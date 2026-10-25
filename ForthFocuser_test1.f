\ test for ForthFocuser.f

include "%idir%\..\ForthBase\libraries\libraries.f"
NEED forthbase
NEED simple-tester

include "%idir%\EAF_SDK.f"
: EAFGetPosition ( id position -- ior ) 2drop 1 ;
: EAFIsMoving ( id moving handcontrol -- ior ) 3drop 1 ;
0 value test.moves
: EAFMove ( id position -- ior ) 2drop 1 +to test.moves 0 ;
include "%idir%\EAF_SDK_extend.f"
include "%idir%\ForthFocuser.f"

Tstart
T{ 123 1 EAF.?abort focuser_position }T 123 0 ==
T{ 123 100 focus-at test.moves }T 123 0 ==
Tend
