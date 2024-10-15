\ test for EAF_SDK.f

include "%idir%\..\ForthBase\libraries\libraries.f"
NEED network

include "%idir%\EAF_SDK.f"
include "%idir%\EAF_SDK_extend.f"
CR	
\ check DLL and extern status
." EAF_focuser.dll load address " EAF_focuser.dll u. CR
.BadExterns CR