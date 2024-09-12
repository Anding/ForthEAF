\ Add FITS and XISF keywords to a map
\ 	ASI version

\ requires forthbase.f
\ requires EAF_SDK.f
\ requires EAF_SDK_extend.f
\ requires maps.fs
\ requires map-tools.fs

\ FITS keywords supported by MaxImDL
\ ==================================
\ FOCUSPOS – Focuser position in steps
\ FOCUSSSZ – Focuser step size in microns
\ FOCUSTEM – Focuser temperature readout in degrees C

\ FITS keywords defined here for the ZWO wheel
\ =============================================
\ FOCUSER	- name of the filter wheel
\ FOCUSERSN - wheel serial number

: add-focuserFITS ( map --)
\ add key value pairs for FITS wheel parameters
	>R
	focuser_position (.) R@ =>" WHEELPOS"
	focuser_temp (.)		R@ =>" FOCUSTEMP"
	." unknown"				R@ =>" FOCUSSZ"
	focuser_name			R@ =>" FOCUSER"
	focuser_SN				R@ =>" FOCUSERSN"
	R> drop
;	

	

