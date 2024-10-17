// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";

// import "./interface/IIntellSetting.sol";
// import "./interface/IShareERC721.sol";
// import "./interface/IFactory.sol";
// import "./IntellShareNFTContract.sol";

// pragma experimental ABIEncoderV2;

// contract IntellFactoryContract is IFactory, Ownable {
//     // using Strings for uint256;
//     // using SafeMath for uint256;

//     bytes32 public constant INIT_CODE_PAIR_HASH =
//         keccak256(abi.encodePacked(type(IntellShareNFTContract).creationCode));

//     mapping(uint256 => address) public override getShareNFTAddr;
//     address[] public override allShareNFTAddrs;
//     IIntellSetting private _intellSetting;

//     mapping(address => bool) public enablePaymentTokenAddrs;

//     constructor(IIntellSetting _intellSetting_, address _intellTokenAddr_) {
//         _intellSetting = _intellSetting_;
//         enablePaymentTokenAddrs[_intellTokenAddr_] = true;
//     }

//     modifier onlyCreator() {
//         require(
//             _intellSetting.intellModelNFTContractAddr() == msg.sender &&
//                 msg.sender != tx.origin,
//             "Ownable: caller is not the creator"
//         );
//         _;
//     }

//     function setEnablePaymentTokenAddrs(
//         address _newPaymentToken,
//         bool enable
//     ) external onlyOwner {
//         enablePaymentTokenAddrs[_newPaymentToken] = enable;
//     }

//     function intellSetting() external view returns (IIntellSetting) {
//         return _intellSetting;
//     }

//     function setIntellSetting(
//         IIntellSetting _intellSetting_
//     ) external onlyOwner {
//         _intellSetting = _intellSetting_;
//     }

//     function shareLaunchPrice() public view returns (uint256) {
//         return _intellSetting.shareNFTLaunchPrice();
//     }

//     function allShareNFTAddrsLength() external view override returns (uint256) {
//         return allShareNFTAddrs.length;
//     }

//     function recoverSigner(
//         bytes32 hash,
//         bytes memory signature
//     ) internal pure returns (address) {
//         bytes32 messageDigest = keccak256(
//             abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
//         );
//         return ECDSA.recover(messageDigest, signature);
//     }

//     function verifyMessage(
//         bytes memory message,
//         bytes memory signature
//     ) internal view returns (bool) {
//         bytes32 hash = keccak256(message);
//         return recoverSigner(hash, signature) == _intellSetting.truthHolder();
//     }

//     function createShareNFTContract(
//         bytes memory shareMessage,
//         uint256 _INTELL_MODEL_NFT_TOKEN_ID
//     ) external override onlyCreator {
//         (
//             address _PAYMENT_TOKEN_ADDR,
//             string memory _NAME,
//             string memory _SYMBOL
//         ) = abi.decode(shareMessage, (address, string, string));

//         require(
//             enablePaymentTokenAddrs[_PAYMENT_TOKEN_ADDR],
//             "DISABLED THIS PAYMENT TOKEN"
//         );

//         require(
//             _intellSetting.intellModelNFTContractAddr() != address(0),
//             "NEEDS TO SENT SMART INTEGLLIGENCE EXCHANGE NFT CONTRACT ADDRESS"
//         );

//         require(
//             getShareNFTAddr[_INTELL_MODEL_NFT_TOKEN_ID] == address(0),
//             "THE INTELLIGENCE EXCHANGE: SHARE_NFT_EXISTS"
//         );

//         require(
//             bytes(_NAME).length > 0 && bytes(_SYMBOL).length > 0,
//             "THE NAME & SYMBOL IS INVALID"
//         );

//         IntellShareNFTContract intellShare = new IntellShareNFTContract(
//             _NAME,
//             _SYMBOL,
//             _intellSetting
//         );

//         intellShare.launch(shareMessage, _INTELL_MODEL_NFT_TOKEN_ID);

//         emit InvestorNFTCreated(
//             _INTELL_MODEL_NFT_TOKEN_ID,
//             address(intellShare)
//         );

//         getShareNFTAddr[_INTELL_MODEL_NFT_TOKEN_ID] = address(intellShare);
//         allShareNFTAddrs.push(address(intellShare));
//     }

// }
