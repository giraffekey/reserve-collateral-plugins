// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import "../vendor/plugins/assets/AppreciatingFiatCollateral.sol";
import "./IPoolCollection.sol";
import "./IStandardRewards.sol";

/**
 * @title BnTokenSelfReferentialCollateral
 * @notice Collateral plugin for a V3 bnToken of unpegged collateral, such as bnETH.
 * Expected: {tok} != {ref}, {ref} == {target}, {target} != {UoA}
 */
contract BnTokenSelfReferentialCollateral is AppreciatingFiatCollateral {
    using OracleLib for AggregatorV3Interface;
    using FixLib for uint192;

    IPoolCollection public immutable collection;

    IStandardRewards public immutable rewards;

    uint256 immutable programId;

    /// @param revenueHiding {1} A value like 1e-6 that represents the maximum refPerTok to hide
    /// @param collection_ The Bancor pool collection
    /// @param rewards_ The token rewards
    /// @param programId_ The reward program ID
    constructor(
        CollateralConfig memory config,
        uint192 revenueHiding,
        IPoolCollection collection_,
        IStandardRewards rewards_,
        uint256 programId_
    ) AppreciatingFiatCollateral(config, revenueHiding) {
        require(address(collection_) != address(0), "collection missing");
        require(address(rewards_) != address(0), "rewards missing");
        collection = collection_;
        rewards = rewards_;
        programId = programId_;
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
        uint256 rate = collection.poolTokenToUnderlying(address(erc20), FIX_ONE);
        return shiftl_toFix(rate, -18);
    }

    /// Claim rewards earned by holding a balance of the ERC20 token
    /// @dev delegatecall
    function claimRewards() external virtual override(Asset, IRewardable) {
        uint256[] memory ids = new uint256[](0);
        ids[0] = programId;
        ProgramData[] memory data = rewards.programs(ids);
        IERC20 token = IERC20(data[0].rewardsToken);
        uint256 amount = rewards.claimRewards(ids);
        emit RewardsClaimed(token, amount);
    }
}
