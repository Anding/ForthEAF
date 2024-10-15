\ test for EAF_SDK.f

include "%idir%\..\ForthBase\libraries\libraries.f"
NEED forthbase
NEED network
NEED serial
NEED ForthKMTronic

include "%idir%\EAF_SDK.f"
include "%idir%\EAF_SDK_extend.f"
include "%idir%\ForthFocuser.f"

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