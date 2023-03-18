// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import "../vendor/plugins/assets/AppreciatingFiatCollateral.sol";
import "./IPool.sol";

/**
 * @title StargateTokenFiatCollateral
 * @notice Collateral plugin for a Stargate LP token of fiat collateral, like USDC or USDT
 * Expected: {tok} != {ref}, {ref} is pegged to {target} unless defaulting, {target} == {UoA}
 */
contract StargateTokenFiatCollateral is AppreciatingFiatCollateral {
    using OracleLib for AggregatorV3Interface;
    using FixLib for uint192;

    IPool public immutable pool;

    /// @param revenueHiding {1} A value like 1e-6 that represents the maximum refPerTok to hide
    /// @param pool_ The Stargate pool
    constructor(
        CollateralConfig memory config,
        uint192 revenueHiding,
        IPool pool_
    ) AppreciatingFiatCollateral(config, revenueHiding) {
        require(address(pool_) != address(0), "pool missing");
        pool = pool_;
    }

    /// @return {ref/tok} Actual quantity of whole reference units per whole collateral tokens
    function _underlyingRefPerTok() internal view override returns (uint192) {
        uint256 rate = pool.amountLPtoLD(FIX_ONE);
        return shiftl_toFix(rate, -18);
    }
}
