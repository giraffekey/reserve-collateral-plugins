// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import "../vendor/plugins/assets/AppreciatingFiatCollateral.sol";
import "./IPoolCollection.sol";
import "./IStandardRewards.sol";

/**
 * @title BnTokenFiatCollateral
 * @notice Collateral plugin for a V3 bnToken of fiat collateral, like bnUSDC or bnDAI
 * Expected: {tok} != {ref}, {ref} is pegged to {target} unless defaulting, {target} == {UoA}
 */
contract BnTokenFiatCollateral is AppreciatingFiatCollateral {
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
