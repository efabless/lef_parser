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
import re
from dataclasses import dataclass, field
from typing import Literal, Optional, Dict, Set, Tuple


@dataclass
class Layer:
    name: str


@dataclass
class Pin:
    name: str
    direction: Literal["INPUT", "OUTPUT", "INOUT", "FEEDTHRU"] = "INOUT"
    tristate: Optional[bool] = None
    kind: Literal["SIGNAL", "CLOCK", "POWER", "GROUND"] = "SIGNAL"
    antennaGateArea: Optional[float] = None
    antennaDiffArea: Optional[float] = None

    basename: Optional[str] = None
    index: Optional[int] = None


@dataclass
class Port:
    name: str
    direction: Literal["INPUT", "OUTPUT", "INOUT", "FEEDTHRU"] = "INOUT"
    tristate: Optional[bool] = None
    kind: Literal["SIGNAL", "CLOCK", "POWER", "GROUND"] = "SIGNAL"
    msb: Optional[int] = None
    lsb: Optional[int] = None


@dataclass
class Macro:
    name: str
    site: str = ""
    cls: str = "Core"
    foreign: bool = False
    origin: Tuple[float, float] = (0, 0)
    size: Tuple[float, float] = (0, 0)
    symmetry: Set[Literal["X", "Y", "R90"]] = field(default_factory=lambda: set())
    pins: Dict[str, Pin] = field(default_factory=lambda: {})
    ports: Dict[str, Port] = field(default_factory=lambda: {})


@dataclass
class UnitConversionFactors:
    capacitance_pF: int = 1
    current_mA: int = 1
    db_µm: int = 100
    frequency_mhz: int = 1
    power_mw: int = 1
    resistance_Ω: int = 1
    time_ns: int = 1
    voltage_v: int = 1


@dataclass
class LEF:
    version: str = "5.8"
    unit_conversion_factors: UnitConversionFactors = field(
        default_factory=lambda: UnitConversionFactors()
    )
    busbitchars: str = "[]"
    dividerchar: str = "/"
    layers: Dict[str, Layer] = field(default_factory=lambda: {})
    macros: Dict[str, Macro] = field(default_factory=lambda: {})

    def __post_init__(self):
        self.update_busbitchars(self.busbitchars)

    def update_busbitchars(self, busbitchars: str):
        self.busbitchars = busbitchars
        self._busbitchars_rx = re.compile(
            rf"{re.escape(self.busbitchars[0])}(\d+){re.escape(self.busbitchars[1])}$"
        )

    def process_pin(self, pin: Pin):
        basename = pin.name
        if match := self._busbitchars_rx.search(basename):
            pin.index = int(match[1])
            basename = self._busbitchars_rx.sub("", basename)
        pin.basename = basename

    def process_macro(self, macro: Macro):
        ports: Dict[str, Port] = {}
        for pin in macro.pins.values():
            assert (
                pin.basename is not None
            ), f"Pin {pin.name} was not properly processed"
            port = ports.get(
                pin.basename,
                Port(
                    name=pin.basename,
                    direction=pin.direction,
                    kind=pin.kind,
                    tristate=pin.tristate,
                ),
            )
            if pin.index is not None:
                port.msb = max(pin.index, port.msb or 0)
                port.lsb = min(pin.index, port.lsb or 0)
            ports[pin.basename] = port
        macro.ports = ports
