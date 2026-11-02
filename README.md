# ForthEAF

`eaf.error.code` and `.timestamp` retain the latest nonzero SDK result until
application acknowledgement; success does not clear them. Timestamps are
ForthBase UTC Unix epoch seconds. `EAF.reopen?` accepts removed (4),
error-state (6) and closed (9), not invalid values, moving or unsupported
operations. Printers never reconnect; application idle policy owns recovery.

`configure-focuser` applies desired `focuser.default.reverse`, `.backlash`,
`.maxsteps` and `.position`. Hardware defaults are 0, 0, 60000 and 0;
the environment must select safe rig-specific values before configuring.
These are policy values, never hardware-state caches.
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
