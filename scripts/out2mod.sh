#!/bin/bash
#: Name        : out2mod.sh
#: Description : Converts output from CRUST2.0 getCN2point into MOD format for Herrmann's CPS
#: Usage       : out2mod.sh outcr
#: Date        : 2018-11-09
#: Author      : "Antonio Villasenor" <antonio.villasenor@csic.es>
#: Version     : 1.0
#: Requirements: CPS programs
#: Arguments   : outcr file
#: Options     : none
set -e # stop on error
set -u # error if variable undefined
set -o pipefail

progname=${0##*/}
[[ $# -ne 1 ]] && { echo "usage: $progname crust2.0_file"; exit 1; }
[[ ! -s $1 ]] && { echo "ERROR: model file does not exist"; exit 1; }

model=$1
model_name=${model%.*}

/bin/rm -f tmp*

/bin/rm -f ${model_name}.mod
cat << EOF > ${model_name}.mod
MODEL.01
Model after     n iterations
ISOTROPIC
KGS
FLAT EARTH
1-D
CONSTANT VELOCITY
LINE08
LINE09
LINE10
LINE11
      H(KM)   VP(KM/S)   VS(KM/S) RHO(GM/CC)         QP         QS       ETAP       ETAS      FREFP      FREFS
EOF


read -r elevation <<< $( awk '/elevation/ {print $NF}' $model)
read -r vp_moho vs_moho rho_moho <<< $( awk '/Moho/ {print $8, $9, $10}' $model )
awk '(NR > 5 && $1 > 0)' $model > model.dat

while read -r h vp vs rho label; do

	printf " %10.4f %10.4f %10.4f %10.4f   0.00       0.00       0.00       0.00       1.00       1.00\n" $h $vp $vs $rho >> ${model_name}.mod

done < model.dat

printf " %10.4f %10.4f %10.4f %10.4f   0.00       0.00       0.00       0.00       1.00       1.00\n" 0.0 $vp_moho $vs_moho $rho_moho >> ${model_name}.mod


/bin/rm -f tmp*
