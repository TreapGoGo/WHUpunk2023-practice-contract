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

pragma solidity ^0.8.18;

contract DailyCheckIn is Ownable {
    /* Errors */
    error DailyCheckIn__NotEnoughTimeHasPassed(uint256 timeUntilNextCheckIn);

    /* State Variables */
    uint256 public immutable checkInTimeInterval;
    mapping(address => uint256) addressToCheckInTimes;
    mapping(address => uint256) addressToLastCheckInTimestamp;

    /* Events */
    event checkInSuccess(address indexed userAddress, uint256 indexed checkInTimestamp, uint256 nowCheckInTimes);

    /* Modifiers */
    modifier enoughTimeHasPassed() {
        uint256 lastCheckInTimestamp = addressToLastCheckInTimestamp[msg.sender];
        if (block.timestamp - lastCheckInTimestamp < checkInTimeInterval) {
            revert DailyCheckIn__NotEnoughTimeHasPassed(lastCheckInTimestamp + checkInTimeInterval - block.timestamp);
        }
        _;
    }

    /* Functions */
    constructor(uint256 _chekInTimeInterval) Ownable(msg.sender) {
        checkInTimeInterval = _chekInTimeInterval;
    }

    function checkIn() public enoughTimeHasPassed {
        addressToCheckInTimes[msg.sender]++;
        addressToLastCheckInTimestamp[msg.sender] = block.timestamp;

        emit checkInSuccess(msg.sender, block.timestamp, addressToCheckInTimes[msg.sender]);
    }
}
