// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

/// Portion of external interface for PoolCollection
// See: https://github.com/bancorprotocol/contracts-v3/blob/dev/contracts/pools/interfaces/IPoolCollection.sol
interface IPoolCollection {
    /// @return Underlying tokens per pool tokens
    function poolTokenToUnderlying(address pool, uint256 poolTokenAmount) external view returns (uint256);
}
