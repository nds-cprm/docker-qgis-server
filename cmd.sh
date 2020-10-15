#!/bin/bash

[[ $DEBUG == "1" ]] && env

exec /usr/bin/xvfb-run --auto-servernum --server-num=1 /usr/bin/spawn-fcgi -p 8000 -n -d /home/qgis -- /usr/lib/cgi-bin/qgis_mapserv.fcgi