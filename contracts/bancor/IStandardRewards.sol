// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

struct ProgramData {
    uint256 id;
    address pool;
    address poolToken;
    address rewardsToken;
    bool isPaused;
    uint32 startTime;
    uint32 endTime;
    uint256 rewardRate;
    uint256 remainingRewards;
}

/// Portion of external interface for StandardRewards
// See: https://github.com/bancorprotocol/contracts-v3/blob/dev/contracts/pools/interfaces/IPoolCollection.sol
interface IStandardRewards {
    /// @return program data for each specified program id
    function programs(uint256[] calldata ids) external view returns (ProgramData[] memory);

    /// @dev claims rewards and returns the claimed reward amount
    function claimRewards(uint256[] calldata ids) external returns (uint256);
}
