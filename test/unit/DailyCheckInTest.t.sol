// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DailyCheckIn} from "../../src/DailyCheckIn.sol";
import {DeployDailyCheckIn} from "../../script/DeployDailyCheckIn.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract DailyCheckInTest is Test {
    constructor() {}

    DailyCheckIn dailyCheckIn;
    HelperConfig helperConfig;
    bool onAnvil;

    address public USER = makeAddr("user");

    uint256 checkInTimeInterval;

    event checkInSuccess(address indexed userAddress, uint256 indexed checkInTimestamp, uint256 nowCheckInTimes);

    modifier timeWarpForOneYear() {
        if (onAnvil && block.timestamp <= 1000) {
            vm.warp(365 days);
        }
        _;
    }

    function setUp() public {
        DeployDailyCheckIn deployer = new DeployDailyCheckIn();
        (dailyCheckIn, helperConfig) = deployer.run();
        (checkInTimeInterval,, onAnvil) = helperConfig.activeNetworkConfig();
    }

    ///////////////////////////////
    // checkIn                   //
    ///////////////////////////////

    function testCanCheckInIfEnoughTimeHasPassed() public timeWarpForOneYear {
        vm.startPrank(USER);

        vm.expectEmit(true, true, true, false);
        emit checkInSuccess(USER, block.timestamp, 1);
        dailyCheckIn.checkIn();

        if (!onAnvil) {
            return;
        }

        vm.warp(block.timestamp + checkInTimeInterval);
        vm.expectEmit(true, true, true, false);
        emit checkInSuccess(USER, block.timestamp, 2);
        dailyCheckIn.checkIn();
    }

    function testCanRevertIfNotEnoughTimeHasPassed() public timeWarpForOneYear {
        vm.startPrank(USER);

        vm.expectEmit(true, true, true, false);
        emit checkInSuccess(USER, block.timestamp, 1);
        dailyCheckIn.checkIn();

        vm.expectRevert(
            abi.encodeWithSelector(DailyCheckIn.DailyCheckIn__NotEnoughTimeHasPassed.selector, checkInTimeInterval)
        );
        dailyCheckIn.checkIn();
    }
}
