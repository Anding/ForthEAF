# ForthEAF
Forth control of the ZWO electronic focuser controller

Metadata uses ForthBase's `NEED ordered-maps` string maps.
`ForthFocuserMaps_test2.f` checks metadata and map reuse without hardware;
`ForthFocuserMaps_test1.f` remains a hardware example.

Ordinary SDK errors report and return normally; `EAF.?abort` retains its name
but does not abort. Failed reads return initialized zero values. A failed
readiness query prevents a focus move; attachment and scans stop at the failed
step. The caller can retry on its next iteration.
`ForthFocuser_test1.f` checks reporting and skipped moves with SDK mocks and no hardware.
`focus-at` uses the common readiness wait and reports its final position
rather than constructing continuous progress strings.
