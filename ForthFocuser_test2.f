\ test for EAF_SDK.f

include C:\MPE\VfxForth\Lib\Win32\Genio\SocketIo.fth
include "%idir%\..\ForthBase\ForthBase.f"
include "%idir%\EAF_SDK.f"
include "%idir%\EAF_SDK_extend.f"
include "%idir%\ForthFocuser.f"
include "%idir%\..\ForthBase\serial\VFX32serial.f"
include "%idir%\..\ForthKMTronic\KMTronic_Bidmead.f"
include "%idir%\..\ForthKMTronic\KMTronic.f"

-1 constant power-is-relay-switched
CR

power-is-relay-switched [IF] 
\ Switch on the camera relay

	COM_KMT add-relays
	1 relay-on
	3000 ms
	." Relay power on" CR
[THEN]

scan-focusers
0 add-focuser
0 use-focuser

CR
what-focuser?

: monitor-focuser
	begin
		250 ms
		focuser_moving
	while
		." focuser position is " focuser_position . CR
	repeat
	." focuser position is " focuser_position . CR
;

0 ->focuser_position
monitor-focuser

2000 ->focuser_position
monitor-focuser

0 remove-focuser

power-is-relay-switched [IF]
\ Switch off the camera relay

	500 ms
	1 relay-off
	CR ." Relay power off" CR

	remove-relays
	
[THEN]