#!/bin/bash
#: Name        : get_mftdsp.sh
#: Description : Reads ".phv" and ".dsp" files obtained from do_mft
#:               and converts it to input for Barmim's tomography code
#: Usage       : get_mftdsp.sh
#: Date        : 2019-03-26
#: Author      : "Antonio Villasenor" <antonio.villasenor@csic.es>
#: Version     : 1.0
#: Requirements: none 
#: Arguments   : none
#: Options     : none
set -e # stop on error
set -u # error if variable undefined
set -o pipefail

progname=${0##*/}

/bin/rm -f disp.list
find . -name "COR_*.phv" -print > disp.list
find . -name "COR_*.dsp" -print >> disp.list

ncor=$( echo disp.list | wc -l )

[[ $ncor -eq 0 ]] && { echo "ERROR: no phv/dsp files in current directory"; /bin/rm -f disp.list; exit 1; }

/bin/rm -f all.tmp
touch all.tmp

while read -r disp_file; do

	awk '{printf("%-1s%-1s %5.1f %7.5f %10.4f %10.4f %10.4f %10.4f %s\n", $2, $3, $5, $6, $11, $12, $13, $14, FILENAME)}' $disp_file >> all.tmp

done < disp.list
/bin/rm -f disp.list

for vel in RC RU LC LU; do

    echo $vel
	grep "^$vel" all.tmp > $vel.dat
	awk '{print $2}' $vel.dat | sort -nu > $vel.periods

	while read -r period; do
		echo $period
#		outfile=$( printf "%2s%05.1f_MFT.dat" $vel $period )
		outfile=$( echo $vel $period | awk '{printf("%2s%05.1f_MFT.dat", $1, $2)}' )
		echo $outfile
		awk 'BEGIN {n = 0} ($2 == period) {n++; printf("%5d %10.4f %10.4f %10.4f %10.4f %7.5f 0.000 1 %s\n", n, $4, $5, $6, $7, $3, $8)}' period=$period $vel.dat > $outfile
	done < $vel.periods
	/bin/rm -f $vel.periods $vel.dat

done

/bin/rm -f all.tmp
