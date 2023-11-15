// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 checkInTimeInterval;
        uint256 deployerKey;
        bool onAnvil;
    }

    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
        // console.log("chainid: ", block.chainid);
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({checkInTimeInterval: 6 hours, deployerKey: vm.envUint("PRIVATE_KEY"), onAnvil: false});
    }

    function getAnvilEthConfig() public view returns (NetworkConfig memory) {
        if (activeNetworkConfig.checkInTimeInterval != 0) {
            return activeNetworkConfig;
        }
        return NetworkConfig({checkInTimeInterval: 10 seconds, deployerKey: DEFAULT_ANVIL_KEY, onAnvil: true});
    }
}
