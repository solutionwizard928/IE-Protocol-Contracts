// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "./interface/IIntellSetting.sol";

contract IntellShareNFTContract is
    ERC1155,
    ERC1155Burnable,
    ERC1155Supply,
    AccessControl
{
    // Structure for Share Collection Info
    struct ShareCollectionInfo {
        address paymentTokenAddr;
        uint256 maxTotalSupply;
        uint256 totalInvestmentAmount;
        uint256 price;
        uint256 launchEndTime;
        bool withdrawn;
        bool blocked;
        bool paused;
        bool forUSInvestors;
        string ipfsHash;
    }

    error ShareCollectionNotFoound();
    error NotEnoughSupply();

    // Mapping of share collections
    mapping(uint256 => ShareCollectionInfo) _shareCollections;

    // Intell Setting
    IIntellSetting public intellSetting;

    // The token name
    string public name;

    // The token symbol
    string public symbol;

    /**
     * @dev Sets name/symbol/intell setting in construction
     *
     * @param __name The token name
     * @param __symbol The token symbol
     * @param __intellSetting The instance of intellSetting
     * Date: 2023-05-18
     */
    constructor(
        string memory __name,
        string memory __symbol,
        IIntellSetting __intellSetting
    ) ERC1155("") {
        name = __name;
        symbol = __symbol;
        intellSetting = __intellSetting;
    }

    /* ============================================== */
    /* ================== Modifiers ================= */
    /* ============================================== */

    /**
     * @dev Checks if share collection exists
     *
     * @param __id The shsare collection id
     * Date: 2023-05-18
     * Author: Created by Isom
     */
    modifier onlyExistingShareCollection(uint256 __id) {
        if (!shareCollectionExists(__id)) {
            revert ShareCollectionNotFoound();
        }
    }

    /**
     * @dev Checks if share collections exists
     *
     * @param __ids The share collection id(s)
     * Date: 2023-05-18
     */

    modifier onlyExistingShareCollectionBatch(uint256[] calldata __ids) {
        for (uint256 i = 0; i < __ids.length; i++) {
            if (!shareCollectionExists(__ids[i])) {
                revert ShareCollectionNotFoound();
            }
        }
    }

    modifier onlyCreator() {
        
    }

    /* ============================================== */
    /* ================== Internal ================= */
    /* ============================================== */

    
    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *   
     * Requirements:
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     * Date: 2023-05-18
     */

    function _beforeTokenTransfer(
        address __operator,
        address __from,
        address __to,
        uint256[] memory __ids,
        uint256[] memory __amounts,
        bytes memory __data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(
            __operator,
            __from,
            __to,
            __ids,
            __amounts,
            __data
        );

        if (__from == address(0) && __ids.length > 0) {
            for (uint256 i = 0; i < __ids.length; i++) {
                if (_shareCollections[__ids[i]].maxTotalSupply != 0) {
                    if (totalSupply(__ids[i]) > _shareCollections[__ids[i]].maxTotalSupply)
                        revert NotEnoughSupply();
                }
            }
        }
    }

    /* ============================================== */
    /* ================== For Creators ================= */
    /* ============================================== */

    function releaseShareCollection(
        bytes memory __initialShareCollectionInfo,
        bytes memory __signature
    ) external onlyCreator {

    }


    function shareCollectionExists(uint256 __id) public view returns (bool) {
        return true;
    }
}
