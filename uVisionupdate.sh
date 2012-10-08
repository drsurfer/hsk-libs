#!/bin/sh -f

IFS='
'

eval "$(make printEnv)"

overlays="$(awk -f scripts/overlays.awk $(find src/ -name \*.c))"

cp uVision/hsk_libs.uvproj uVision/hsk_libs.uvproj.bak
awk -f scripts/xml.awk uVision/hsk_libs.uvproj.bak \
        -search:IncludePath \
        -set:"../$CANDIR" \
        -select:/ \
	-search:OverlayString \
	-set:"$overlays" \
	-select:/ \
	-print > uVision/hsk_libs.uvproj \
		&& rm uVision/hsk_libs.uvproj.bak \
		|| mv uVision/hsk_libs.uvproj.bak uVision/hsk_libs.uvproj

