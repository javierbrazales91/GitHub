clear all
set more off
set matsize 11000
set maxvar 20000

global path "C:\Users\CEMFI\Dropbox\00_S5\GitHub\Development-Economics\HWK03\Codes"
global output "$path\Output"

cd "$path"


global check "full sample"
do "$path/002_main.do"

global check "rural"
do "$path/002_main.do"

global check "urban"
do "$path/002_main.do"
