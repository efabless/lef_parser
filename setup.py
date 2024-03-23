#!/usr/bin/env python3
import os
import sys
import subprocess
from setuptools import setup

module_name = "lef_parser"
__dir__ = os.path.dirname(os.path.abspath(__file__))

version = subprocess.check_output(
    [
        sys.executable,
        os.path.join(
            os.path.abspath(__dir__),
            module_name,
            "__version__.py",
        ),
    ],
    encoding="utf8",
)

requirements = (
    open(os.path.join(__dir__, "requirements.txt")).read().strip().split("\n")
)


setup(
    name=module_name,
    packages=["lef_parser", "_lef_parser_antlr"],
    package_data={module_name: ["py.typed"], "_lef_parser_antlr": []},
    version=version,
    description="Antlr4-based parser for LEF files",
    long_description=open(os.path.join(__dir__, "Readme.md")).read(),
    long_description_content_type="text/markdown",
    author="Efabless Corporation and Contributors",
    author_email="donn@efabless.com",
    install_requires=requirements,
    classifiers=[
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3",
        "Intended Audience :: Developers",
        "Operating System :: POSIX :: Linux",
        "Operating System :: MacOS :: MacOS X",
    ],
    python_requires=">3.8",
)
