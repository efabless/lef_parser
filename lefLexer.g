// Copyright 2024 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
lexer grammar lefLexer;

Comment: '#' ~('\n' | '\r')* '\r'? '\n' -> channel(HIDDEN);
String: '"' ('\\' ["\\] | ~["\\])* '"';
Semicolon: Whitespace+ ';';
Ws: Whitespace+ -> skip;

KW_Layer: 'LAYER';
KW_Site: 'SITE';
KW_Via: 'VIA';
KW_ViaRule: 'VIARULE';
KW_Macro: 'MACRO';
KW_Foreign: 'FOREIGN';
KW_Pin: 'PIN';
KW_End: 'END';

KW_Version: 'VERSION';
KW_BusBitChars: 'BUSBITCHARS';
KW_DividerChar: 'DIVIDERCHAR';
KW_Units: 'UNITS';
KW_ManufacturingGrid: 'MANUFACTURINGGRID';
KW_UseMinSpacing: 'USEMINSPACING';
KW_ClearanceMeasure: 'CLEARANCEMEASURE';
KW_PropertyDefinitions: 'PROPERTYDEFINITIONS';
KW_MaxViaStack: 'MAXVIASTACK';
KW_Generate: 'GENERATE';
KW_NonDefaultRule: 'NONDEFAULTRULE';
KW_BeginExt: 'BEGINEXT' -> pushMode(EXTENSION_MODE);
KW_Obs: 'OBS';
KW_Library: 'LIBRARY';
KW_MaxXY: 'MAXXY';
KW_Euclidean: 'EUCLIDEAN';
KW_Type: 'TYPE';
KW_Property: 'PROPERTY';
KW_Spacing: 'SPACING';
KW_SpacingTable: 'SPACINGTABLE';
KW_Orthognal: 'ORTHOGNAL';
KW_ACCurrentDensity: 'ACCURRENTDENSITY';
KW_DCCurrentDensity: 'DCCURRENTDENSITY';
KW_Peak: 'PEAK';
KW_Average: 'AVERAGE';
KW_RMS: 'RMS';
KW_ArrayCuts: 'ARRAYCUTS';
KW_CutArea: 'CUTAREA';
KW_CutSpacing: 'CUTSPACING';
KW_TableEntries: 'TABLEENTRIES';
KW_AntennaAreaDiffReducePWL: 'ANTENNAAREADIFFREDUCEPWL';
KW_AntennaAreaFactor: 'ANTENNAAREAFACTOR';
KW_AntennaSideAreaFactor: 'ANTENNASIDEAREAFACTOR';
KW_AntennaAreaMinusDiff: 'ANTENNAAREAMINUSDIFF';
KW_AntennaAreaRatio: 'ANTENNAAREARATIO';
KW_AntennaSideAreaRatio: 'ANTENNASIDEAREARATIO';
KW_AntennaDiffAreaRatio: 'ANTENNADIFFAREARATIO';
KW_AntennaDiffSideAreaRatio: 'ANTENNADIFFSIDEAREARATIO';
KW_AntennaCumAreaRatio: 'ANTENNACUMAREARATIO';
KW_AntennaCumDiffAreaRatio: 'ANTENNACUMDIFFAREARATIO';
KW_AntennaGatePlusDiff: 'ANTENNAGATEPLUSDIFF';
KW_AntennaModel: 'ANTENNAMODEL';
KW_ArraySpacing: 'ARRAYSPACING';
KW_DiffuseOnly: 'DIFFUSEONLY';
KW_PWL: 'PWL';
KW_LongArray: 'LONGARRAY';
KW_Width: 'WIDTH';
KW_MinWidth: 'MINWIDTH';
KW_MaxWidth: 'MAXWIDTH';
KW_Length: 'LENGTH';
KW_Enclosure: 'ENCLOSURE';
KW_PreferEnclosure: 'PREFERENCLOSURE';
KW_Above: 'ABOVE';
KW_Below: 'BELOW';
KW_ExceptExtraCut: 'EXCEPTEXTRACUT';
KW_CenterToCenter: 'CENTERTOCENTER';
KW_SameNet: 'SAMENET';
KW_Stack: 'STACK';
KW_AdjacentCuts: 'ADJACENTCUTS';
KW_Within: 'WITHIN';
KW_ExceptSamePGNet: 'EXCEPTSAMEPGNET';
KW_ParallelOverlap: 'PARALLELOVERLAP';
KW_ParallelRunLength: 'PARALLELRUNLENGTH';
KW_Area: 'AREA';
KW_Thickness: 'THICKNESS';
KW_Class: 'CLASS';
KW_Size: 'SIZE';
KW_By: 'BY';
KW_To: 'TO';
KW_Symmetry: 'SYMMETRY';
KW_On: 'ON';
KW_Off: 'OFF';
KW_String: 'STRING';
KW_Direction: 'DIRECTION';
KW_Vertical: 'VERTICAL';
KW_Horizontal: 'HORIZONTAL';
KW_Diag45: 'DIAG45';
KW_Diag135: 'DIAG135';
KW_Pitch: 'PITCH';
KW_DiagPitch: 'DIAGPITCH';
KW_Offset: 'OFFSET';
KW_Influence: 'INFLUENCE';
KW_TwoWidths: 'TWOWIDTHS';
KW_PRL: 'PRL';
KW_MinEnclosedArea: 'MINENCLOSEDAREA';
KW_MaximumDensity: 'MAXIMUMDENSITY';
KW_DensityCheckWindow: 'DENSITYCHECKWINDOW';
KW_DensityCheckStep: 'DENSITYCHECKSTEP';
KW_Default: 'DEFAULT';
KW_Rect: 'RECT';
KW_Polygon: 'POLYGON';
KW_Origin: 'ORIGIN';
KW_UseRangeThreshold: 'USERANGETHRESHOLD';
KW_LengthThreshold: 'LENGTHTHRESHOLD';
KW_EndOfLine: 'ENDOFLINE';
KW_ParallelEdge: 'PARALLELEDGE';
KW_TwoEdges: 'TWOEDGES';
KW_Cut: 'CUT';
KW_Implant: 'IMPLANT';
KW_Masterslice: 'MASTERSLICE';
KW_Overlap: 'OVERLAP';
KW_Routing: 'ROUTING';
KW_EdgeCapacitance: 'EDGECAPACITANCE';
KW_Time: 'TIME';
KW_Nanoseconds: 'NANOSECONDS';
KW_Capacitance: 'CAPACITANCE';
KW_PicoFarads: 'PICOFARADS';
KW_CPerSqDist: 'CPERSQDIST';
KW_Resistance: 'RESISTANCE';
KW_Ohms: 'OHMS';
KW_RPerSq: 'RPERSQ';
KW_Power: 'POWER';
KW_Ground: 'GROUND';
KW_Signal: 'SIGNAL';
KW_Milliwatts: 'MILLIWATTS';
KW_Voltage: 'VOLTAGE';
KW_Volts: 'VOLTS';
KW_Database: 'DATABASE';
KW_Microns: 'MICRONS';
KW_Frequency: 'FREQUENCY';
KW_Megahertz: 'MEGAHERTZ';
KW_Current: 'CURRENT';
KW_Milliamps: 'MILLIAMPS';
KW_Input: 'INPUT';
KW_Output: 'OUTPUT';
KW_Inout: 'INOUT';
KW_Tristate: 'TRISTATE';
KW_Use: 'USE';
KW_Shape: 'SHAPE';
KW_Abutment: 'ABUTMENT';
KW_Port: 'PORT';
KW_Clock: 'CLOCK';
KW_NoWireExtensionAtPin: 'NOWIREEXTENSIONATPIN';
KW_AntennaGateArea: 'ANTENNAGATEAREA';
KW_AntennaDiffArea: 'ANTENNADIFFAREA';
KW_MinimumDensity: 'MINIMUMDENSITY';
KW_Range: 'RANGE';
KW_Cover: 'COVER';
KW_Block: 'BLOCK';
KW_Blackbox: 'BLACKBOX';
KW_Soft: 'SOFT';
KW_Bump: 'BUMP';
KW_Ring: 'RING';
KW_Core: 'CORE' | 'core'; // gf180 uses lowercase for some reason
KW_Pad: 'PAD' | 'pad'; // match core
KW_AreaIO: 'AREAIO';
KW_Spacer: 'SPACER';
KW_AntennaCell: 'ANTENNACELL';
KW_Welltap: 'WELLTAP';
KW_Feedthru: 'FEEDTHRU';
KW_TieHigh: 'TIEHIGH';
KW_TieLow: 'TIELOW';
KW_Endcap: 'ENDCAP';
KW_Pre: 'PRE';
KW_Post: 'POST';
KW_TopLeft: 'TOPLEFT';
KW_TopRight: 'TOPRIGHT';
KW_BottomLeft: 'BOTTOMLEFT';
KW_BottomRight: 'BOTTOMRIGHT';

KW_R90: 'R90';
KW_X: 'X';
KW_Y: 'Y';

Oxide: 'OXIDE' [0-9]+;
Number: ('-')? Integer ('.' Integer)? ('E' '-'? Integer)?;
LParen: '(';
RParen: ')';

// Common
fragment Integer: Digit+;
fragment Whitespace: (' ' | '\t' | EOL);
fragment EOL: ('\n');
fragment NonEOL: ~('\n');
fragment Nondigit: [a-zA-Z_];
fragment Digit: [0-9];

mode NAME_MODE;

NAME_MODE_WS: (' ' | '\t')+ -> skip;
Name: [!<>$.&?|{}:'`"@_~^=,A-Za-z0-9[\]]+ -> popMode;

mode EXTENSION_MODE;

EM_Comment: '#' ~('\n' | '\r')* '\r'? '\n' -> channel(HIDDEN);
EM_String: '"' ('\\' ["\\] | ~["\\])* '"';
EM_Semicolon: Whitespace+ ';';
EM_Ws: Whitespace+ -> skip;
EM_Name: [!<>$.&?|{}:'`"@_~^=,A-Za-z0-9[\]]+ -> popMode;
EM_KW_EndExt: 'ENDEXT' -> popMode;
