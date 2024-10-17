// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIntellModelNFT {
    function modelNFTMintedHistory(uint256 _modelId) external view returns(uint256);
    function modelIdByTokenId(uint256 _tokenId) external view returns(uint256);
    function tokenIdByModelId(uint256 _modelId) external view returns(uint256);
    function getPause() external view returns (bool);
    function paymentToken() external view returns (IERC20);
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
}

