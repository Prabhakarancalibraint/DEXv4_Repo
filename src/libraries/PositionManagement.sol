// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PositionInfoLibrary} from "../libraries/PositionInfoLibrary.sol";

library PositionManagement {
    using PositionInfoLibrary for uint256;
    
    error InvalidTokenId();
    error PoolNotFound();

    function getPoolAndPositionInfo(
        mapping(uint256 => uint256) storage positions,
        mapping(bytes25 => PoolKey) storage poolKeys,
        uint256 tokenId
    ) internal view returns (PoolKey memory poolKey, uint256 info) {
        info = positions[tokenId];
        if (info == 0) revert InvalidTokenId();
        
        bytes25 poolId = PositionInfoLibrary.poolId(info);
        poolKey = poolKeys[poolId];
        if (poolKey.currency0.toId() == 0) revert PoolNotFound();
        
        return (poolKey, info);
    }

    function storeNewPosition(
        mapping(uint256 => uint256) storage positions,
        mapping(bytes25 => PoolKey) storage poolKeys,
        uint256 tokenId,
        PoolKey memory poolKey,
        int24 tickLower,
        int24 tickUpper
    ) internal {
        uint256 info = PositionInfoLibrary.initialize(poolKey, tickLower, tickUpper);
        bytes25 poolId = PositionInfoLibrary.poolId(info);
        poolKeys[poolId] = poolKey;
        positions[tokenId] = info;
    }
}
