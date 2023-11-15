// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DailyCheckIn} from "../src/DailyCheckIn.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {console} from "forge-std/console.sol";

contract DeployDailyCheckIn is Script {
    constructor() {}

    function run() external returns (DailyCheckIn, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (uint256 checkInTimeInterval, uint256 deployerKey,) = helperConfig.activeNetworkConfig();

        // console.log(deployerKey);

        vm.startBroadcast(deployerKey);
        DailyCheckIn dailyCheckIn = new DailyCheckIn(checkInTimeInterval);
        vm.stopBroadcast();

        return (dailyCheckIn, helperConfig);
    }
}
