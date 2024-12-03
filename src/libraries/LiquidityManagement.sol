// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Position} from "@uniswap/v4-core/src/libraries/Position.sol";
import {PositionInfo, PositionInfoLibrary} from "../libraries/PositionInfoLibrary.sol";

library LiquidityManagement {
    using PositionInfoLibrary for PositionInfo;
    
    error SlippageCheckFailed(uint256 amount0, uint256 amount1);
    error InvalidLiquidity();

    function increaseLiquidity(
        IPoolManager poolManager,
        PoolKey memory poolKey,
        PositionInfo info,
        uint256 tokenId,
        uint256 liquidity,
        uint128 amount0Max,
        uint128 amount1Max,
        bytes memory hookData
    ) internal returns (BalanceDelta liquidityDelta, BalanceDelta feesAccrued) {
        if (liquidity == 0) revert InvalidLiquidity();

        (liquidityDelta, feesAccrued) = poolManager.modifyPosition(
            poolKey,
            IPoolManager.ModifyPositionParams({
                tickLower: info.tickLower(),
                tickUpper: info.tickUpper(),
                liquidityDelta: int256(liquidity)
            }),
            hookData
        );

        if (
            uint256(uint128(-liquidityDelta.amount0())) > amount0Max
            || uint256(uint128(-liquidityDelta.amount1())) > amount1Max
        ) {
            revert SlippageCheckFailed(
                uint256(uint128(-liquidityDelta.amount0())),
                uint256(uint128(-liquidityDelta.amount1()))
            );
        }
    }

    function decreaseLiquidity(
        IPoolManager poolManager,
        PoolKey memory poolKey,
        PositionInfo info,
        uint256 tokenId,
        uint256 liquidity,
        uint128 amount0Min,
        uint128 amount1Min,
        bytes memory hookData
    ) internal returns (BalanceDelta liquidityDelta, BalanceDelta feesAccrued) {
        if (liquidity == 0) revert InvalidLiquidity();

        (liquidityDelta, feesAccrued) = poolManager.modifyPosition(
            poolKey,
            IPoolManager.ModifyPositionParams({
                tickLower: info.tickLower(),
                tickUpper: info.tickUpper(),
                liquidityDelta: -(int256(liquidity))
            }),
            hookData
        );

        if (
            uint256(uint128(liquidityDelta.amount0())) < amount0Min
            || uint256(uint128(liquidityDelta.amount1())) < amount1Min
        ) {
            revert SlippageCheckFailed(
                uint256(uint128(liquidityDelta.amount0())),
                uint256(uint128(liquidityDelta.amount1()))
            );
        }
    }
}
