// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Card is ERC721, Ownable {
    uint256 private s_tokenCounter;
    mapping(uint256 => string) public s_tokenIdToUri;
    mapping(uint256 => uint256) public s_tokenIdToSerialNumber;

    // mapping(address => uint256) private s_lastMintTimestamp;

    constructor(address engineAddress) ERC721("WHUPunk Testnet Cards", "CARD") Ownable(engineAddress) {
        s_tokenCounter = 0;
    }

    function mintNft(address recipient, string memory tokenUri, uint256 serialNumber) public onlyOwner {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        s_tokenIdToSerialNumber[s_tokenCounter] = serialNumber;
        _safeMint(recipient, s_tokenCounter);
        s_tokenCounter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenIdToUri[tokenId];
    }

    function tokenSerialNumber(uint256 tokenId) public view returns (uint256) {
        return s_tokenIdToSerialNumber[tokenId];
    }

    function addressBalance(address user) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](s_tokenCounter);
        uint256 counter = 0;
        for (uint256 tokenId = 0; tokenId < s_tokenCounter; tokenId++) {
            if (_ownerOf(tokenId) == user) {
                result[counter] = tokenSerialNumber(tokenId);
                counter++;
            }
        }
        return result;
    }
}
