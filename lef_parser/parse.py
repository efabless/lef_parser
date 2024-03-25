# Copyright 2024 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import os
import sys
from enum import IntEnum
from collections import deque
from typing import Deque, Optional, Sequence, TextIO, Tuple, Type, Union

from _lef_parser_antlr.lefListener import lefListener  # type: ignore
from _lef_parser_antlr.lefParser import lefParser  # type: ignore
from _lef_parser_antlr.lefLexer import lefLexer  # type: ignore
from antlr4 import InputStream, CommonTokenStream, ParseTreeWalker, Token  # type: ignore

from .data import LEF, Macro, Pin, Layer


class Lexer(lefLexer):
    IDENTIFIED_BLOCKS = set(
        [
            lefLexer.KW_Units,
            lefLexer.KW_PropertyDefinitions,
        ]
    )
    NAMED_BLOCKS = set(
        [
            lefLexer.KW_Site,
            lefLexer.KW_Layer,
            lefLexer.KW_Via,
            lefLexer.KW_ViaRule,
            lefLexer.KW_Macro,
            lefLexer.KW_Pin,
        ]
    )
    ANONYMOUS_BLOCKS = set([lefLexer.KW_Port, lefLexer.KW_Obs])

    TOP_LEVEL_BLOCKS = set(
        [
            lefLexer.KW_Layer,
            lefLexer.KW_Site,
            lefLexer.KW_Macro,
            lefLexer.KW_Via,
            lefLexer.KW_ViaRule,
            lefLexer.KW_Units,
            lefLexer.KW_PropertyDefinitions,
        ]
    )
    NESTED_BLOCKS = set(
        [
            lefLexer.KW_Pin,
            lefLexer.KW_Port,
            lefLexer.KW_Obs,
        ]
    )

    NAME_MODE_TOKENS = NAMED_BLOCKS.union(
        set([lefLexer.KW_Foreign, lefLexer.KW_Property])
    )

    class BlockState(IntEnum):
        default = 0
        waitingForName = 1
        waitingForMatch = 2

    def __init__(
        self,
        input: Optional[InputStream] = None,
        output: TextIO = sys.stdout,
    ):
        super().__init__(input, output)

        self.block_stack: Deque[Tuple[int, Optional[str]]] = deque([(0, "LIBRARY")])
        self.block_state = Lexer.BlockState.default
        self.named_block_kind: Optional[int] = None
        self.block_matching_string: Optional[str] = None

    def nextToken(self):
        # So, this slows down the lexer a *lot*. This is all because LEF
        # uses three kinds of blocks.
        #
        # "Identifier Blocks": e.g. UNITS (…) END UNITS
        # "Named Blocks": e.g. SITE x (…) END x
        # "Anonymous Blocks": e.g. OBS (…) END
        #
        # Because identifiers need to be lexed separately from keywords, the
        # logic is complex.
        #
        token = super().nextToken()
        assert isinstance(token, Token)

        # Handle "Waiting" States
        if self.block_state == Lexer.BlockState.waitingForName:
            assert self.named_block_kind is not None, "state inconsistent"
            self.block_stack.append((self.named_block_kind, token.text))
            self.named_block_kind = None
            self.block_state = Lexer.BlockState.default
            return token
        if self.block_state == Lexer.BlockState.waitingForMatch:
            if self.block_matching_string != token.text:
                listener = self.getErrorListenerDispatch()
                listener.syntaxError(
                    self,
                    None,
                    self._tokenStartLine,
                    self._tokenStartColumn,
                    f"Invalid end for block: expecting {self.block_matching_string}",
                    None,
                )
            self.block_matching_string = None
            self.block_state = Lexer.BlockState.default
            return token

        # Check if the mode Changes
        if token.type == self.KW_End:
            kind, matching = self.block_stack.pop()
            if matching is not None:
                self.block_matching_string = matching
                if kind in self.NAMED_BLOCKS:
                    self.pushMode(self.NAME_MODE)
                self.block_state = Lexer.BlockState.waitingForMatch
            return token

        if token.type in self.NAME_MODE_TOKENS:
            if token.type == self.KW_ViaRule:
                if self.block_stack[-1] != "VIA":
                    self.pushMode(self.NAME_MODE)
            else:
                self.pushMode(self.NAME_MODE)

        # If starting a block: add it to the stack
        if (
            len(self.block_stack) == 1
            and token.type in self.TOP_LEVEL_BLOCKS
            or len(self.block_stack) >= 2
            and token.type in self.NESTED_BLOCKS
        ):
            if token.type in self.NAMED_BLOCKS:
                self.block_state = Lexer.BlockState.waitingForName
                self.named_block_kind = token.type
            else:
                matchable: Optional[str] = None
                if token.type in self.IDENTIFIED_BLOCKS:
                    matchable = str(token.text)
                self.block_stack.append((int(token.type), matchable))
        return token


