// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import "../vendor/libraries/Fixed.sol";
import "../vendor/plugins/assets/OracleLib.sol";
import "./StargateTokenFiatCollateral.sol";

/**
 * @title StargateTokenNonFiatCollateral
 * @notice Collateral plugin for a Stargate LP token of non-fiat collateral that requires default checks,
 * like WBTC. Expected: {tok} != {ref}, {ref} == {target}, {target} != {UoA}
 */
contract StargateTokenNonFiatCollateral is StargateTokenFiatCollateral {
    using FixLib for uint192;
    using OracleLib for AggregatorV3Interface;

    AggregatorV3Interface public immutable targetUnitChainlinkFeed; // {UoA/target}
    uint48 public immutable targetUnitOracleTimeout; // {s}

    /// @param config.chainlinkFeed Feed units: {target/ref}
    /// @param targetUnitChainlinkFeed_ Feed units: {UoA/target}
    /// @param targetUnitOracleTimeout_ {s} oracle timeout to use for targetUnitChainlinkFeed
    /// @param pool_ The Stargate pool
    constructor(
        CollateralConfig memory config,
        AggregatorV3Interface targetUnitChainlinkFeed_,
        uint48 targetUnitOracleTimeout_,
        uint192 revenueHiding,
        IPool pool_
    ) StargateTokenFiatCollateral(config, revenueHiding, pool_) {
        require(address(targetUnitChainlinkFeed_) != address(0), "missing targetUnit feed");
        require(targetUnitOracleTimeout_ > 0, "targetUnitOracleTimeout zero");
        targetUnitChainlinkFeed = targetUnitChainlinkFeed_;
        targetUnitOracleTimeout = targetUnitOracleTimeout_;
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
        pegPrice = chainlinkFeed.price(oracleTimeout); // {target/ref}

        // {UoA/target}
        uint192 pricePerTarget = targetUnitChainlinkFeed.price(targetUnitOracleTimeout);

        // {UoA/tok} = {UoA/target} * {target/ref} * {ref/tok}
        uint192 pLow = pricePerTarget.mul(pegPrice).mul(refPerTok());

        // {UoA/tok} = {UoA/target} * {target/ref} * {ref/tok}
        uint192 pHigh = pricePerTarget.mul(pegPrice).mul(_underlyingRefPerTok());

        low = pLow - pLow.mul(oracleError);
        high = pHigh + pHigh.mul(oracleError);
    }
}
