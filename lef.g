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
grammar lef;

options {
	tokenVocab = lefLexer;
}

top: statement+ KW_End KW_Library;

statement:
	version_statement
	| busbitchar_statement
	| clearancemeasure_statement
	| dividerchar_statement
	| units_statement
	| useminspacing_statement
	| mfg_grid_statement
	| propertydefinitions_statement
	| nowireextensionatpin_statement
	| site_statement
	| layer_statement
	| via_statement
	| macro_statement
	|
	// TODO: viarule_statement |
	viarule_generate_statement;

nowireextensionatpin_statement:
	KW_NoWireExtensionAtPin (KW_On | KW_Off) Semicolon;

version_statement: KW_Version Number Semicolon;

busbitchar_statement: KW_BusBitChars String Semicolon;

clearancemeasure_statement:
	KW_ClearanceMeasure (KW_MaxXY | KW_Euclidean) Semicolon;

dividerchar_statement: KW_DividerChar String Semicolon;

mfg_grid_statement: KW_ManufacturingGrid Number Semicolon;

useminspacing_statement:
	KW_UseMinSpacing KW_Obs (KW_On | KW_Off) Semicolon;

ext_statement: KW_BeginExt EM_String extension* EM_KW_EndExt;

extension: EM_Name EM_String;

// Property Definitions
propertydefinitions_statement:
	KW_PropertyDefinitions property_definition* KW_End KW_PropertyDefinitions;

property_definition: KW_Layer Name KW_String Semicolon;

// Units
units_statement: KW_Units unit_declaration* KW_End KW_Units;

unit_declaration:
	KW_Time KW_Nanoseconds Number Semicolon
	| KW_Capacitance KW_PicoFarads Number Semicolon
	| KW_Resistance KW_Ohms Number Semicolon
	| KW_Power KW_Milliwatts Number Semicolon
	| KW_Voltage KW_Volts Number Semicolon
	| KW_Database KW_Microns Number Semicolon
	| KW_Frequency KW_Megahertz Number Semicolon
	| KW_Current KW_Milliamps Number Semicolon;

// Site   
site_statement: KW_Site Name site_rule* KW_End Name;

site_rule:
	KW_Symmetry symmetry Semicolon
	| KW_Class site_class Semicolon
	| KW_Size Number KW_By Number Semicolon;

site_class: KW_Pad | KW_Core;

// Layer
layer_statement: KW_Layer Name layer_rule* KW_End Name;

layer_rule:
	// TODO: Probably missing a whole bunch of rules here
	lef58_property_rule
	| ac_density_rule
	| dc_density_rule
	| antenna_area_rule
	| array_spacing_rule
	| enclosure_rule
	| property
	| spacing_rule
	| layer_type_rule
	| direction_rule
	| pitch_rule
	| offset_rule
	| width_rule
	| spacing_table_rule
	| area_rule
	| thickness_rule
	| resistance_rule
	| capacitance_rule
	| edgecapacitance_rule
	| minenclosedarea_rule
	| density_rule;

lef58_property_rule: property;

ac_density_rule:
	KW_ACCurrentDensity (KW_Peak | KW_Average | KW_RMS) ac_density_value Semicolon;

ac_density_value:
	Number
	| KW_Frequency Number+ Semicolon (
		KW_CutArea Number+ Semicolon
	)? KW_TableEntries Number+;

dc_density_rule:
	KW_DCCurrentDensity KW_Average dc_density_value Semicolon;

dc_density_value:
	Number
	| KW_Width Number+ Semicolon KW_TableEntries Number+;

array_spacing_rule:
	KW_ArraySpacing (KW_LongArray)? (KW_Width Number)? KW_CutSpacing Number (
		KW_ArrayCuts Number KW_Spacing Number
	)+ Semicolon;

density_rule:
	KW_MaximumDensity Number Semicolon
	| KW_DensityCheckWindow Number Number Semicolon
	| KW_DensityCheckStep Number Semicolon
	| KW_MinimumDensity Number Semicolon;

direction_rule:
	KW_Direction (
		KW_Vertical
		| KW_Horizontal
		| KW_Diag45
		| KW_Diag135
	) Semicolon;

spacing_rule: KW_Spacing Number spacing_subrule? Semicolon;

spacing_subrule:
	KW_Range Number Number spacing_range_subrule?
	| KW_LengthThreshold Number (KW_Range Number Number)?
	| KW_EndOfLine Number KW_Within Number (
		KW_ParallelEdge Number KW_Within Number KW_TwoEdges?
	)?;

spacing_range_subrule:
	KW_UseRangeThreshold
	| KW_Influence Number (KW_Range Number Number)?
	| KW_Range Number Number;

spacing_c2c_subrule:
	KW_Layer Name KW_Stack?
	| KW_AdjacentCuts Number KW_Within Number KW_ExceptSamePGNet?
	| KW_ParallelOverlap
	| KW_Area Number;

layer_type_rule: KW_Type layer_type Semicolon;

layer_type:
	KW_Cut
	| KW_Implant
	| KW_Masterslice
	| KW_Overlap
	| KW_Routing;

width_rule:
	KW_Width Number Semicolon
	| KW_MinWidth Number Semicolon
	| KW_MaxWidth Number Semicolon;

area_rule: KW_Area Number Semicolon;

thickness_rule: KW_Thickness Number Semicolon;

enclosure_rule:
	KW_Enclosure (KW_Above | KW_Below)? Number Number (
		KW_Width Number (KW_ExceptExtraCut Number)?
	)? (KW_Length Number)? Semicolon
	| KW_PreferEnclosure (KW_Above | KW_Below)? Number Number (
		KW_Width Number
	)? Semicolon;

