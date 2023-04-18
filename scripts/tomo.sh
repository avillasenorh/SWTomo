#!/bin/bash
#: Name        : ${0##*/}
#: Description : Template for bash-shell scripts
#: Usage       : bash_template.sh input_files -o output_file -V
#: Date        : $(date +%Y-%m-%d)
#: Author      : "Antonio Villasenor" <antonio.villasenor@csic.es>
#: Version     : 1.0
#: Requirements: programs required by script (GMT5, gdate, getjul, etc)
#: Arguments   : argument1
#:               argument2
#: Options     : -o output_file   - write ouput to output file
#:               -h               - print help
#:               -V               - verbose
set -e # stop on error
set -u # error if variable undefined
set -o pipefail

datafile=RC020.0.dat
per=20.0

alpha=1200
sigma=250
beta=10
prefix=RC_${alpha}_${sigma}_${beta}

lat1=5.0                       # bottom latitude of model
lat2=15.0                      # top latitude of model
dlat=0.5                       # model grid in latitude (degrees)
lon1=-69.0                     # left latitude of model
lon2=-60.0                     # right latitude of model
dlon=0.5                       # model grid in longitude (degrees)

itomo_sp_cu_shn $datafile $prefix $per << EOF > $prefix.itomo.log
me
4
5
$beta
6
$alpha
$sigma
$sigma
7
$lat1 $lat2 $dlat
8
$lon1 $lon2 $dlon
12
0.1
$dlat
16
v
q
go
EOF
