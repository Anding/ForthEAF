\ test for ForthAstroCameraFITS.f

include C:\MPE\VfxForth\Lib\Win32\Genio\SocketIo.fth
include "%idir%\..\ForthBase\ForthBase.f"
include "%idir%\EAF_SDK.f"
include "%idir%\EAF_SDK_extend.f"
include "%idir%\ForthFocuser.f"
include "%idir%\..\ForthBase\serial\VFX32serial.f"
include "%idir%\..\KMTronic\KMTronic_Bidmead.f"
include "%idir%\..\KMTronic\KMTronic.f"
include "%idir%\..\forth-map\map.fs"
include "%idir%\..\forth-map\map-tools.fs"
include "%idir%\ForthFocuserMaps.f"

-1 constant power-is-relay-switched
CR

power-is-relay-switched [IF] 
\ Switch on the camera relay

	COM-KMT add-relays
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


power-is-relay-switched [IF]
\ Switch off the camera relay

	500 ms
	1 relay-off
	CR ." Relay power off" CR

	remove-relays
	
[THEN]