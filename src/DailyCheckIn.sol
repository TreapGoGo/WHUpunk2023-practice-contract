// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console} from "forge-std/console.sol";

pragma solidity ^0.8.18;

contract DailyCheckIn is Ownable {
    /* Errors */
    error DailyCheckIn__NotEnoughTimeHasPassed(uint256 timeUntilNextCheckIn);

    /* State Variables */
    uint256 public immutable i_checkInTimeInterval;
    mapping(address => uint256) s_addressToCheckInTimes;
    mapping(address => uint256) s_addressToLastCheckInTimestamp;

    /* Events */
    event CheckInSuccess(
        address indexed userAddress, uint256 indexed checkInTimestamp, uint256 indexed nowCheckInTimes
    );

    /* Modifiers */
    modifier enoughTimeHasPassed() {
        uint256 lastCheckInTimestamp = s_addressToLastCheckInTimestamp[msg.sender];
        if (block.timestamp - lastCheckInTimestamp < i_checkInTimeInterval) {
            revert DailyCheckIn__NotEnoughTimeHasPassed(lastCheckInTimestamp + i_checkInTimeInterval - block.timestamp);
        }
        _;
    }

    /* Functions */
    constructor(uint256 _chekInTimeInterval) Ownable(msg.sender) {
        i_checkInTimeInterval = _chekInTimeInterval;
    }

    function checkIn() public enoughTimeHasPassed {
        s_addressToCheckInTimes[msg.sender]++;
        s_addressToLastCheckInTimestamp[msg.sender] = block.timestamp;

        emit CheckInSuccess(msg.sender, block.timestamp, s_addressToCheckInTimes[msg.sender]);
        // console.log(msg.sender, block.timestamp, s_addressToCheckInTimes[msg.sender]);
        // console.log("checkInSuccess", msg.sender, block.timestamp, addressToCheckInTimes[msg.sender]);
    }

    /* View Functions */

    function getCheckInTimeIntervavl() public view returns (uint256) {
        return i_checkInTimeInterval;
    }

    function getCheckInTimesWithAddress(address _address) public view returns (uint256) {
        return s_addressToCheckInTimes[_address];
    }

    function getLastCheckInTimestampWithAddress(address _address) public view returns (uint256) {
        return s_addressToLastCheckInTimestamp[_address];
    }
}
