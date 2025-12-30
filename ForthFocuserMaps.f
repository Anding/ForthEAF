\ Add FITS and XISF keywords to a map
\ 	ASI version


\ FITS keywords supported by MaxImDL
\ ==================================
\ FOCUSPOS – Focuser position in steps
\ FOCUSSSZ – Focuser step size in microns
\ FOCUSTEM – Focuser temperature readout in degrees C

\ FITS keywords defined here for the ZWO wheel
\ =============================================
\ FOCUSER	- name of the filter wheel
\ FOCUSERSN - wheel serial number

s" unknown" $value focuser.stepsize		\ micrometers per step

: add-focuserFITS ( map --)
\ add key value pairs for FITS wheel parameters
	>R
	s"  " 					R@ =>" #FOCUSER"		\ a header to indicate the source of these FITS values
	focuser_position (.) R@ =>" FOCUSPOS"
\ focuser_temp (.)		R@ =>" FOCUSTEMP"
	focuser.stepsize	R@ =>" FOCUSSZ"
	focuser_name			R@ =>" FOCUSER"
	focuser_SN				R@ =>" FOCUSERSN"
	R> drop
;	

	

