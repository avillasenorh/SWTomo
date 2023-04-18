#!/bin/bash
#: Name        : map_template.sh
#: Description : Template for GMT5 maps
#: Usage       : bash_template.sh
#: Date        : 2017-05-25
#: Author      : "Antonio Villasenor" <antonio.villasenor@csic.es>
#: Version     : 1.0 (based on maptemplate5.csh)
#: Requirements: GMT5
#: Arguments   : none
#: Options     : none
#set -e # stop on error
set -u # error if variable undefined
set -o pipefail

/bin/rm -f gmt.history gmt.conf

progname=${0##*/}
if [[ $# -ne 1 ]]; then
   echo "usage: $progname correlation_file_prefix"
   exit 1
fi

prefix=$1

psfile=$prefix.ps
/bin/rm -f $psfile

love_disp=${prefix}_TT_S_2_DISP.1
rayleigh_disp=${prefix}_ZZ_S_2_DISP.1

if [[ -s $love_disp ]]; then
    awk '{print $3, $4}' $love_disp > aftan_love_u.xy
    awk '{print $3, $5}' $love_disp > aftan_love_c.xy
else
    echo "WARNING: no Love waves FTAN file for $prefix"
fi

if [[ -s $rayleigh_disp ]]; then
    awk '{print $3, $4}' $rayleigh_disp > aftan_rayleigh_u.xy
    awk '{print $3, $5}' $rayleigh_disp > aftan_rayleigh_c.xy
else
    echo "WARNING: no Rayleigh waves FTAN file for $prefix"
fi

[[ -s ${prefix}_TT_S.dsp ]] && awk '{print $5, $6}' ${prefix}_TT_S.dsp > mft_love_u.xy
[[ -s ${prefix}_TT_S.phv ]] && awk '{print $5, $6}' ${prefix}_TT_S.phv > mft_love_c.xy
[[ -s ${prefix}_ZZ_S.dsp ]] && awk '{print $5, $6}' ${prefix}_ZZ_S.dsp > mft_rayleigh_u.xy
[[ -s ${prefix}_ZZ_S.phv ]] && awk '{print $5, $6}' ${prefix}_ZZ_S.phv > mft_rayleigh_c.xy

xmin=2.0
xmax=100.0
ymin=1.0
ymax=4.5

region="-R$xmin/$xmax/$ymin/$ymax"

projection=X
scalex=13
scaley=13

J="-J${projection}${scalex}cl/${scaley}c"

gmt psbasemap $region $J -Bxa2f3g3+l"period (s)" -Bya0.5f0.1g0.5+l"c/U (km/s)" -BWeSn+t"$prefix" -Xc -Yc -P -K > $psfile

test -s mft_love_c.xy && gmt psxy mft_love_c.xy -R -J -W3p,green -O -K >> $psfile
test -s mft_love_u.xy && gmt psxy mft_love_u.xy -R -J -W3p,green,dashed -O -K >> $psfile
test -s mft_rayleigh_c.xy && gmt psxy mft_rayleigh_c.xy -R -J -W3p,red -O -K >> $psfile
test -s mft_rayleigh_u.xy && gmt psxy mft_rayleigh_u.xy -R -J -W3p,red,dashed -O -K >> $psfile

test -s aftan_love_c.xy && gmt psxy aftan_love_c.xy -R -J -W1.5p,darkolivegreen3 -O -K >> $psfile
test -s aftan_love_u.xy && gmt psxy aftan_love_u.xy -R -J -W1.5p,darkolivegreen3,dashed -O -K >> $psfile
test -s aftan_rayleigh_c.xy && gmt psxy aftan_rayleigh_c.xy -R -J -W1.5p,darkorange4 -O -K >> $psfile
test -s aftan_rayleigh_u.xy && gmt psxy aftan_rayleigh_u.xy -R -J -W1.5p,darkorange4,dashed -O -K >> $psfile

gmt psxy -R -J -T -O >> $psfile

/bin/rm -f aftan_*_[cu].xy mft_*_[cu].xy
/bin/rm -f gmt.history gmt.conf
