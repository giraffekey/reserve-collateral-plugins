// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

/// Portion of external interface for Pool
// See: https://etherscan.io/address/0xdf0770dF86a8034b3EFEf0A1Bb3c889B8332FF56#code
interface IPool {
    /// @return Convert {tok} to {ref}
    function amountLPtoLD(uint256 _amountLP) external view returns (uint256);
}
