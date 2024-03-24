import os
import pytest


def test_spm():
    from lef_parser import parse_files

    lef = parse_files(
        [
            os.path.join(pytest.test_root, "files", "spm_example.lef"),
        ]
    )

    assert list(lef.macros["spm"].pins.keys()) == [
        "VGND",
        "VPWR",
        "clk",
        "p",
        "rst",
        "x[0]",
        "x[10]",
        "x[11]",
        "x[12]",
        "x[13]",
        "x[14]",
        "x[15]",
        "x[16]",
        "x[17]",
        "x[18]",
        "x[19]",
        "x[1]",
        "x[20]",
        "x[21]",
        "x[22]",
        "x[23]",
        "x[24]",
        "x[25]",
        "x[26]",
        "x[27]",
        "x[28]",
        "x[29]",
        "x[2]",
        "x[30]",
        "x[31]",
        "x[3]",
        "x[4]",
        "x[5]",
        "x[6]",
        "x[7]",
        "x[8]",
        "x[9]",
        "y",
    ], "failed to extract pins"

    for pin in lef.macros["spm"].pins.values():
        if pin.direction == "INPUT":
            assert (
                pin.antennaGateArea is not None
            ), f"Failed to extract {pin.name}'s antenna gate area"
        elif pin.direction == "OUTPUT":
            assert (
                pin.antennaDiffArea is not None
            ), f"Failed to extract {pin.name}'s antenna diff area"
        elif pin.direction == "INOUT":
            assert pin.kind in [
                "POWER",
                "GROUND",
            ], f"Failed to extract kind for {pin.name}"


def test_tristate():
    from lef_parser import parse_files

    lef = parse_files(
        [
            os.path.join(pytest.test_root, "files", "tristate_example.lef"),
        ]
    )

    for pin in lef.macros["user_proj_example"].pins.values():
        if pin.direction == "OUTPUT":
            assert pin.tristate, f"Pin {pin.name} not correctly parsed as tristate"
