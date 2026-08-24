# EmissionsMRV — Remix VM test matrix (15 Aug 2026)
Environment: Remix VM (Cancun) · Contract deployed by Account 0 (owner/regulator)
Roles: Acc0 = regulator · Acc1 (0xAb8…5cb2) = authorised reporter · Acc2 (0x4B2…C02db) = attacker

| # | Test | Caller | Expected | Result |
|---|------|--------|----------|--------|
| 1 | registerFacility("Plant A","Johannesburg") | Owner | Success, ID 1, FacilityRegistered | PASS (gas 140,997) |
| 2 | authoriseReporter(1, reporter) | Owner | Success, ReporterAuthorised | PASS (gas 50,541) |
| 3 | submitRecord(1, real hash, "2026-07", 1250) | Reporter | Success, index 0, EmissionRecorded | PASS (gas 194,540) |
| 4 | getRecordCount / getRecord / verifyReport(correct) | Anyone | 1 / record / true | PASS |
| 5 | verifyReport(wrong hash) | Anyone | false | PASS |
| 6 | registerFacility | Attacker | Revert "Only the regulator may call this" | PASS |
| 7 | submitRecord | Attacker | Revert "Not an authorised reporter..." | PASS |
| 8 | submitRecord same period again | Reporter | Revert "Period already reported..." | PASS |
| 9 | submitRecord zero hash | Reporter | Revert "Report hash required" | PASS |
| 10 | submitRecord facility 99 | Reporter | Revert (modifier fires first) | PASS |
| 11 | submitRecord amendment for 2026-07 | Reporter | Success, index 1, count = 2 | PASS |