// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PositionInfo} from "../libraries/PositionInfoLibrary.sol";

library PositionManagement {
    error InvalidTokenId();
    error PoolNotFound();

    function getPoolAndPositionInfo(
        mapping(uint256 => PositionInfo) storage positions,
        mapping(bytes25 => PoolKey) storage poolKeys,
        uint256 tokenId
    ) internal view returns (PoolKey memory poolKey, PositionInfo memory info) {
        info = positions[tokenId];
        if (info.poolId == bytes25(0)) revert InvalidTokenId();
        
        poolKey = poolKeys[info.poolId];
        if (poolKey.currency0.toId() == 0) revert PoolNotFound();
        
        return (poolKey, info);
    }

    function storeNewPosition(
        mapping(uint256 => PositionInfo) storage positions,
        mapping(bytes25 => PoolKey) storage poolKeys,
        uint256 tokenId,
        PoolKey memory poolKey,
        int24 tickLower,
        int24 tickUpper
    ) internal {
        bytes25 poolId = poolKey.toId();
        poolKeys[poolId] = poolKey;
        positions[tokenId] = PositionInfo({
            poolId: poolId,
            tickLower: tickLower,
            tickUpper: tickUpper
        });
    }
}
