\ Forth lexicon for controlling a focuser
\ 	ZWO EAF version
\ 	ordinary errors report and return to the caller

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

: focuser-motion? { | moving handcontrol -- moving? valid? }
	0 -> moving 0 -> handcontrol
	focuser.ID ADDR moving ADDR handcontrol EAFIsMoving
	dup 5 = if drop -1 -1 exit then
	?dup if EAF.?abort 0 0 exit then
	ADDR moving c@ -1 \ Some SDK versions write a byte boolean.
;

: focuser_moving ( -- flag )
	focuser-motion? drop
;

: (wait-focuser) ( -- ready? )
\ synchronous hold until the focuser stops moving
	begin
	    100 ms
		focuser-motion? 0= if drop 0 exit then
	0= until
	-1
;

: wait-focuser ( --)
	(wait-focuser) drop
;

: EAF.getter ( xt "name" --)
	create ,
	does> { | n -- n }
		0 -> n
		focuser.ID ADDR n rot @ execute
		?dup if EAF.?abort 0 else n then
;

: EAF.setter ( xt "name" --)
	create ,
	does> @ focuser.ID -rot execute EAF.?abort
;

' EAFGetPosition EAF.getter focuser_position
' EAFGetBacklash EAF.getter focuser_backlash
' EAFGetMaxStep EAF.getter focuser_maxsteps
' EAFGetReverse EAF.getter focuser_reverse
' EAFGetBeep EAF.getter focuser_beeping
' EAFStepRange EAF.getter focuser_steprange
' EAFMove EAF.setter ->focuser_position
' EAFSetBacklash EAF.setter ->focuser_backlash
' EAFSetMaxStep EAF.setter ->focuser_maxsteps
' EAFSetReverse EAF.setter ->focuser_reverse
' EAFSetBeep EAF.setter ->focuser_beeping

: focuser_temp { | temp } ( -- temp) \ VFX locals for pass-by-reference 
	0 -> temp
	focuser.ID ADDR temp EAFGetTemp ?dup if EAF.?abort 0 exit then
	ADDR temp sf@ fr>s
;

: focuser_stop ( -- ior)
	focuser.ID EAFStop dup EAF.?abort
;

: add-focuser ( FocuserID --)
\ make a focuser available for application use
\ 	connect the focuser and read its properties
    EAFGetNum 0= if drop s" no connected focusers" .E> exit then
	dup EAFOpen ?dup if EAF.?abort drop exit then
	500 ms
	dup EAFFocuserInfo EAFGetProperty ?dup if
		EAF.?abort EAFClose EAF.?abort exit
	then
	drop
;

: use-focuser ( FocuserID --)
\ choose the focuser to be selected for operations - must be added first
	-> focuser.ID
	focuser.ID EAFFocuserInfo EAFGetProperty ?dup if EAF.?abort exit then
	focuser.ID EAFSN EAFGetSerialNumber ?dup if EAF.?abort exit then
	focuser_name $-> eaf.str1 s"  at position " $+> eaf.str1
	focuser_position (.) $+> eaf.str1
	eaf.str1 .>
;

: remove-focuser ( FocuserID --)
\ disconnect the focuser, it becomes unavailable to the application
    (wait-focuser) drop
	EAFClose EAF.?abort
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
			0 EAFFocuserID !
			i EAFFocuserID EAFGetID ?dup if EAF.?abort unloop exit then
			EAFFocuserID @										( ID)
			dup -> focuser.ID .
			focuser.ID EAFOpen ?dup if EAF.?abort unloop exit then
			focuser.ID EAFFocuserInfo EAFGetProperty ?dup if
				EAF.?abort focuser.ID EAFClose EAF.?abort unloop exit
			then
			focuser.ID EAFSN EAFGetSerialNumber ?dup if
				EAF.?abort focuser.ID EAFClose EAF.?abort unloop exit
			then
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
\ report the current focuser state to the user
	focuser.ID EAFFocuserInfo EAFGetProperty ?dup if EAF.?abort exit then
	s" Focuser" panel{
	s" ID" focuser.ID (.) .field
	s" Name" focuser_name .field
	s" Position" focuser_position (.) .field
	s" Moving" focuser_moving (.) .field
	s" Backlash" focuser_backlash (.) .field
	s" Reverse" focuser_reverse (.) .field
	s" Maximum" focuser_maxsteps (.) .field
	s" Temperature (C)" focuser_temp (.) .field
	}panel
;

: focus-at ( pos --)
\ Move to an absolute position and report the resulting position in steps.
	(wait-focuser) 0= if drop exit then
	focuser.ID swap EAFMove ?dup if EAF.?abort exit then
	(wait-focuser) if
		s" Focuser position: " $-> eaf.str1
		focuser_position (.) $+> eaf.str1
		s"  steps" $+> eaf.str1
		eaf.str1 .>
	then
;

: focus? ( -- pos)
    focuser_position (.) .>
;	