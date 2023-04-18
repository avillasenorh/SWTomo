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
/bin/rm -f gmt.history gmt.conf

progname=${0##*/}

[[ $# -ne 1 ]] && { echo "usage: $progname model_file"; exit 1; }
[[ ! -s $1 ]] && { echo "ERROR: model file does not exist: $1"; exit 1; }
model=$1

xmin=0.5
xmax=30.0
ymin=1.0
ymax=4.5


# Generate dispersion curves

/bin/rm -f sdisp96.dat sdisp96.ray sdisp96.lov sregn96.egn slegn96.egn
/bin/rm -f SLEGN.* SLEGNC.PLT SLEGNU.PLT SREGN.* SREGNC.PLT SREGNU.PLT

sprep96 -M $model -PMIN $xmin -PMAX $xmax -R -L
sdisp96
sregn96 ; slegn96
sdpegn96 -C -L -TXT -S -ASC -XLOG -PER -YMIN $ymin -YMAX $ymax -XMIN $xmin -XMAX $xmax -K 2
sdpegn96 -C -R -TXT -S -ASC -XLOG -PER -YMIN $ymin -YMAX $ymax -XMIN $xmin -XMAX $xmax -K 2
sdpegn96 -U -L -TXT -S -ASC -XLOG -PER -YMIN $ymin -YMAX $ymax -XMIN $xmin -XMAX $xmax -K 4
sdpegn96 -U -R -TXT -S -ASC -XLOG -PER -YMIN $ymin -YMAX $ymax -XMIN $xmin -XMAX $xmax -K 4

grep 'SURF96 L C' SLEGN.dsp | awk '{printf("SURF96 L C X   0 %8.4f %8.4f %8.4f\n",$6, $7, 0.1)}' > LC.dsp
grep 'SURF96 L U' SLEGN.dsp | awk '{printf("SURF96 L U X   0 %8.4f %8.4f %8.4f\n",$6, $7, 0.1)}' > LU.dsp
grep 'SURF96 R C' SREGN.dsp | awk '{printf("SURF96 R C X   0 %8.4f %8.4f %8.4f\n",$6, $7, 0.1)}' > RC.dsp
grep 'SURF96 R U' SREGN.dsp | awk '{printf("SURF96 R U X   0 %8.4f %8.4f %8.4f\n",$6, $7, 0.1)}' > RU.dsp

/bin/rm -f sdisp96.dat sdisp96.ray sdisp96.lov sregn96.egn slegn96.egn 
/bin/rm -f SLEGN.* SLEGNC.PLT SLEGNU.PLT SREGN.* SREGNC.PLT SREGNU.PLT sregn.eps slegn.eps

color=( darkblue blue dodgerblue yellow darkolivegreen1 darkolivegreen4 red2 )

psfile1=LC.ps
psfile2=LU.ps
psfile3=RC.ps
psfile4=RU.ps
/bin/rm -f $psfile1 $psfile2 $psfile3 $psfile4

#(( i = 0 ))
i=0
#for period in 0.5 0.75 1.0 2.0 5.0 10.0 20.0; do
#for period in 0.5 0.75 1.0 2.0 3.0 4.0 5.0; do
for period in 5.0 ; do

/bin/rm -f tmp* sobs.d tdisp.d

cat << EOF1 > sobs.d
  4.99999989E-03  4.99999989E-03   0.0000000      4.99999989E-03   0.0000000
    1    1    1    1    1    1    1    0    1    0
$model
tdisp.d
EOF1

/bin/rm -f tdisp.d
touch tdisp.d
awk '$6 == period' period=$period LC.dsp >> tdisp.d
awk '$6 == period' period=$period RC.dsp >> tdisp.d
awk '$6 == period' period=$period LU.dsp >> tdisp.d
awk '$6 == period' period=$period RU.dsp >> tdisp.d
cat sobs.d
cat tdisp.d

ndisp=$( cat tdisp.d | wc -l )

if [ $ndisp -eq 4 ]; then
    surf96 39
    surf96 1
    srfker96 > kernel.$period.txt
    surf96 39

    # LC and LU
    gmt psbasemap -R-0.05/0.15/0/30    -JX10c/-14c -Bxa0.05f0.01g1+l"dvs/dc (Love)"     -Bya5f1+l"depth (km)" -BWeNs -P -Xc -Yc -K > $psfile1
    awk 'BEGIN {z = 0} {if (NF == 9 && $0 !~ /LAYER/) { z += $2; print 1.0*$3, z}}' kernel.$period.txt | \
    gmt psxy -R -J -W0.5p,${color[$i]} -O -K >> $psfile1
    gmt psxy -R -J -T -O >> $psfile1

    gmt psbasemap -R-0.05/0.15/0/30 -JX10c/-14c -Bxa0.05f0.01g1+l"dvs/dU (Love)"     -Bya5f1+l"depth (km)" -BWeNs -P -Xc -Yc -K > $psfile2
    awk 'BEGIN {z = 0} {if (NF == 9 && $0 !~ /LAYER/) { z += $2; print 1.0*$4, z}}' kernel.$period.txt | \
    gmt psxy -R -J -W0.5p,${color[$i]} -O -K >> $psfile2
    gmt psxy -R -J -T -O >> $psfile2

    # RC and RU
    gmt psbasemap -R-0.05/0.15/0/30    -JX10c/-14c -Bxa0.05f0.01g1+l"dvs/dc (Rayleigh)" -Bya5f1+l"depth (km)" -BWeNs -P -Xc -Yc -K > $psfile3
    awk 'BEGIN {z = 0} {if (NF == 14 && $0 !~ /LAYER/) { z += $2; print 1.0*$4, z}}' kernel.$period.txt | \
    gmt psxy -R -J -W0.5p,${color[$i]} -O -K >> $psfile3
    gmt psxy -R -J -T -O >> $psfile3

    gmt psbasemap -R-0.05/0.15/0/30 -JX10c/-14c -Bxa0.1f0.05g1+l"dvs/dU (Rayleigh)"  -Bya5f1+l"depth (km)" -BWeNs -P -Xc -Yc -K > $psfile4
    awk 'BEGIN {z = 0} {if (NF == 14 && $0 !~ /LAYER/) { z += $2; print 1.0*$6, z}}' kernel.$period.txt | \
    gmt psxy -R -J -W0.5p,${color[$i]} -O -K >> $psfile4
    gmt psxy -R -J -T -O >> $psfile4

else
    echo "ERROR: period $period s not in dispersion files.dsp"
fi


#(( i++ ))
i=$((i+1))
/bin/rm -f tmp* sobs.d tdisp.d

done


/bin/rm -f ??.dsp kernel.*.txt
/bin/rm -f gmt.history gmt.conf
