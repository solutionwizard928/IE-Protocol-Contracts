// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
interface IShareERC721 {
    function MAX_TOTAL_SUPPLY() external view returns (uint256);

    function MAX_MINT_PER_ADDR() external view returns (uint256);

    function MAX_MINT_PER_TX() external view returns (uint256);

    function INTELL_MODEL_NFT_TOKEN_ID() external view returns (uint256);

    function INTELL_MODEL_NFT_CONTRACT_ADDR() external view returns (address);

    function MINT_PRICE() external view returns (uint256);

    function PAYMENT_TOKEN_ADDR() external view returns (address);

    function LAUNCH_END_TIME() external view returns (uint256);

    function FOR_ONLY_US_INVESTOR() external view returns(bool);
    
    function WITHDRAWN() external view returns(bool);

    function BLOCKED() external view returns(bool);

    function launch(bytes calldata _data, uint256 _INTELL_MODEL_NFT_TOKEN_ID) external;

    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory);
}