from ast import parse
import os
import pytest


def test_complete():
    from lef_parser import parse_files

    lef = parse_files(
        [
            os.path.join(pytest.test_root, "files", "complete.lef"),
        ]
    )
