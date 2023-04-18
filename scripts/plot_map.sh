#!/bin/bash
#: Title       :
#: Synopsis    :
#: Date        : 2018-03-06
#: Author      : "Antonio Villasenor" <antonio.villasenor@csic.es>
#: Version     : 1.0
#: Requirements:
#: Arguments   : parfile
#: Options     : none
set -u # error if variable undefined
set -o pipefail

/bin/rm -f gmt.history gmt.conf

model=$1
filename=${model%.*}
extension=${model##*.}
psfile=$filename.ps

period=${filename##*_}

lat1=5.0                       # bottom latitude of model
lat2=15.0                      # top latitude of model
dlat=0.5                       # model grid in latitude (degrees)
lon1=-69.0                     # left latitude of model
lon2=-60.0                     # right latitude of model
dlon=0.5                       # model grid in longitude (degrees)

region=-R$lon1/$lon2/$lat1/$lat2


# convert model to percent (and interpolate to topography grid)

if [[ $extension = "1_%_" ]]; then
	gmt xyz2grd $model -Gmodel.grd $region -I$dlon/$dlat -di0 \
	-Ddegree/degree/percent/1/0/"velocity perturbation (%)"
else
	refvel=$( head -1 $model | awk '{print $3}' )
	echo $refvel
	gmt xyz2grd $model -Gtmp.grd $region -I$dlon/$dlat -di0 \
	-Ddegree/degree/percent/1/0/"velocity perturbation"
	gmt grdmath tmp.grd $refvel SUB $refvel DIV 100 MUL = model.grd
fi

cpt=8%_panoply.cpt

gmt set PS_MEDIA                   A4
gmt set PROJ_LENGTH_UNIT           cm
gmt set FONT_ANNOT_PRIMARY         10p
gmt set MAP_TICK_LENGTH_PRIMARY    -0.2c
gmt set FORMAT_GEO_MAP             dddF

projection="-JM14c"
xa=5
xt=1
xg=0
ya=5
yt=1
yg=0

gmt psbasemap $region ${projection} -Bxa${xa}f${xt}g${xg} -Bya${ya}f${yt}g${yg} -BWeSn+t"$filename" -Xc -Yc -P -K > $psfile

gmt grdimage model.grd -C$cpt -R -J -O -K >> $psfile

gmt pscoast -R -J -B -Di -A100/1/1  -W0.75p -O -K >> $psfile
gmt pscoast -R -J -B -Di -A1000/1/2 -W0.75p -O -K >> $psfile

gmt psscale -C$cpt -Dx7.5c/-1c+w15c/0.5c+jTC+h+e -Bx+l"velocity perturbation (%)" -O -K >> $psfile

gmt psxy -R -J -T -O >> $psfile

/bin/rm -f tmp.grd model.grd
/bin/rm -f gmt.history gmt.conf
