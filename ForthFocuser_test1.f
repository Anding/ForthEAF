\ test for ForthFocuser.f

include "%idir%\..\ForthBase\libraries\libraries.f"
NEED forthbase
NEED simple-tester

include "%idir%\EAF_SDK.f"
: EAFGetPosition ( id position -- ior ) 2drop 1 ;
1 value test.motion-error
: EAFIsMoving ( id moving handcontrol -- ior )
\ Return idle only when the simulated transport succeeds.
    0 swap ! 0 swap ! drop test.motion-error ;
0 value test.moves
0 value test.position
0 value test.reverse
0 value test.backlash
0 value test.maxsteps
: EAFMove ( id position -- ior )
\ Record a simulated absolute move.
    -> test.position drop 1 +to test.moves 0 ;
: EAFSetReverse ( id reverse -- ior )
\ Capture desired direction.
    -> test.reverse drop 0 ;
: EAFSetBacklash ( id backlash -- ior )
\ Capture desired backlash.
    -> test.backlash drop 0 ;
: EAFSetMaxStep ( id steps -- ior )
\ Capture desired travel limit.
    -> test.maxsteps drop 0 ;
include "%idir%\EAF_SDK_extend.f"
include "%idir%\ForthFocuser.f"

Tstart
T{ 123 1 EAF.?abort focuser_position }T 123 0 ==
T{ 123 100 focus-at test.moves }T 123 0 ==
0 -> test.motion-error
0 -> focuser.default.reverse 50 -> focuser.default.backlash
6500 -> focuser.default.maxsteps 3950 -> focuser.default.position
T{ 123 configure-focuser }T 123 ==
T{ test.reverse test.backlash test.maxsteps test.position test.moves }T 0 50 6500 3950 1 ==
Tend
