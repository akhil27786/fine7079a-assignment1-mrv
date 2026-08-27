# EmissionsMRV — Blockchain MRV System for GHG Emissions
FINE7079A Assignment 1 (2026) · Akhil Choubae · Student number 687823

A Solidity smart contract implementing a Monitoring, Reporting and Verification (MRV)
registry for greenhouse-gas emissions. The regulator (contract owner) registers
manufacturing facilities and authorises reporters; authorised reporters submit the
SHA-256 hash of each emissions report; anyone can verify a report against the chain
via open read functions. There are no update or delete functions — corrections are
appended as amendment records.

## Repository contents
- `contracts/EmissionsMRV.sol` — the smart contract (pragma ^0.8.26)
- `deployment.md` — deployment record (network, address, transaction hash, demo transactions)
- `test-notes.md` — 11-test matrix run in Remix VM (three roles incl. attacker)
- `screenshots/` — deployment and demonstration evidence
- `emissions_report_2026-07.txt` — sample off-chain report used for the hash demonstrations

## How to compile and deploy locally
npm install
npx hardhat compile
npx hardhat node # terminal 1: local blockchain (chain ID 31337)
npx hardhat console --network localhost # terminal 2
## In the console:
const { ethers } = await network.connect()
const c = await ethers.deployContract("EmissionsMRV")
await c.waitForDeployment()
await c.getAddress()

## Deployment (24 August 2026, per amended brief: local deployment)
- Network: Hardhat local node, chain ID 31337
- Contract address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
- Deployment transaction: 0xc144e9fef60264c7ae07951e6e7d10634baa64db40e76276161d14a26925544b

## Demonstration video
https://www.youtube.com/watch?v=qGip8_wfpBM

