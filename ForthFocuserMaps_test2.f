\ Hardware-free metadata lifecycle checks using focuser replies.
NEED simple-tester
NEED ordered-maps

: focuser_position ( -- n ) 1234 ;
: focuser_name ( -- caddr u ) s" ZWO EAF" ;
: focuser_SN ( -- caddr u ) s" test-focuser" ;
: focuser_temp ( -- n ) 15 ;

include "%idir%\ForthFocuserMaps.f"
allocate-map constant focuser.test-map

Tstart
T{ 5678 focuser.test-map add-focuserFITS }T 5678 ==
T{ focuser.test-map map-count }T 6 ==
T{ s" FOCUSPOS" focuser.test-map map@ s" 1234" compare }T 0 ==
T{ s" FOCUSSZ" focuser.test-map map@ s" unknown" compare }T 0 ==
T{ focuser.test-map reset-map focuser.test-map map-count }T 6 ==
T{ s" FOCUSPOS" focuser.test-map map@ }T 0 0 ==
T{ focuser.test-map add-focuserFITS focuser.test-map map-count }T 6 ==
T{ s" FOCUSER" focuser.test-map map@ s" ZWO EAF" compare }T 0 ==
T{ focuser.test-map erase-map focuser.test-map map-count }T 0 ==
T{ s" FOCUSER" focuser.test-map map@ }T 0 0 ==
T{ focuser.test-map free-map }T ==
Tend
