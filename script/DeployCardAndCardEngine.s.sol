// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Card} from "../src/Card.sol";
import {CardEngine} from "../src/CardEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployCardAndCardEngine is Script {
    constructor() {}

    function run() external returns (Card, CardEngine, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            uint256 mintTimeInterval,
            uint256 deployerKey,
            ,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link
        ) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator, deployerKey);

            //Fund it!
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinator, subscriptionId, link, deployerKey);
        }

        string[] memory cardUriArray = getCardUriArray();

        vm.startBroadcast(deployerKey);

        CardEngine cardEngine =
            new CardEngine(cardUriArray, mintTimeInterval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit);
        Card card = new Card(address(cardEngine));

        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(cardEngine), vrfCoordinator, subscriptionId, deployerKey);
        return (card, cardEngine, helperConfig);
    }

    function getCardUriArray() public view returns (string[] memory) {
        string[] memory cardUriArray = new string[](16);
        string[3] memory param0 = ["A", "B", "C"];
        string[3] memory param1 = ["a", "b", "c"];
        string[6] memory param2 = ["1", "2", "3", "4", "5", "6"];

        for (uint256 i = 0; i < cardUriArray.length; i++) {
            string memory parameter0 = param0[i / 6];
            string memory parameter1 = param1[i / 6];
            string memory parameter2 = param2[i % 6];
            string memory svgPath =
                string(abi.encodePacked("./images/", parameter0, "/", parameter1, parameter2, ".svg"));
            string memory svg = vm.readFile(svgPath);
            cardUriArray[i] = svgToImageURI(svg);
        }
        return cardUriArray;
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
