\ utilities and helper functions to conveniently operate the EAF SDK
\ requires EAF_SDK.f

\ Lexicon conventions
\ 	EAF.word

\ Operational notes
\ 	variables over values

: despace ( c-addr u --)
\ convert spaces to underscore characters
	over + swap do
		i c@ BL = if '_' i c! then	
	loop
;

: EAF.make-handle ( -- c-addr u)
\ prepare a handle for the focuser based on name and serial number
\ assumes EFWGetProperty and EFWGetSerialNumber have been called
	base @ >R hex	\ s/n in hexadecimal
	EAFSN w@(n) 0 
	<# # # # #  	\ first 4 digits only 
	'_' HOLD			\ separator
	EAFFocuserInfo EAF_FOCUSER_NAME zcount HOLDS
	#> 
	R> base !
;
 
0 value focuser.ID 
\ the EAF FocuserID of the presently selected focuser