// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {NftSimulator} from "../src/NftSimulator.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {console} from "forge-std/console.sol";

contract DeployNftSimulator is Script {
    constructor() {}

    string[] private imageCidArray = [
        "bafkreiea5zrtir57ermhs4563uonmebrprpqlug7sr4bwiompgkjtfu4ea",
        "bafybeie3no7ogx2d7dxgd2lk5jcbmsfmsf6mv2fk5f455jssq2wmuvkrhi",
        "bafybeigoneny7nnvzc6gljfystlphatdzzlxncu6ugpjtpq27z26abob2m",
        "bafkreibeu3fcqug4uh3r7d6au3w5lebru3mo5jrgol2i33vqndhemvotkm",
        "bafybeidk7mm3u4uxjjo4apc2ncdkauzhus6sh2hpuhddh3wcj6tlhn7bya",
        "bafkreidj52mn2whijo27cy4o75zgidjrrlsabawonkd4ez3xvhn2ijentq",
        "bafybeiceglt6ha36vmjnkhjnbrcy453irho6wq37lzmzykqjxu4rye4owa",
        "bafkreieisu74sjyi2ipmhj3pjre6kbs25unwkp3pdubmn7psiopb3olu7m",
        "bafkreieops4zoprelypumcxoozdeurcdx3sr27mzadrqkxhxwlwni3em7i",
        "bafkreiaku73mqdqbvw7h2om242tdyvz6rdvaikbr4fw54a47nmotcsqgiy",
        "bafybeiapx3w2dndxjk6scmyjyhjyquegcpih5qqhwas6bawjhscv2zkrbi",
        "bafybeibvpg3kkur2xxtzeyzayvpt2l5lknn4slk5bt7zs2rm36sop7o424",
        "bafkreiexon3pn36avwpsfc555qy5qlwf5cfrj2hcxj6mgojexo2dlkrmsa",
        "bafybeid3qoiqgqjedc7os7j2bfxycacppzygsw4m5isuas3eoqm32hzohq",
        "bafybeiembni2gpv5u343zgtqsbeesss7ji76h2avatguhwdaedlq6g3qnq",
        "bafkreia6hhzc7vsff37dlwajwoeofhzggomqq2cp5mschdlzkl6wesrg7q",
        "bafybeigykuhviaqkfol5ul7jcqvf2wlah4dbjiihpdvm4pqchojlmoliy4",
        "bafkreibdvavbp5v5z6vylzjcevf6wrqh5bpr3txn6rkvoulfqylqyuqbtm",
        "bafkreibzx7gd7i53ckxbb3pkn6e6ruroemizp3uisehioh5uvq76vemy7m",
        "bafybeie3no7ogx2d7dxgd2lk5jcbmsfmsf6mv2fk5f455jssq2wmuvkrhi",
        "bafybeigoneny7nnvzc6gljfystlphatdzzlxncu6ugpjtpq27z26abob2m",
        "bafkreibeu3fcqug4uh3r7d6au3w5lebru3mo5jrgol2i33vqndhemvotkm",
        "bafybeidk7mm3u4uxjjo4apc2ncdkauzhus6sh2hpuhddh3wcj6tlhn7bya",
        "bafkreidj52mn2whijo27cy4o75zgidjrrlsabawonkd4ez3xvhn2ijentq",
        "bafybeiceglt6ha36vmjnkhjnbrcy453irho6wq37lzmzykqjxu4rye4owa",
        "bafkreieisu74sjyi2ipmhj3pjre6kbs25unwkp3pdubmn7psiopb3olu7m",
        "bafkreieops4zoprelypumcxoozdeurcdx3sr27mzadrqkxhxwlwni3em7i",
        "bafkreiaku73mqdqbvw7h2om242tdyvz6rdvaikbr4fw54a47nmotcsqgiy",
        "bafybeiapx3w2dndxjk6scmyjyhjyquegcpih5qqhwas6bawjhscv2zkrbi",
        "bafybeibvpg3kkur2xxtzeyzayvpt2l5lknn4slk5bt7zs2rm36sop7o424",
        "bafkreiexon3pn36avwpsfc555qy5qlwf5cfrj2hcxj6mgojexo2dlkrmsa",
        "bafybeid3qoiqgqjedc7os7j2bfxycacppzygsw4m5isuas3eoqm32hzohq",
        "bafybeiembni2gpv5u343zgtqsbeesss7ji76h2avatguhwdaedlq6g3qnq",
        "bafkreia6hhzc7vsff37dlwajwoeofhzggomqq2cp5mschdlzkl6wesrg7q",
        "bafybeigykuhviaqkfol5ul7jcqvf2wlah4dbjiihpdvm4pqchojlmoliy4",
        "bafkreibdvavbp5v5z6vylzjcevf6wrqh5bpr3txn6rkvoulfqylqyuqbtm",
        "bafkreibzx7gd7i53ckxbb3pkn6e6ruroemizp3uisehioh5uvq76vemy7m",
        "bafybeie3no7ogx2d7dxgd2lk5jcbmsfmsf6mv2fk5f455jssq2wmuvkrhi",
        "bafybeigoneny7nnvzc6gljfystlphatdzzlxncu6ugpjtpq27z26abob2m",
        "bafkreibeu3fcqug4uh3r7d6au3w5lebru3mo5jrgol2i33vqndhemvotkm",
        "bafybeidk7mm3u4uxjjo4apc2ncdkauzhus6sh2hpuhddh3wcj6tlhn7bya",
        "bafkreidj52mn2whijo27cy4o75zgidjrrlsabawonkd4ez3xvhn2ijentq",
        "bafybeiceglt6ha36vmjnkhjnbrcy453irho6wq37lzmzykqjxu4rye4owa",
        "bafkreieisu74sjyi2ipmhj3pjre6kbs25unwkp3pdubmn7psiopb3olu7m",
        "bafkreieops4zoprelypumcxoozdeurcdx3sr27mzadrqkxhxwlwni3em7i",
        "bafkreiaku73mqdqbvw7h2om242tdyvz6rdvaikbr4fw54a47nmotcsqgiy",
        "bafybeiapx3w2dndxjk6scmyjyhjyquegcpih5qqhwas6bawjhscv2zkrbi",
        "bafybeibvpg3kkur2xxtzeyzayvpt2l5lknn4slk5bt7zs2rm36sop7o424",
        "bafkreiexon3pn36avwpsfc555qy5qlwf5cfrj2hcxj6mgojexo2dlkrmsa",
        "bafybeid3qoiqgqjedc7os7j2bfxycacppzygsw4m5isuas3eoqm32hzohq",
        "bafybeiembni2gpv5u343zgtqsbeesss7ji76h2avatguhwdaedlq6g3qnq",
        "bafkreia6hhzc7vsff37dlwajwoeofhzggomqq2cp5mschdlzkl6wesrg7q",
        "bafybeigykuhviaqkfol5ul7jcqvf2wlah4dbjiihpdvm4pqchojlmoliy4",
        "bafkreibdvavbp5v5z6vylzjcevf6wrqh5bpr3txn6rkvoulfqylqyuqbtm",
        "bafkreibzx7gd7i53ckxbb3pkn6e6ruroemizp3uisehioh5uvq76vemy7m"
    ];

    string[] private imageUriArray;

    function run() external returns (NftSimulator) {
        HelperConfig helperConfig = new HelperConfig();
        (,, uint256 deployerKey,,,,,,) = helperConfig.activeNetworkConfig();
        getImageUriArray();

        vm.startBroadcast(deployerKey);
        NftSimulator nftSimulator = new NftSimulator(imageUriArray);
        // nftSimulator.mintNft();
        vm.stopBroadcast();

        // console.log(nftSimulator.tokenURI(0));

        return nftSimulator;
    }

    function getImageUriArray() public returns (string[] memory) {
        string memory prefix = "https://b9ba8146bdb8cc4835ce403b0cbb1887.ipfs.4everland.link/ipfs/";
        for (uint256 i = 0; i < imageCidArray.length; i++) {
            imageUriArray.push(string(bytes(abi.encodePacked(prefix, imageCidArray[i]))));
            console.log(string(bytes(abi.encodePacked(prefix, imageCidArray[i]))));
        }
        return imageUriArray;
    }
}
