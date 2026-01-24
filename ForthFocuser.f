\ Forth lexicon for controlling a focuser
\ 	ZWO EAF version
\ 	interactive version - errors will report and abort

\ requires EAF_SDK.f
\ requires EAF_SDK_extend.f
\ requires forthbase.f

\ Lexicon conventions
\ 	wheel.word or cam.ID is a word within the encapsulation
\ 	dash is used as a verb-noun seperator
\ 	underscore is used as a whitespace in a noun (including structure field names and hardware properties)
\ 	camelCase is used as whitespace in a verb (including values and variables)
\ 	word? reports text to the user
\ 	->property ( x --) sets a hardware property
\ 	property ( -- x) returns a hardware property

\ Operational notes
\ 	values over variables
\ 	actions to the presently-selected-camera   

s" " $value eaf.str1

: focuser_name ( -- caddr u)
\ return the name of the focuser
	EAFFocuserInfo EAF_FOCUSER_NAME zcount
;

: focuser_SN   ( -- caddr u)
\ return the S/N of the focuser as a hex string
	base @ >R hex
	EAFSN dup @ ( n) swap 4 + @ ( n) swap		\ S/N is stored in big-endian format
	<# # # # # # # # # # # # # # # # # #> 	\ VFX has no word (ud.)
	R> base !
;

: focuser_moving { | moving handcontrol } ( -- flag) 
	focuser.ID ADDR moving ADDR handcontrol 
	EAFIsMoving case
	    0 OF ADDR moving c@ ENDOF   \ some focusers return byte boolean type	
	    5 OF -1 ENDOF               \ some focusers return the ismoving code
        0 SWAP 
    ENDCASE
;

: wait-focuser ( --)
\ synchronous hold until the focuser stops moving
	begin
	    100 ms                  \ default delay to allow the previous command to start
		focuser_moving 0=
	until
;

: focuser_position { | pos } ( -- pos) \ VFX locals for pass-by-reference 
	focuser.ID ADDR pos EAFGetPosition EAF.?abort
	pos
;

: ->focuser_position ( pos --)
	focuser.ID swap EAFMove EAF.?abort
; 

: focuser_backlash { | steps } ( -- steps ) \ VFX locals for pass-by-reference 
	focuser.ID ADDR steps EAFGetBacklash EAF.?abort
	steps
;

: ->focuser_backlash ( pos --)
	focuser.ID swap EAFSetBacklash EAF.?abort
; 

: focuser_maxsteps { | steps } ( -- steps) \ VFX locals for pass-by-reference 
	focuser.ID ADDR steps EAFGetMaxStep EAF.?abort
	steps
;

: ->focuser_maxsteps ( steps -- ) \ VFX locals for pass-by-reference 
	focuser.ID swap EAFSetMaxStep EAF.?abort
;

: focuser_reverse { | flag } ( -- flag) \ VFX locals for pass-by-reference 
	focuser.ID ADDR flag EAFGetReverse EAF.?abort
	ADDR flag c@	\ API appears to use the byte boolean type
;

: ->focuser_reverse ( flag --)
	focuser.ID swap EAFSetReverse EAF.?abort
;

: focuser_temp { | temp } ( -- temp) \ VFX locals for pass-by-reference 
	focuser.ID ADDR temp EAFGetTemp EAF.?abort
	ADDR temp sf@ fr>s
;

: focuser_stop
	focuser.ID EAFStop
;

: focuser_beeping { | flag } ( -- pos) \ VFX locals for pass-by-reference 
	focuser.ID ADDR flag EAFGetBeep EAF.?abort
	ADDR flag c@	\ API appears to use the byte boolean type
;

: ->focuser_beeping ( flag --)
	focuser.ID swap EAFSetBeep EAF.?abort
;

: focuser_steprange { | flag } ( -- steps) \ VFX locals for pass-by-reference 
	focuser.ID ADDR flag EAFStepRange EAF.?abort
	ADDR flag @	
;

: add-focuser ( FocuserID --)
\ make a focuser available for application use
\ 	connect the focuser and calibrate it
    EAFGetNum 0= if s" no connected focusers" cr .>E cr abort then
	dup EAFOpen EAF.?abort
	500 ms
	EAFFocuserInfo ( ID buffer) EAFGetProperty EAF.?abort    
;

: use-focuser ( FocuserID --)
\ choose the focuser to be selected for operations - must be added first
	-> focuser.ID
	focuser.ID EAFFocuserInfo ( ID buffer) EAFGetProperty EAF.?abort
	focuser.ID EAFSN EAFGetSerialNumber drop   
	focuser_name $-> eaf.str1 s"  at position " $+> eaf.str1
	focuser_position (.) $+> eaf.str1
	cr eaf.str1 .> cr	
;

: remove-focuser ( FocuserID --)
\ disconnect the focuser, it becomes unavailable to the application
    wait-focuser
	EAFClose drop
;

: scan-focusers ( -- )
\ scan the plugged-in focusers
\ create a CONSTANT (out of the name and S/N) for each FocuserID
	EAFGetNum ( -- n)
	?dup
	IF
		\ loop over each connected focuser
		CR ." ID" tab ." Handle" tab tab  ." Focuser" CR
		0 do
			i EAFFocuserID ( index buffer) EAFGetID  EAF.?abort
			EAFFocuserID @										( ID)
			dup -> focuser.ID .
			focuser.ID EAFOpen EAF.?abort
			focuser.ID EAFFocuserInfo ( ID buffer) EAFGetProperty EAF.?abort
			focuser.ID EAFSN EAFGetSerialNumber drop 			
			focuser.ID EAF.make-handle	2dup tab type 	( ID c-addr u)		
			($constant)											( --)			
			focuser_name tab type CR
			focuser.ID EAFClose EAF.?abort		
		loop
	ELSE
		CR ." No connected focusers" CR
	THEN
;

\ user lexicon

: check-focuser ( --)
\ connect and report the current focuser to the user
	focuser.ID EAFFocuserInfo ( ID buffer) EAFGetProperty EAF.?abort	
	CR 
	." Focuser ID = " focuser.ID . 	
	."  ; Name = " focuser_name type
;

: focus-at ( pos --)
	wait-focuser
	->focuser_position cr
	begin
		focuser_moving
		100 ms
		focuser_position (.) .>
	while
		150 ms
	repeat cr
;

: focus? ( -- pos)
    cr focuser_position (.) .> cr
	cr
;	