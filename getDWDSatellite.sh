#! /bin/bash
# v.0.0.3
# get satellite data from www.dwd.de and open it with eye of gnome
# will create subdirectories if nescessary
#
# WorldComposite Flat:
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/wcm__aktuell__m24h,templateId=poster,property=poster.png
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/wcm__aktuell__m21h,templateId=poster,property=poster.png
# ... every 3 hours ...
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/wcm__aktuell__m03h,templateId=poster,property=poster.png
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/wcm__aktuell,templateId=poster,property=poster.png
#
# WorldComposite Hammer Projection:
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/kompHammer__aktuell__m08s,templateId=poster,property=poster.png
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/kompHammer__aktuell__m07s,templateId=poster,property=poster.png
# ... special case: m0#s is substracted by 1 every time  ...
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/kompHammer__aktuell__m01s,templateId=poster,property=poster.png
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/kompHammer__aktuell__m00s,templateId=poster,property=poster.png
#
# global view centered on africa:
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/met10__erde__aktuell__m24h,templateId=poster,property=poster.png
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/met10__erde__aktuell__m21h,templateId=poster,property=poster.png
# ... every 3 hours ...
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/met10__erde__aktuell__m03h,templateId=poster,property=poster.png
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Global/met10__erde__aktuell,templateId=poster,property=poster.png
#
# regional view of central europe centered on germany:
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Regional/met8__deut__aktuell__m24h,templateId=poster,property=poster.png
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Regional/met8__deut__aktuell__m21h,templateId=poster,property=poster.png
# ... every 3 hours ...
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Regional/met8__deut__aktuell__m03h,templateId=poster,property=poster.png
# http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/Regional/met8__deut__aktuell,templateId=poster,property=poster.png
#
#   Copyright © 2015 GGShinobi (GGShinobi@googlemail.com)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

# set global variables:
currentDir=`pwd`
tempMasterDir=/tmp/Satellite/
urlPrefix="http://www.dwd.de/bvbw/generator/DWDWWW/Content/Oeffentlichkeit/WV/WVFK/Dynamisches/"

function startDownload() {
  wgetOpts="-a ${tempMasterDir}${mode}.log"
  tmpDir=${tempMasterDir}$mode
  # create subdirectory for download if nescessary:
  [ -d $tmpDir ] || mkdir -p $tmpDir

  # start download of satellite data:
  cd $tmpDir; echo -n "downloading images to "; pwd

  # special case: World Hammer Projection uses different URLs and counting mechanism (better/simpler imho):
  if [ "$mode" == "worldHammer" ]; then
    urlPostfix="s,templateId=poster,property=poster.png"
    counter=8; substractor=01
    for (( img=$counter ; $img>=0 ; img=$(($img - $substractor)) )); do
      url="${urlPrefix}${urlPart}${img}${urlPostfix}"
      wget $wgetOpts $url
    done

  else

    urlPostfix="h,templateId=poster,property=poster.png"
    counter=24; substractor=3
    # the others are a little bit more complicated:
    unset preimg; unset urlPostPart
    for (( img=$counter ; $img>=0 ; img=$(($img - $substractor)) )); do

      # if img between 0 and 10 we need a leading 0
      if [ $img -lt 10 ] && [  $img -gt 0 ]; then preimg=0 ; fi

      # special case if 0:
      if [ $img -eq 0 ]; then
        img=
        preimg=
        urlPostfix=",templateId=poster,property=poster.png"
        urlPostPart=
      else
        urlPostPart="__m"
      fi


      url="${urlPrefix}${urlPart}${urlPostPart}${preimg}${img}${urlPostfix}"
      wget $wgetOpts $url
    done
  fi

  # display downloaded data with eye of gnome and return to old dir:
  eog . &
  cd $currentDir
}

# ask satellite/radar mode from user:
unset mode
echo "=============="
echo "Please choose:"
echo "=============="
# echo -n "WorldComposite (h)ammer, WorldComposite (f)lat, (g)lobal (Africa), global Ind(i)a, global A(u)stralia, (e)ast Pacific, A(m)erica, (r)egional (Europe/Germany), (a)ll or (s)howDir? "
echo "h: WorldComposite (h)ammer"
echo "f: WorldComposite (f)lat"
echo "g: (g)lobal (Africa)"
echo "i: global Ind(i)a"
echo "u: global A(u)stralia"
echo "e: (e)ast Pacific"
echo "m: A(m)erica"
echo "r: (r)egional (Europe/Germany)"
echo "a: (a)ll"
echo -n "s: (s)howDir? "
read answer
case "$answer" in
  h*) mode="worldHammer" ; urlPart="Global/kompHammer__aktuell__m0" ; startDownload ;;
  f*) mode="worldFlat" ; urlPart="Global/wcm__aktuell" ; startDownload ;;
  g*) mode="global" ; urlPart="Global/met10__erde__aktuell" ; startDownload ;;
  i*) mode="india" ; urlPart="Global/met7__erde__aktuell" ; startDownload ;;
  u*) mode="australia" ; urlPart="Global/mtsat1r__erde__aktuell" ; startDownload ;;
  e*) mode="pacific" ; urlPart="Global/goes15__erde__aktuell" ; startDownload ;;
  m*) mode="america" ; urlPart="Global/goes13__erde__aktuell" ; startDownload ;;
  r*) mode="regional" urlPart="Regional/met8__deut__aktuell" ; startDownload ;;
  a*) mode="all" ;;
  s*) nautilus $tempMasterDir; exit ;;
   *) echo "exiting..."; exit 0 ;;
esac

if [ "$mode" == "all" ]; then
echo "<<<< DOWNLOADING ALL >>>>"
  mode="worldHammer" ; urlPart="Global/kompHammer__aktuell__m0" ; startDownload
  mode="worldFlat" ; urlPart="Global/wcm__aktuell" ; startDownload
  mode="global" ; urlPart="Global/met10__erde__aktuell" ; startDownload
  mode="india" ; urlPart="Global/met7__erde__aktuell" ; startDownload
  mode="australia" ; urlPart="Global/mtsat1r__erde__aktuell" ; startDownload
  mode="pacific" ; urlPart="Global/goes15__erde__aktuell" ; startDownload
  mode="america" ; urlPart="Global/goes13__erde__aktuell" ; startDownload
  mode="regional" urlPart="Regional/met8__deut__aktuell" ; startDownload
fi
