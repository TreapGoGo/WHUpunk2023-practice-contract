// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 checkInTimeInterval;
        uint256 mintTimeInterval;
        uint256 deployerKey;
        bool onAnvil;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
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
        return NetworkConfig({
            checkInTimeInterval: 6 hours,
            mintTimeInterval: 3 hours,
            deployerKey: vm.envUint("PRIVATE_KEY"),
            onAnvil: false,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 7283,
            callbackGasLimit: 2500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.checkInTimeInterval != 0) {
            return activeNetworkConfig;
        }
        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoorinatorMock = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);
        LinkToken link = new LinkToken();
        vm.stopBroadcast();

        return NetworkConfig({
            checkInTimeInterval: 10 seconds,
            mintTimeInterval: 10 seconds,
            deployerKey: DEFAULT_ANVIL_KEY,
            onAnvil: true,
            vrfCoordinator: address(vrfCoorinatorMock),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callbackGasLimit: 500000,
            link: address(link)
        });
    }
}
