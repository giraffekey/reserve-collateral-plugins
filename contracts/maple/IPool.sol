// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

/// Portion of external interface for Pool
// See: https://maplefinance.gitbook.io/maple/technical-resources/interfaces/pool
interface IPool {
    /// @return Total amount of the underlying asset that is managed by the Vault
    function totalAssets() external view returns (uint256);

    /// @return Total amount of tokens in existence
    function totalSupply() external view returns (uint256);
}