minenclosedarea_rule: KW_MinEnclosedArea Number Semicolon;

pitch_rule:
	KW_Pitch (Number | (Number Number)) Semicolon
	| KW_DiagPitch (Number | (Number Number)) Semicolon;

offset_rule: KW_Offset (Number | (Number Number)) Semicolon;

resistance_rule:
	KW_Resistance Number Semicolon
	| KW_Resistance KW_RPerSq Number Semicolon;

capacitance_rule:
	KW_Capacitance Number Semicolon
	| KW_Capacitance KW_CPerSqDist Number Semicolon;

edgecapacitance_rule: KW_EdgeCapacitance Number Semicolon;

/// Antenna Rules
antenna_area_rule:
	KW_AntennaAreaDiffReducePWL tuple_list Semicolon
	| KW_AntennaAreaFactor Number KW_DiffuseOnly? Semicolon
	| KW_AntennaAreaMinusDiff Number Semicolon
	| KW_AntennaAreaRatio Number Semicolon
	| KW_AntennaSideAreaRatio Number Semicolon
	| KW_AntennaCumAreaRatio Number Semicolon
	| KW_AntennaCumDiffAreaRatio (Number | (KW_PWL tuple_list)) Semicolon
	| KW_AntennaGatePlusDiff Number Semicolon
	| KW_AntennaModel Oxide Semicolon
	| KW_AntennaSideAreaFactor Number KW_DiffuseOnly? Semicolon
	| KW_AntennaDiffAreaRatio (Number | (KW_PWL tuple_list)) Semicolon
	| KW_AntennaDiffSideAreaRatio (Number | (KW_PWL tuple_list)) Semicolon;

/// Spacing Tables
spacing_table_rule:
	KW_SpacingTable KW_Orthognal spacing_table_cut_row+ Semicolon
	| KW_SpacingTable KW_ParallelRunLength Number+ (
		spacing_table_routing_prl_row
	)+ Semicolon (spacing_table_routing_prl_influence Semicolon)?
	| KW_TwoWidths (KW_Width Number (KW_PRL Number)? KW_Spacing+)+ Semicolon;

spacing_table_cut_row:
	KW_Within Number KW_Spacing Number Semicolon;

spacing_table_routing_prl_row: KW_Width Number Number+;

spacing_table_routing_prl_influence:
	KW_SpacingTable KW_Influence spacing_table_routing_prl_influence_row+;

spacing_table_routing_prl_influence_row:
	KW_Width Number KW_Within Number KW_Spacing Number;

// Via, ViaRule, etc
via_statement:
	// TODO: Other style (VIA viaName DEFAULT VIARULE)
	KW_Via Name KW_Default? via_element* KW_End Name;

via_element:
	KW_Resistance Number Semicolon
	| KW_Layer Name Semicolon polygon+
	| property;

polygon:
	KW_Rect pt pt Semicolon
	| KW_Polygon pt pt pt+ Semicolon;

viarule_generate_statement:
	KW_ViaRule Name KW_Generate KW_Default? KW_Layer Name Semicolon KW_Enclosure Number Number
		Semicolon (KW_Width Number KW_To Number Semicolon)? KW_Layer Name Semicolon KW_Enclosure
		Number Number Semicolon (
		KW_Width Number KW_To Number Semicolon
	)? KW_Layer Name Semicolon KW_Rect pt pt Semicolon KW_Spacing Number KW_By Number Semicolon (
		KW_Resistance Number Semicolon
	)? KW_End Name;

// Macros
macro_statement: KW_Macro Name macro_property* KW_End Name;

macro_property:
	KW_Class macro_class Semicolon
	| KW_Foreign Name Semicolon
	| KW_Origin pt Semicolon
	| KW_Size Number KW_By Number Semicolon
	| KW_Symmetry symmetry Semicolon
	| KW_Site Name Semicolon
	| pin_declaration
	| obs_declaration;

macro_class:
	KW_Cover (KW_Bump)?
	| KW_Ring
	| KW_Block (KW_Blackbox | KW_Soft)?
	| KW_Pad (
		KW_Input
		| KW_Output
		| KW_Inout
		| KW_Power
		| KW_Spacer
		| KW_AreaIO
	)?
	| KW_Core (
		KW_Feedthru
		| KW_TieHigh
		| KW_TieLow
		| KW_Spacer
		| KW_AntennaCell
		| KW_Welltap
	)?
	| KW_Endcap (
		KW_Pre
		| KW_Post
		| KW_TopLeft
		| KW_TopRight
		| KW_BottomLeft
		| KW_BottomRight
	)?;
symmetry:
	KW_X
	| KW_Y
	| KW_R90
	| KW_X KW_Y
	| KW_Y KW_R90
	| KW_X KW_Y KW_R90;

pin_declaration: KW_Pin Name pin_property* KW_End Name;

pin_property:
	KW_Direction pin_direction Semicolon
	| KW_Use (KW_Power | KW_Ground | KW_Clock | KW_Signal) Semicolon
	| KW_Shape KW_Abutment Semicolon
	| KW_AntennaGateArea Number Semicolon
	| KW_AntennaDiffArea Number Semicolon
	| KW_Port macro_layer_declaration* KW_End;

pin_direction:
	KW_Input
	| KW_Output (KW_Tristate)?
	| KW_Inout
	| KW_Feedthru;

obs_declaration: KW_Obs macro_layer_declaration* KW_End;

macro_layer_declaration:
	KW_Layer Name Semicolon (
		KW_Rect Number Number Number Number Semicolon
	)*;

// Common
pt: Number Number;

tuple_list: LParen (LParen Number Number RParen)+ RParen;

property: KW_Property Name (Number | String) Semicolon;
