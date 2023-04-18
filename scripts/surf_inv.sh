#!/bin/bash
#: Name        : surf_inv.sh
#: Description : Inverts surface wave dispersion curves for 1-D Vs structure
#: Usage       : surf_inv.sh disp_file initial_model
#: Date        : 2019-03-26
#: Author      : "Antonio Villasenor" <antonio.villasenor@csic.es>
#: Version     : 1.0
#: Requirements: Herrmann's CPS
#: Arguments   : 1 = file with dispersion measurements in surf96 format
#:               2 = initial model in Herrmann's format
#: Options     : none
set -e # stop on error
set -u # error if variable undefined
set -o pipefail

progname=${0##*/}
[[ $# -ne 2 ]] && { echo "usage: $progname disp_file initial_model"; exit 1; }

[[ ! -s $1 ]] && { echo "ERROR: dispersion file does not exist: $1"; exit 1; }
[[ ! -s $2 ]] && { echo "ERROR: initial model file does not exist: $2"; exit 1; }

/bin/rm -f tmpmod96.* tmpsrfi.*  tmpmrgs.* *.PLT *.eps *.png 

/bin/rm -f sobs.d
echo "   5.00000000E-03   5.00000000E-03   0.00000000       5.00000000E-03   0.00000000" >> sobs.d
echo "    1    0    1    1    0    1    1    0    1    0" >> sobs.d
echo $2 >> sobs.d
echo $1 >> sobs.d

/bin/rm -f *.PLT

#####
#   initialize by cleaning up
#####

surf96 39

#####
#   fix the bottom layer for stability
#####
surf96 31 30 0.0

#####
#   for the initial runs use a large damping to prevent artificial low velocity zones
#####
surf96 32 10

#####
#    do 10 iterations with this value
#####
surf96 37 10 1 2 6 

#####
#    reduce the damping
#####
surf96 32 1

#####
#    do 10 iterations with this value
#####
surf96 37 10 1 2 6 

#####
#    get the final prediction for this model
#####
surf96 1

#####
#    save the current model
#####
surf96 28 model.out

#####
# plot the dispersion fit
#####
srfphv96

#####
#   compare the final and initial models
#####
shwmod96 -ZMAX 60 -VMIN 1 -VMAX 5 -K -1 -LEGIN model.in model.out
mv SHWMOD96.PLT MODEL.PLT


#####
#   show the progression of the inversion as a guide to changing the controls
#####
shwmod96 -ZMAX 60 -VMIN 1 -VMAX 5 -K -1 -LEGIN tmpmod96*
mv SHWMOD96.PLT MODITERATION.PLT

plotnps  -F7 -W10 -EPS -K < MODEL.PLT > MODEL.eps
plotnps  -F7 -W10 -EPS -K < SRFPHV96.PLT > DATAFIT.eps
#convert -trim MODEL.eps -background white -alpha remove -alpha off MODEL.png

/bin/rm -f sobs.d
/bin/rm -f tmpmod96.* tmpsrfi.*  tmpmrgs.*
