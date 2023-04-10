// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// Portion of external interface for StrategyBase
// See: https://etherscan.io/address/0x3B960E47784150F5a63777201ee2B15253D713e8#code
interface IStrategyBase is IERC20 {
    /**
     * @notice get the vault composition of the strategy 
     * @return operator
     * @return nft collateral id
     * @return collateral amount
     * @return short amount
    */
    function getVaultDetails() external view returns (address, uint256, uint256, uint256);
}
