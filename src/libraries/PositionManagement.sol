// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PositionInfo, PositionInfoLibrary} from "../libraries/PositionInfoLibrary.sol";

library PositionManagement {
    using PositionInfoLibrary for PositionInfo;
    
    error InvalidTokenId();
    error PoolNotFound();

    function getPoolAndPositionInfo(
        mapping(uint256 => uint256) storage positionInfo,
        mapping(bytes25 => PoolKey) storage poolKeys,
        uint256 tokenId
    ) internal view returns (PoolKey memory poolKey, PositionInfo info) {
        uint256 rawInfo = positionInfo[tokenId];
        info = PositionInfo.wrap(rawInfo);
        if (info.unwrap() == 0) revert InvalidTokenId();
        
        poolKey = poolKeys[info.poolId()];
        if (poolKey.currency0.toId() == 0) revert PoolNotFound();
        
        return (poolKey, info);
    }

    function storeNewPosition(
        mapping(uint256 => uint256) storage positionInfo,
        mapping(bytes25 => PoolKey) storage poolKeys,
        PoolKey memory poolKey,
        int24 tickLower,
        int24 tickUpper
    ) internal returns (uint256 tokenId) {
        PositionInfo info = PositionInfoLibrary.initialize(poolKey, tickLower, tickUpper);
        
        // Generate a new token ID (this is a placeholder - replace with actual token ID generation logic)
        tokenId = block.timestamp; 
        
        positionInfo[tokenId] = info.unwrap();

        // Store the poolKey if it is not already stored
        bytes25 poolId = info.poolId();
        if (poolKeys[poolId].currency0.toId() == 0) {
            poolKeys[poolId] = poolKey;
        }

        return tokenId;
    }
}
