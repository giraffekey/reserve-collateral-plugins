// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

/// Portion of external interface for LeverageZen
// See: https://etherscan.io/address/0xb46Fb07b0c80DBC3F97cae3BFe168AcaD46dF507#code
interface ILeverageZen {
    /**
     * @notice calculate amount of ETH collateral to withdraw to Euler based on amount of share of bull token
     * @param _bullShare bull share amount
     * @return WETH to withdraw
     */
    function calcWethToWithdraw(uint256 _bullShare) external view returns (uint256);
}
