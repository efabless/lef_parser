import pprint
import sys
from lef_parser import parse_files

my_lef = parse_files(sys.argv[1:])
pprint.pprint(my_lef)
