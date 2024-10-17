// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
    event InvestorNFTCreated(uint256 indexed tokenId, address investorNFT);

    function getShareNFTAddr(uint256 _tokenId)
        external
        view
        returns (address investorNFT);

    function allShareNFTAddrs(uint256) external view returns (address);

    function allShareNFTAddrsLength() external view returns (uint256);

    function createShareNFTContract(
        bytes memory shareMessage,
        uint256 _INTELL_MODEL_NFT_TOKEN_ID
    ) external;
}