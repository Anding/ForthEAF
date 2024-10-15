\ test for ForthFocuserMaps.f

include "%idir%\..\ForthBase\libraries\libraries.f"
NEED forthbase
NEED network
NEED serial
NEED ForthKMTronic
NEED forth-map

include "%idir%\EAF_SDK.f"
include "%idir%\EAF_SDK_extend.f"
include "%idir%\ForthFocuser.f"
include "%idir%\ForthFocuserMaps.f"

-1 constant power-is-relay-switched
CR

power-is-relay-switched [IF] 
\ Switch on the camera relay

	add-relays
	1 relay-on
	3000 ms
	." Relay power on" CR
[THEN]

scan-focusers
0 add-focuser
0 use-focuser
500 ms

	map-strings
	map CONSTANT focuser_FITSmap
	focuser_FITSmap add-focuserFITS
	focuser_FITSmap .map

0 remove-focuser

power-is-relay-switched [IF]
\ Switch off the camera relay

	500 ms
	1 relay-off
	CR ." Relay power off" CR

	remove-relays
	
[THEN]