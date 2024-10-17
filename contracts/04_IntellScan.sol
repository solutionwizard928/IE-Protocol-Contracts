// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import "./interface/IShareERC721.sol";
import "./interface/IIntellModelNFT.sol";
import "./interface/IFactory.sol";
import "./interface/IIntellSetting.sol";

pragma experimental ABIEncoderV2;

interface IShareERC721InDetail is IERC721Enumerable, IShareERC721 {}
interface IIntellModelNFTInDetail is IERC721Enumerable, IIntellModelNFT {}

contract IntellScan is Ownable {
    using SafeMath for uint256;

    IIntellSetting private _intellSetting;

    constructor(IIntellSetting _intellSetting_) {
        _intellSetting = _intellSetting_;
    }

    function intellSetting() public view returns (IIntellSetting) {
        return _intellSetting;
    }

    function setIntelliSetting(
        IIntellSetting _intellSetting_
    ) external onlyOwner {
        _intellSetting = _intellSetting_;
    }

    function creatorNFT() public view returns (IIntellModelNFTInDetail) {
        return
            IIntellModelNFTInDetail(
                _intellSetting.intellModelNFTContractAddr()
            );
    }

    function factory() public view returns (IFactory) {
        return IFactory(_intellSetting.factoryContractAddr());
    }

    struct ModelMetadata {
        uint256 tokenId;
        uint256 modelId;
        string shareName;
        string shareSymbol;
        uint256 totalSupply;
        uint256 maxTotalSupply;
        uint256 mnpw;
        uint256 mnpt;
        uint256 sharePrice;
        address tokenAddr;
        uint256 withdrawAmount;
        address shareNFTAddr; // Share NFT Contract Address for the investors
        bool hasShareLaunched; // whether sNFT was launched or not
        bool forOnlyUS; // for only us investor
        uint256 endTime;
        bool finished;
        uint256 countdown;
        bool withdrawn;
        bool blocked;
    }

    struct ShareMetadata {
        uint256 shareId;
        uint256 tokenId;
        uint256 modelId;
        string shareName;
        string shareSymbol;
        uint256 totalSupply;
        uint256 maxTotalSupply;
        uint256 mnpw;
        uint256 mnpt;
        uint256 sharePrice;
        address tokenAddr;
        uint256 withdrawAmount;
        address shareNFTAddr; // Share NFT Contract Address for the investors
        bool hasShareLaunched; // whether sNFT was launched or not
        bool forOnlyUS; // for only us investor
        uint256 endTime;
        bool finished;
        uint256 countdown;
        bool withdrawn;
        bool blocked;
    }

    function creatorNFTCollectionDetail(
        address _owner
    ) external view returns (ModelMetadata[] memory) {
        uint256 tokenCount = creatorNFT().balanceOf(_owner);
        uint256[] memory tokenIds = creatorNFT().walletOfOwner(_owner);

        ModelMetadata[] memory creatorNFTCollections = new ModelMetadata[](
            tokenCount
        );

        for (uint256 i = 0; i < tokenCount; i++) {
            if (factory().getShareNFTAddr(tokenIds[i]) != address(0)) {
                address _shareNFTAddr = factory().getShareNFTAddr(tokenIds[i]);

                IShareERC721InDetail _shareNFT = IShareERC721InDetail(
                    _shareNFTAddr
                );
                IERC721Metadata _shareMetadataNFT = IERC721Metadata(
                    _shareNFTAddr
                );

                uint256 _endTime = _shareNFT.LAUNCH_END_TIME();

                creatorNFTCollections[i] = ModelMetadata(
                    tokenIds[i], // token id
                    creatorNFT().modelIdByTokenId(tokenIds[i]), // model id
                    _shareMetadataNFT.name(), // name
                    _shareMetadataNFT.symbol(), // symbol
                    _shareNFT.totalSupply(), // so far total supply minted
                    _shareNFT.MAX_TOTAL_SUPPLY(), // max total supply
                    _shareNFT.MAX_MINT_PER_ADDR(), // max number of share per wallet
                    _shareNFT.MAX_MINT_PER_TX(), // max number of share per tx
                    _shareNFT.MINT_PRICE(), // price per share
                    _shareNFT.PAYMENT_TOKEN_ADDR(), // payment token used in investment
                    IERC20(_shareNFT.PAYMENT_TOKEN_ADDR()).balanceOf(
                        _shareNFTAddr
                    ), // withdraw amount
                    _shareNFTAddr, // share nft token address
                    true, // whether cNFT has share nft or not
                    _shareNFT.FOR_ONLY_US_INVESTOR(), // for only us investor
                    _endTime,
                    _endTime < block.timestamp,
                    _endTime < block.timestamp ? 0 : _endTime - block.timestamp,
                    _shareNFT.WITHDRAWN(),
                    _shareNFT.BLOCKED()
                );
            } else {
                creatorNFTCollections[i] = ModelMetadata(
                    tokenIds[i], // token id
                    creatorNFT().modelIdByTokenId(tokenIds[i]), // model id
                    "_", // name
                    "_", // symbol
                    0, // so far total supply minted
                    0, // max total supply
                    0, // max number of share per wallet
                    0, // max number of share per tx
                    0, // price per share
                    address(0), // payment token used in investment
                    0, // withdraw amount
                    address(0), // share nft token address
                    false, // whether cNFT has share nft or not
                    false, // for only us investor
                    0,
                    true,
                    0,
                    false,
                    true
                );
            }
        }

        return creatorNFTCollections;
    }

    function singleCreatorNFTDetail(
        uint256 _tokenId
    ) external view returns (ModelMetadata memory) {

        if (factory().getShareNFTAddr(_tokenId) != address(0)) {
            address _shareNFTAddr = factory().getShareNFTAddr(_tokenId);
            IShareERC721InDetail _shareNFT = IShareERC721InDetail(
                _shareNFTAddr
            );
            IERC721Metadata _shareMetadataNFT = IERC721Metadata(_shareNFTAddr);

            uint256 _endTime = _shareNFT.LAUNCH_END_TIME();

            return
                ModelMetadata(
                    _tokenId, // token id
                    creatorNFT().modelIdByTokenId(_tokenId), // model id
                    _shareMetadataNFT.name(), // name
                    _shareMetadataNFT.symbol(), // symbol
                    _shareNFT.totalSupply(), // so far total supply minted
                    _shareNFT.MAX_TOTAL_SUPPLY(), // max total supply
                    _shareNFT.MAX_MINT_PER_ADDR(), // max number of share per wallet
                    _shareNFT.MAX_MINT_PER_TX(), // max number of share per tx
                    _shareNFT.MINT_PRICE(), // price per share
                    _shareNFT.PAYMENT_TOKEN_ADDR(), // payment token used in investment
                    IERC20(_shareNFT.PAYMENT_TOKEN_ADDR()).balanceOf(
                        _shareNFTAddr
                    ), // withdraw amount
                    _shareNFTAddr, // share nft token address
                    true, // whether cNFT has share nft or not
                    _shareNFT.FOR_ONLY_US_INVESTOR(), // for only us investor
                    _endTime,
                    _endTime < block.timestamp,
                    _endTime < block.timestamp ? 0 : _endTime - block.timestamp,
                    _shareNFT.WITHDRAWN(),
                    _shareNFT.BLOCKED()
                );
        } else {
            return
                ModelMetadata(
                    _tokenId, // token id
                    creatorNFT().modelIdByTokenId(_tokenId), // model id
                    "_", // name
                    "_", // symbol
                    0, // so far total supply minted
                    0, // max total supply
                    0, // max number of share per wallet
                    0, // max number of share per tx
                    0, // price per share
                    address(0), // payment token used in investment
                    0, // withdraw amount
                    address(0), // share nft token address
                    false, // whether cNFT has share nft or not
                    false, // for only us investor
                    0,
                    true,
                    0,
                    false,
                    true
                );
        }
    }

    function singleInvestmentChance(
        uint256 _index
    ) external view returns (ModelMetadata memory) {
        address _shareNFTAddr = factory().allShareNFTAddrs(_index);
        IShareERC721InDetail _shareNFT = IShareERC721InDetail(_shareNFTAddr);
        IERC721Metadata _shareMetadataNFT = IERC721Metadata(_shareNFTAddr);

        uint256 _tokenId = _shareNFT.INTELL_MODEL_NFT_TOKEN_ID();
        uint256 _endTime = _shareNFT.LAUNCH_END_TIME();

        return
            ModelMetadata(
                _tokenId, // token id
                creatorNFT().modelIdByTokenId(_tokenId), // model id
                _shareMetadataNFT.name(), // name
                _shareMetadataNFT.symbol(), // symbol
                _shareNFT.totalSupply(), // so far total supply minted
                _shareNFT.MAX_TOTAL_SUPPLY(), // max total supply
                _shareNFT.MAX_MINT_PER_ADDR(), // max number of share per wallet
                _shareNFT.MAX_MINT_PER_TX(), // max number of share per tx
                _shareNFT.MINT_PRICE(), // price per share
                _shareNFT.PAYMENT_TOKEN_ADDR(), // payment token used in investment
                IERC20(_shareNFT.PAYMENT_TOKEN_ADDR()).balanceOf(_shareNFTAddr), // withdraw amount
                _shareNFTAddr, // share nft token address
                true, // whether cNFT has share nft or not
                _shareNFT.FOR_ONLY_US_INVESTOR(), // for only us investor
                _endTime,
                _endTime < block.timestamp,
                _endTime < block.timestamp ? 0 : _endTime - block.timestamp,
                _shareNFT.WITHDRAWN(),
                _shareNFT.BLOCKED()
            );
    }

    function shareNFTCollectionDetail(
        address _owner,
        uint256 _index
    ) external view returns (ShareMetadata[] memory) {
        address _shareNFTAddr = factory().allShareNFTAddrs(_index);

        IShareERC721InDetail _shareNFT = IShareERC721InDetail(_shareNFTAddr);
        IERC721Metadata _shareMetadataNFT = IERC721Metadata(_shareNFTAddr);

        uint256 tokenCount = _shareNFT.balanceOf(_owner);
        ShareMetadata[] memory shareNFTCollections = new ShareMetadata[](
            tokenCount
        );

        uint256 tokenId = _shareNFT.INTELL_MODEL_NFT_TOKEN_ID();
        uint256 _endTime = _shareNFT.LAUNCH_END_TIME();

        for (uint256 i = 0; i < tokenCount; i++) {
            shareNFTCollections[i] = ShareMetadata(
                _shareNFT.tokenOfOwnerByIndex(_owner, i), // share id
                tokenId, // token id
                creatorNFT().modelIdByTokenId(tokenId), // model id
                _shareMetadataNFT.name(), // name
                _shareMetadataNFT.symbol(), // symbol
                _shareNFT.totalSupply(), // so far total supply minted
                _shareNFT.MAX_TOTAL_SUPPLY(), // max total supply
                _shareNFT.MAX_MINT_PER_ADDR(), // max number of share per wallet
                _shareNFT.MAX_MINT_PER_TX(), // max number of share per tx
                _shareNFT.MINT_PRICE(), // price per share
                _shareNFT.PAYMENT_TOKEN_ADDR(), // payment token used in investment
                IERC20(_shareNFT.PAYMENT_TOKEN_ADDR()).balanceOf(_shareNFTAddr), // withdraw amount
                _shareNFTAddr, // share nft token address
                true, // whether cNFT has share nft or not
                _shareNFT.FOR_ONLY_US_INVESTOR(), // for only us investor
                _endTime,
                _endTime < block.timestamp,
                _endTime < block.timestamp ? 0 : _endTime - block.timestamp,
                _shareNFT.WITHDRAWN(),
                _shareNFT.BLOCKED()
            );
        }

        return shareNFTCollections;
    }

}
