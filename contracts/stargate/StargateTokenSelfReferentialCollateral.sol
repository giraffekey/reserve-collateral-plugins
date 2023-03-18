// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import "../vendor/plugins/assets/AppreciatingFiatCollateral.sol";
import "./IPool.sol";

/**
 * @title StargateTokenSelfReferentialCollateral
 * @notice Collateral plugin for a Stargate LP token of unpegged collateral, such as ETH.
 * Expected: {tok} != {ref}, {ref} == {target}, {target} != {UoA}
 */
contract StargateTokenSelfReferentialCollateral is AppreciatingFiatCollateral {
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

    /// Can revert, used by other contract functions in order to catch errors
    /// @param low {UoA/tok} The low price estimate
    /// @param high {UoA/tok} The high price estimate
    /// @param pegPrice {target/ref}
    function tryPrice()
        external
        view
        override
        returns (
            uint192 low,
            uint192 high,
            uint192 pegPrice
        )
    {
        uint192 p = chainlinkFeed.price(oracleTimeout); // {UoA/ref}

        // {UoA/tok} = {UoA/ref} * {ref/tok}
        uint192 pLow = p.mul(refPerTok());

        // {UoA/tok} = {UoA/ref} * {ref/tok}
        uint192 pHigh = p.mul(_underlyingRefPerTok());

        low = pLow - pLow.mul(oracleError);
        high = pHigh + pHigh.mul(oracleError);

        pegPrice = targetPerRef();
    }

    /// @return {ref/tok} Actual quantity of whole reference units per whole collateral tokens
    function _underlyingRefPerTok() internal view override returns (uint192) {
        uint256 rate = pool.amountLPtoLD(FIX_ONE);
        return shiftl_toFix(rate, -18);
    }
}
