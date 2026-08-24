# EmissionsMRV — Local Deployment Record

- Network: Hardhat local node (chain ID 31337), per Ulwazi announcement (local deployment)
- Contract address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
- Deployment transaction hash: 0xc144e9fef60264c7ae07951e6e7d10634baa64db40e76276161d14a26925544b
- Deployer / regulator: Account #0 — 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
- Reporter: Account #1 — 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
- Compiler: solc 0.8.28 (pragma ^0.8.26)
- Date: 24/08/2026

## Demonstration transactions
| Block | Action | Caller | Result |
|---|---|---|---|
| 2 | registerFacility("Plant A","Johannesburg") | Regulator | Success — gasUsed 140,997 |
| 3 | authoriseReporter(1, reporter) | Regulator | Success |
| 4 | submitRecord(1, SHA-256 hash, "2026-07", 1250) | Reporter | Success — index 0 |
| — | getRecordCount(1) / verifyReport(correct hash) | open read | 1 / true |
| — | registerFacility by unauthorised account | Attacker | REVERTED: "Only the regulator may call this" |