class Listener(lefListener):
    def __init__(
        self,
        file_name: str = "<Anonymous>",
        lef_in: Optional[LEF] = None,
    ) -> None:
        super().__init__()
        self.file_name = file_name
        self.lef = lef_in or LEF()
        self.current_layer: Optional[Layer] = None
        self.current_macro: Optional[Macro] = None
        self.current_pin: Optional[Pin] = None

    @property
    def layer(self):
        assert self.current_layer is not None
        return self.current_layer

    @property
    def macro(self):
        assert self.current_macro is not None
        return self.current_macro

    @property
    def pin(self):
        assert self.current_pin is not None
        return self.current_pin

    def exitVersion_statement(self, ctx: lefParser.Version_statementContext):
        self.lef.version = str(ctx.children[1])

    def exitBusbitchar_statement(self, ctx: lefParser.Busbitchar_statementContext):
        self.lef.update_busbitchars(str(ctx.children[1])[1:-1])

    def exitDividerchar_statement(self, ctx: lefParser.Dividerchar_statementContext):
        self.lef.dividerchar = str(ctx.children[1])[1:-1]

    def exitUnit_declaration(self, ctx: lefParser.Unit_declarationContext):
        if str(ctx.children[0]) == "DATABASE":
            self.lef.unit_conversion_factors.db_μm = int(str(ctx.children[2]))
        else:
            # The rest are to be ignored per the standard. Yep.
            pass

    def enterLayer_statement(self, ctx: lefParser.Layer_statementContext):
        identifier = str(ctx.children[1])
        self.current_layer = Layer(name=identifier)
        self.lef.layers[identifier] = self.current_layer

    def exitLayer_statement(self, ctx: lefParser.Layer_statementContext):
        if str(ctx.children[-1]) != self.layer.name:
            raise ValueError(
                f"Error: mismatched END for layer {self.layer.name}: '{str(ctx.children[-1])}'"
            )
        self.current_layer = None

    def enterMacro_statement(self, ctx: lefParser.Macro_statementContext):
        identifier = str(ctx.children[1])
        self.current_macro = Macro(name=identifier)
        self.lef.macros[identifier] = self.current_macro

    def exitMacro_statement(self, ctx: lefParser.Macro_statementContext):
        if str(ctx.children[-1]) != self.macro.name:
            raise ValueError(
                f"Error: mismatched END for macro {self.macro.name}: '{str(ctx.children[-1])}'"
            )
        self.lef.process_macro(self.macro)
        self.current_macro = None

    def enterPin_declaration(self, ctx: lefParser.Pin_declarationContext):
        identifier = str(ctx.children[1])
        self.current_pin = Pin(name=identifier)
        self.macro.pins[identifier] = self.current_pin

    def enterPin_property(self, ctx: lefParser.Pin_propertyContext):
        directive = str(ctx.children[0])
        p = self.pin
        if directive == "USE":
            p.kind = str(ctx.children[1])
        elif directive == "ANTENNAGATEAREA":
            p.antennaGateArea = float(str(ctx.children[1]))
        elif directive == "ANTENNADIFFAREA":
            p.antennaDiffArea = float(str(ctx.children[1]))

        # TODO: The rest

    def enterPin_direction(self, ctx: lefParser.Pin_directionContext):
        direction = str(ctx.children[0])
        tristate = None
        if direction == "OUTPUT":
            tristate = len(ctx.children) > 1 and str(ctx.children[1]) == "TRISTATE"
        self.pin.direction = direction
        self.pin.tristate = tristate

    def exitPin_declaration(self, ctx: lefParser.Pin_declarationContext):
        if str(ctx.children[-1]) != self.pin.name:
            raise ValueError(
                f"Error: mismatched END for macro {self.pin.name}: '{str(ctx.children[-1])}'"
            )
        self.lef.process_pin(self.pin)
        self.current_pin = None

    def syntaxError(
        self, recognizer, offendingSymbol, line, charPositionInLine, msg, e
    ):
        raise ValueError(
            f"Syntax Error at {self.file_name}:{line}:{charPositionInLine}: {msg}"
        )

    def reportAttemptingFullContext(self, *args, **kwargs):
        pass

    def reportAmbiguity(self, *args, **kwargs):
        pass


def parse(
    file_in: Union[str, os.PathLike],
    string: Optional[str] = None,
    lef_in: Optional[LEF] = None,
    listener_type: Type[Listener] = Listener,
) -> LEF:
    if string is None:
        string = open(file_in).read()
    listener = listener_type(file_name=str(file_in), lef_in=lef_in)

    stream = InputStream(string)

    lexer = Lexer(stream)
    lexer.addErrorListener(listener)
    token_stream = CommonTokenStream(lexer)
    token_stream.fill()
    # print(token_stream.getTokens(start=0, stop=9999999))
    parser = lefParser(token_stream)
    parser.addErrorListener(listener)

    tree = parser.top()

    ParseTreeWalker.DEFAULT.walk(listener, tree)

    return listener.lef


def parse_files(
    files: Sequence[Union[str, os.PathLike]], lef_in: Optional[LEF] = None
) -> LEF:
    lef_so_far = lef_in
    if len(files) == 0:
        raise ValueError("No LEF files provided")
    for file in files:
        lef_so_far = parse(file, lef_in=lef_so_far)
    assert isinstance(lef_so_far, LEF)
    return lef_so_far
