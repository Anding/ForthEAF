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

: focuser_name ( -- caddr u)
\ return the name of the focuser
	EAFFocuserInfo EAF_FOCUSER_NAME zcount
;

: focuser_SN   ( -- caddr u)
\ return the S/N of the focuser as a hex string
	base @ >R hex
	EAFSN 2@ <# #s #> 	\ VFX has no word (ud.)
	R> base !
;

: focuser_moving { | moving handcontrol -- flag } 
	focuser.ID addr moving addr handcontrol 
	EAFIsMoving EAF.?abort
	moving	
;

: wait-focuser ( --)
\ synchronous hold until the wheel stops moving
	begin
		focuser_moving
	while
		." . " 250 ms
	repeat
;

: focuser_position { | pos } ( -- pos) \ VFX locals for pass-by-reference 
	wait-focuser
	focuser.ID ADDR pos EAFGetPosition EAF.?abort
	pos
;

: ->focuser_position ( pos --)
	wait-focuser
	focuser.ID swap EAFMove EAF.?abort
; 

: focuser_backlash { | steps -- steps } \ VFX locals for pass-by-reference 
	focuser.ID ADDR steps EAFGetBacklash EAF.?abort
	steps
;

: ->focuser_backlash ( pos --)
	focuser.ID swap EAFSetBacklash EAF.?abort
; 

: focuser_maxsteps { | steps -- steps } \ VFX locals for pass-by-reference 
	focuser.ID ADDR steps EAFGetMaxStep EAF.?abort
	steps
;

: ->focuser_maxsteps { steps -- steps } \ VFX locals for pass-by-reference 
	focuser.ID swap EAFSetMaxStep EAF.?abort
;

: focuser_reverse { | flag -- flag } \ VFX locals for pass-by-reference 
	focuser.ID ADDR flag EAFGetReverse EAF.?abort
	flag
;

: ->focuser_reverse ( flag --)
	focuser.ID swap EAFSetReverse EAF.?abort
;

: focuser_temp { | temp -- temp } \ VFX locals for pass-by-reference 
	focuser.ID ADDR temp EAFGetTemp EAF.?abort
	ADDR temp sf@ fr>s
;

: focuser_stop
	focuser.ID EAFStop
;

: focuser_beeping { | flag -- flag } \ VFX locals for pass-by-reference 
	focuser.ID ADDR flag EAFGetBeep EAF.?abort
	flag
;

: ->focuser_beeping ( flag --)
	focuser.ID swap EAFSetBeep EAF.?abort
;

: focuser_steprange { | flag -- flag } \ VFX locals for pass-by-reference 
	focuser.ID ADDR flag EAFStepRange EAF.?abort
	flag
;

: add-focuser ( FocuserID --)
\ make a wheel available for application use
\ 	connect the wheel and calibrate it
	dup EAFOpen EAF.?abort
	500 ms
	EAFFocuserInfo ( ID buffer) EAFGetProperty EAF.?abort
;

: use-focuser ( FocuserID --)
\ choose the focuser to be selected for operations - must be added first
	dup -> focuser.ID
	dup EAFFocuserInfo ( ID buffer) EAFGetProperty EAF.?abort
	dup EAFSN EAFGetSerialNumber EAF.?ABORT 
;

: remove-focuser ( FocuserID --)
\ disconnect the focuser, it becomes unavailable to the application
	EAFClose EAF.?abort
;

: scan-focusers ( -- )
\ scan the plugged-in focusers
\ create a CONSTANT (out of the name and S/N) for each FocuserID
	EAFGetNum ( -- n)
	?dup
	IF
		\ loop over each connected focuser
		CR ." ID" tab ." Focuser" tab tab ." S/N" tab tab ." Handle" CR
		0 do
			i EAFID ( index buffer) EAFGetID  EAF.?abort
			EAFID @												( ID)
			dup . -> focuser.ID
			focuser.ID EAFOpen EAF.?abort
			focuser.ID EAFFocuserInfo ( ID buffer) EAFGetProperty EAF.?abort
			focuser_name tab type focuser_SN tab type		
			focuser.ID EAFClose EAF.?abort		
			focuser.ID EAF.make-handle						( ID c-addr u)
			2dup tab type CR									( ID c-addr u)
			($constant)											( --)
		loop
	ELSE
		CR ." No connected focusers" CR
	THEN
;

\ convenience functions

: what-focuser? ( --)
\ report the current focser to the user
\ WheelID Name SerialNo Slots
	CR ." ID" 		focuser.ID tab tab .	
	CR ." Name" 	focuser_SN tab tab type
	CR ." Reverse?"	focuser_reverse tab . CR
	CR CR
;