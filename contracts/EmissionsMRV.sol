// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EmissionsMRV {

    // ----- Data structures -----

    struct Facility {
        string name;
        string location;
        bool active;
        uint256 registeredAt;
    }

    struct EmissionRecord {
        bytes32 reportHash;      // SHA-256 fingerprint of the off-chain emissions report
        string period;           // reporting period e.g. "2026-07"
        uint256 quantityTCO2e;   // reported emissions in tonnes of CO2 equivalent
        address reporter;        // wallet that submitted the record
        uint256 timestamp;       // block time at submission
        bool isAmendment;        // true if this record corrects an earlier one
        uint256 amendsIndex;     // index of the record being corrected
    }

    // ----- State variables -----

    address public owner;          // the regulator: deploys the contract and manages access
    uint256 public facilityCount;  // number of registered facilities, also used to issue IDs

    mapping(uint256 => Facility) public facilities;                          // facility ID => details
    mapping(uint256 => EmissionRecord[]) private records;                    // facility ID => its records
    mapping(uint256 => mapping(address => bool)) public authorisedReporters; // facility ID => wallet => may submit
    mapping(uint256 => mapping(string => bool)) private periodSubmitted;     // facility ID => period => reported

    // ----- Events -----

    event FacilityRegistered(uint256 indexed facilityId, string name);
    event ReporterAuthorised(uint256 indexed facilityId, address indexed reporter);
    event EmissionRecorded(uint256 indexed facilityId, uint256 index, bytes32 reportHash, string period, address indexed reporter);

    // ----- Access control -----

    // Only the regulator (deployer) may call
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the regulator may call this");
        _;
    }

    // Only a reporter authorised for this facility may call
    modifier onlyReporter(uint256 _facilityId) {
        require(authorisedReporters[_facilityId][msg.sender], "Not an authorised reporter for this facility");
        _;
    }

    // Runs once at deployment: the deploying address becomes the regulator
    constructor() {
        owner = msg.sender;
    }

    // ----- Write functions (paid transactions) -----

    // Regulator registers a new manufacturing facility and receives its ID
    function registerFacility(string memory _name, string memory _location) public onlyOwner returns (uint256) {
        require(bytes(_name).length > 0, "Facility name required");
        facilityCount = facilityCount + 1;
        facilities[facilityCount] = Facility(_name, _location, true, block.timestamp);
        emit FacilityRegistered(facilityCount, _name);
        return facilityCount;
    }

    // Regulator authorises a wallet to submit records for a facility
    function authoriseReporter(uint256 _facilityId, address _reporter) public onlyOwner {
        require(facilities[_facilityId].active, "Unknown or inactive facility");
        require(_reporter != address(0), "Reporter address required");
        authorisedReporters[_facilityId][_reporter] = true;
        emit ReporterAuthorised(_facilityId, _reporter);
    }

    // Authorised reporter submits the hash of an emissions report for a period
    function submitRecord(
        uint256 _facilityId,
        bytes32 _reportHash,
        string memory _period,
        uint256 _quantityTCO2e,
        bool _isAmendment,
        uint256 _amendsIndex
    ) public onlyReporter(_facilityId) returns (uint256) {
        require(facilities[_facilityId].active, "Unknown or inactive facility");
        require(_reportHash != bytes32(0), "Report hash required");
        require(bytes(_period).length > 0, "Reporting period required");
        if (_isAmendment) {
            require(_amendsIndex < records[_facilityId].length, "Amended record does not exist");
        } else {
            require(!periodSubmitted[_facilityId][_period], "Period already reported - submit an amendment");
        }
        records[_facilityId].push(EmissionRecord(_reportHash, _period, _quantityTCO2e, msg.sender, block.timestamp, _isAmendment, _amendsIndex));
        periodSubmitted[_facilityId][_period] = true;
        uint256 index = records[_facilityId].length - 1;
        emit EmissionRecorded(_facilityId, index, _reportHash, _period, msg.sender);
        return index;
    }

    // ----- Read functions (free calls, open to anyone) -----

    // Anyone may read a stored record for verification
    function getRecord(uint256 _facilityId, uint256 _index) public view returns (EmissionRecord memory) {
        require(_index < records[_facilityId].length, "Record does not exist");
        return records[_facilityId][_index];
    }

    // Number of records held for a facility
    function getRecordCount(uint256 _facilityId) public view returns (uint256) {
        return records[_facilityId].length;
    }

    // Auditor check: does this document hash match the record on chain?
    function verifyReport(uint256 _facilityId, uint256 _index, bytes32 _reportHash) public view returns (bool) {
        require(_index < records[_facilityId].length, "Record does not exist");
        return records[_facilityId][_index].reportHash == _reportHash;
    }
}