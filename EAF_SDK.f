\ Forth words directly corresponding to the EAF SDK
                                            
LIBRARY: EAF_focuser.dll  
	
Extern: int "C" EAFClose( int FocuserID );
Extern: int "C" EAFGetBacklash( int FocuserID, int iStep );
Extern: int "C" EAFGetBeep( int FocuserID, int beeping );
Extern: int "C" EAFGetFirmwareVersion( int FocuserID, unsigned char * major, unsigned char * minor, unsigned char * build );
Extern: int "C" EAFGetID( int index, int * FocuserID  );
Extern: int "C" EAFGetMaxStep( int FocuserID, int * iStep );
Extern: int "C" EAFGetNum( );
Extern: int "C" EAFGetPosition( int FocuserID, int * iStep );
Extern: int "C" EAFGetProperty( int FocuserID, int * EAF_FOCUSER_INFO );
Extern: int "C" EAFGetReverse( int FocuserID, int reverse );
Extern: char * "C" EAFGetSDKVersion( );
Extern: int "C" EAFGetSerialNumber( int FocuserID, long * EAFSN );
Extern: int "C" EAFGetTemp( int FocuserID, float * temp );
Extern: int "C" EAFIsMoving( int FocuserID, int * moving, int * handControl );
Extern: int "C" EAFMove( int FocuserID, int iStep );
Extern: int "C" EAFOpen( int FocuserID );
Extern: int "C" EAFResetPostion( int FocuserID, int iStep );
Extern: int "C" EAFSetBacklash( int FocuserID, int iStep );
Extern: int "C" EAFSetBeep( int FocuserID, int beeping );
Extern: int "C" EAFSetID( int FocuserID, long EAFID );
Extern: int "C" EAFSetMaxStep( int FocuserID, int iStep );
Extern: int "C" EAFSetReverse( int ID, int reverse );
Extern: int "C" EAFStepRange( int FocuserID, int * iStep );
Extern: int "C" EAFStop( int FocuserID );

: EAF.Error ( n -- caddr u)
\ return the EFW text error message
	CASE
	 0 OF s" SUCCESS" ENDOF
	 1 OF s" INVALID_INDEX" ENDOF
	 2 OF s" INVALID_ID" ENDOF
	 3 OF s" INVALID_VALUE" ENDOF
	 4 OF s" REMOVED" ENDOF	
	 5 OF s" MOVING" ENDOF	
	 6 OF s" ERROR_STATE" ENDOF
	 7 OF s" GENERAL_ERROR" ENDOF
	 8 OF s" NOT_SUPPORTED" ENDOF
	 9 OF s" CLOSED" ENDOF
	s" OTHER_ERROR" rot 							( caddr u n)  \ ENDCASE consumes the case selector
	ENDCASE 
;

BEGIN-STRUCTURE EAF_FOCUSER_INFO
 4 +FIELD EAF_FOCUSER_ID
64 +FIELD EAF_FOCUSER_NAME
 4 +FIELD EAF_MAX_STEP
END-STRUCTURE

BEGIN-STRUCTURE EAF_ID				\ 8 bytes
  8 +FIELD EAF_ID_ID
END-STRUCTURE

\ pass by reference to ASI library functions
EAF_FOCUSER_INFO	BUFFER: EAFFocuserInfo
EAF_ID				BUFFER: EAFID
EAF_ID				BUFFER: EAFSN

\ do-or-die error handler
: EAF.?abort ( n --)
	flushKeys	
	dup 
	IF 
		EAF.Error type CR
		abort 
	ELSE
		drop	
	THEN
;