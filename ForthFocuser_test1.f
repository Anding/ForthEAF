\ test for ForthFocuser.f

include "%idir%\..\ForthBase\ForthBase.f"
include "%idir%\EAF_SDK.f"
include "%idir%\EAF_SDK_extend.f"
include "%idir%\ForthFocuser.f"

CR	
\ check DLL and extern status
." EAF_focuser.dll load address " EAF_focuser.dll u. CR
.BadExterns CR
