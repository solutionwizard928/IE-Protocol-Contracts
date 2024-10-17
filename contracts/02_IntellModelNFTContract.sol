// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interface/IIntellModelNFT.sol";
import "./interface/IIntellSetting.sol";
import "./interface/IFactory.sol";

contract IntellModelNFTContract is
    ERC721Enumerable,
    ReentrancyGuard,
    IIntellModelNFT,
    Ownable
{
    using Strings for uint256;
    using SafeMath for uint256;

    string _baseTokenURI;
    bool private _paused = false;
    mapping(uint256 => uint256) private _modelNFTMintedHistory;
    mapping(uint256 => uint256) private _modelIdByTokenId;
    mapping(uint256 => uint256) private _tokenIdByModelId;

    IIntellSetting private _intellSetting;

    event UpdateMintPrice(uint256 oldMintPrice, uint256 newMintPrice);
    event UpdatePause(bool oldVal, bool newVal);
    event UpdatePaymentToken(address oldPaymentToken, address newPaymentToken);
    event NewModelMint(
        address creator,
        uint256 price,
        uint256 tokenId,
        uint256 modelId,
        uint256 timestamp,
        uint256 blocknumber
    );

    constructor(string memory baseURI, IIntellSetting _intellSetting_)
        ERC721("IntellModelNFT", "IMN")
    {
        setBaseURI(baseURI);
        _intellSetting = _intellSetting_;
    }

    modifier onlyAdmin() {
        require(
            _intellSetting.admin() == _msgSender(),
            "Ownable: caller is not the admin"
        );
        _;
    }

    function modelIdByTokenId(uint256 _tokenId)
        external
        view
        override
        returns (uint256)
    {
        return _modelIdByTokenId[_tokenId];
    }

    function setIntellSetting(IIntellSetting _intellSetting_)
        external
        onlyOwner
    {
        _intellSetting = _intellSetting_;
    }

    function intellSetting() external view returns (IIntellSetting) {
        return _intellSetting;
    }

    function tokenIdByModelId(uint256 _modelId)
        external
        view
        override
        returns (uint256)
    {
        return _tokenIdByModelId[_modelId];
    }

    function modelNFTMintedHistory(uint256 _modelId)
        external
        view
        override
        returns (uint256)
    {
        return _modelNFTMintedHistory[_modelId];
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function pause(bool val) public onlyOwner {
        require(_paused != val, "NEW STATE IDENTICAL TO OLD STATE");
        emit UpdatePause(_paused, val);
        _paused = val;
    }

    function getPause() public view override returns (bool) {
        return _paused;
    }

    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: CALLER IS NOT TOKEN OWNER OR APPROVED"
        );
        _burn(tokenId);
    }

    function paymentToken() public view override returns (IERC20) {
        return IERC20(_intellSetting.intellTokenAddr());
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        bytes32 messageDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        return ECDSA.recover(messageDigest, signature);
    }

    function verifyMessage(bytes memory message, bytes memory signature)
        internal
        view
        returns (bool)
    {
        bytes32 hash = keccak256(message);
        return recoverSigner(hash, signature) == _intellSetting.truthHolder();
    }

    function checkStatus(bytes calldata statusMessage)
        internal
        view
        returns (bool)
    {
        (
            uint256 _MODEL_ID,
            ,
            uint256 _MODEL_PROGRESS_STATUS,
            address _USER_ADDR,
            address _INTELL_MODEL_NFT_CONTRACT_ADDR,
            bool _VERIFIED_AS_CREATOR,
            bool _USER_SUSPENDED,
            bool _MODEL_UPLOADED
        ) = abi.decode(
                statusMessage,
                (uint256, bool, uint256, address, address, bool, bool, bool)
            );

        require(_USER_ADDR == msg.sender && msg.sender == tx.origin, "NO BOT");
        require(
            _VERIFIED_AS_CREATOR &&
                address(this) == _INTELL_MODEL_NFT_CONTRACT_ADDR &&
                !_USER_SUSPENDED &&
                _MODEL_UPLOADED &&
                _MODEL_PROGRESS_STATUS > 9,
            "THIS IS REQUIRED VALID"
        );

        require(
            _tokenIdByModelId[_MODEL_ID] == 0 && _MODEL_ID > 0,
            "ALREADY MODEL ID MINTED."
        );
        require(!_paused, "SALE IS NOT ACTIVE CURRENTLY.");

        return true;
    }

    function adopt(
        bytes calldata statusMessage,
        bytes calldata statusSignature,
        bytes calldata shareMessage,
        bytes calldata shareSignature
    ) external nonReentrant {
        require(
            address(paymentToken()) != address(0),
            "SET PAYMENT TOKEN IN INTELLSETTING"
        );

        require(
            _intellSetting.factoryContractAddr() != address(0),
            "MUST SET FACTORY ADDRESS IN INTELL SETTING"
        );

        uint256 nextTokenId = totalSupply() + 1;

        require(
            verifyMessage(statusMessage, statusSignature) &&
                verifyMessage(shareMessage, shareSignature),
            "ONLY ACCEPT TRUTHHOLDER SIGNED MESSAGE"
        );

        (uint256 _MODEL_ID, bool _HAS_SHARE) = abi.decode(
            statusMessage,
            (uint256, bool)
        );

        require(checkStatus(statusMessage), "THE STATUS IS INVALID");

        _tokenIdByModelId[_MODEL_ID] = nextTokenId;
        _modelIdByTokenId[nextTokenId] = _MODEL_ID;

        _modelNFTMintedHistory[_MODEL_ID] = block.number;

        _safeMint(msg.sender, nextTokenId);

        uint256 paymentTokenAmount = _intellSetting.modelLaunchPrice();

        if (_HAS_SHARE) {
            paymentTokenAmount += _intellSetting.shareNFTLaunchPrice();
            IFactory(_intellSetting.factoryContractAddr())
                .createShareNFTContract(shareMessage, nextTokenId);
        }

        require(
            paymentToken().balanceOf(msg.sender) >= paymentTokenAmount,
            "THE ERC20 TOKEN AMOUNT SENT IS NOT CORRECT OR INSUFFIENT ERC20 TOKEN AMOUNT SENT."
        );

        paymentToken().transferFrom(
            msg.sender,
            address(this),
            paymentTokenAmount
        );

        emit NewModelMint(
            msg.sender,
            paymentTokenAmount,
            nextTokenId,
            _MODEL_ID,
            block.timestamp,
            block.number
        );
    }

    function walletOfOwner(address _owner)
        public
        view
        override
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function withdraw() external onlyAdmin {
        paymentToken().transfer(
            _msgSender(),
            paymentToken().balanceOf(address(this))
        );
    }
}
