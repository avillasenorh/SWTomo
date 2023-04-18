#!/bin/bash
#: Name        : dispersion.sh
#: Description : generates synthetic dispersion curves for a model file
#: Usage       : dispersion.sh model_file
#: Date        : 2019-04-18
#: Author      : "Antonio Villasenor" <antonio.villasenor@csic.es>
#: Version     : 1.0
#: Requirements: programs required by script: CPS, GMT5
#: Arguments   : model_file
#: Options     : none
set -e # stop on error
set -u # error if variable undefined
set -o pipefail
/bin/rm -f gmt.history gmt.conf

[[ $# -ne 1 ]] && { echo "usage: dispersion.sh model_file"; exit 1; } 
[[ ! -s $1 ]] && { echo "ERROR: model file does not exist: $1"; exit 1; } 

model=$1

xmin=1.0
xmax=100.0
ymin=1.0
ymax=4.5

# remove files from previous runs

/bin/rm -f sdisp96.dat sdisp96.ray sdisp96.lov sregn96.egn slegn96.egn
/bin/rm -f SLEGN.* SLEGNC.PLT SLEGNU.PLT SREGN.* SREGNC.PLT SREGNU.PLT

# Generate dispersion curves

sprep96 -M $model -PMIN $xmin -PMAX $xmax -R -L
sdisp96
sregn96 ; slegn96
sdpegn96 -C -L -TXT -S -ASC -XLOG -PER -YMIN $ymin -YMAX $ymax -XMIN $xmin -XMAX $xmax -K 2
sdpegn96 -C -R -TXT -S -ASC -XLOG -PER -YMIN $ymin -YMAX $ymax -XMIN $xmin -XMAX $xmax -K 2
sdpegn96 -U -L -TXT -S -ASC -XLOG -PER -YMIN $ymin -YMAX $ymax -XMIN $xmin -XMAX $xmax -K 4
sdpegn96 -U -R -TXT -S -ASC -XLOG -PER -YMIN $ymin -YMAX $ymax -XMIN $xmin -XMAX $xmax -K 4
#cat SLEGN?.PLT | plotnps -F7 -W10 -EPS -K > slegn.eps
#cat SREGN?.PLT | plotnps -F7 -W10 -EPS -K > sregn.eps
#convert -trim slegn.eps -background white -alpha remove Love.dispcurves.png
#convert -trim sregn.eps -background white -alpha remove Rayleigh.dispcurves.png

grep 'SURF96 L C' SLEGN.dsp | awk '{printf("%8.4f %8.4f\n",$6, $7)}' > LC.xy
grep 'SURF96 L U' SLEGN.dsp | awk '{printf("%8.4f %8.4f\n",$6, $7)}' > LU.xy
grep 'SURF96 R C' SREGN.dsp | awk '{printf("%8.4f %8.4f\n",$6, $7)}' > RC.xy
grep 'SURF96 R U' SREGN.dsp | awk '{printf("%8.4f %8.4f\n",$6, $7)}' > RU.xy

psfile1=L.${model}.ps
gmt psbasemap -R$xmin/$xmax/$ymin/$ymax -JX12cl/12c \
-Bxa2f3+l"period (s)" -Bya0.5f0.1+l"c/U (km/s)" -BWeSn+t"$model Love" -P -Xc -Yc -K > $psfile1

gmt psxy LC.xy -R -J -W2p,green -O -K >> $psfile1
gmt psxy LU.xy -R -J -W2p,red -O -K >> $psfile1

gmt psxy -R -J -T -O >> $psfile1

psfile2=R.${model}.ps
gmt psbasemap -R$xmin/$xmax/$ymin/$ymax -JX12cl/12c \
-Bxa2f3+l"period (s)" -Bya0.5f0.1+l"c/U (km/s)" -BWeSn+t"$model Rayleigh" -P -Xc -Yc -K > $psfile2

gmt psxy RC.xy -R -J -W2p,green -O -K >> $psfile2
gmt psxy RU.xy -R -J -W2p,red -O -K >> $psfile2

gmt psxy -R -J -T -O >> $psfile2

/bin/rm -f ??.xy
/bin/rm -f sdisp96.dat sdisp96.ray sdisp96.lov sregn96.egn slegn96.egn 
/bin/rm -f SLEGN.* SLEGNC.PLT SLEGNU.PLT SREGN.* SREGNC.PLT SREGNU.PLT sregn.eps slegn.eps
/bin/rm -f gmt.history gmt.conf
