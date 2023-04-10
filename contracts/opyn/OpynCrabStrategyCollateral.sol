// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import "../vendor/plugins/assets/AppreciatingFiatCollateral.sol";
import "./IStrategyBase.sol";

/**
 * @title OpynCrabStrategyCollateral
 * @notice Collateral plugin for the Opyn Crab Strategy
 * Expected: {tok} != {ref}, {ref} == {target}, {target} != {UoA}
 */
contract OpynCrabStrategyCollateral is AppreciatingFiatCollateral {
    using OracleLib for AggregatorV3Interface;
    using FixLib for uint192;

    IStrategyBase public immutable strategy;

    /// @param revenueHiding {1} A value like 1e-6 that represents the maximum refPerTok to hide
    /// @param strategy_ The Opyn strategy
    constructor(
        CollateralConfig memory config,
        uint192 revenueHiding,
        IStrategyBase strategy_
    ) AppreciatingFiatCollateral(config, revenueHiding) {
        require(address(strategy_) != address(0), "strategy missing");
        strategy = strategy_;
    }

    /// @return {ref/tok} Actual quantity of whole reference units per whole collateral tokens
    function _underlyingRefPerTok() internal view override returns (uint192) {
        (, , uint256 strategyCollateral,) = strategy.getVaultDetails();
        uint256 rate = FIX_ONE.wmul(strategyCollateral).wdiv(strategy.totalSupply());
        return shiftl_toFix(rate, -18);
    }
}
