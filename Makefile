PYTHON3 ?= python3
ANTLR4 ?= antlr4
REQ_FILES = ./requirements_dev.txt ./requirements.txt
REQ_FILES_PFX = $(addprefix -r ,$(REQ_FILES))

all: dist

.PHONY: dist
dist: venv/manifest.txt _lef_parser_antlr/lefParser.py
	./venv/bin/python3 setup.py sdist bdist_wheel

.PHONY: lint
lint: venv/manifest.txt
	./venv/bin/black --check .
	./venv/bin/flake8 .
	./venv/bin/mypy --check-untyped-defs .

antlr: _lef_parser_antlr/lefParser.py
_lef_parser_antlr/lefParser.py: lefLexer.g lef.g
	$(ANTLR4) -Dlanguage=Python3 -o $(@D) $^

venv: venv/manifest.txt
venv/manifest.txt: $(REQ_FILES)
	rm -rf venv
	$(PYTHON3) -m venv ./venv
	PYTHONPATH= ./venv/bin/python3 -m pip install --upgrade pip
	PYTHONPATH= ./venv/bin/python3 -m pip install --upgrade wheel
	PYTHONPATH= ./venv/bin/python3 -m pip install --upgrade $(REQ_FILES_PFX)
	PYTHONPATH= ./venv/bin/python3 -m pip freeze > $@


.PHONY: clean
clean:
	rm -rf _lef_parser_antlr/
	rm -rf build/
	rm -rf dist/
	rm -rf htmlcov/
	rm -rf *.egg-info/
	rm -rf .antlr/
	rm -f .coverage
