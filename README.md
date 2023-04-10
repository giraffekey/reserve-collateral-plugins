# reserve-collateral-plugins

A collection of collateral plugins for Reserve.

## Implementation

### Bancor

The PoolCollection contract includes a `poolTokenToUnderlying` function that converts {tok} to {ref}. {ref/tok} can be calculated by measuring the amount of {ref} for one {tok}.

The StandardRewards contract can be used to claim rewards from an array of program IDs. A program ID references a program, which gives a token as a reward for deposited pool tokens.

Supports fiat, nonfiat and unpegged collateral.

### Stargate

Stargate pools accrue automatically by increasing the exchange rate of pool tokens to underlying tokens. The Pool contract includes a `amountLPtoLD` function that can be used to find this exchange rate.

Supports fiat, nonfiat and unpegged collateral.

### Maple Finance

Maple Finance pools accrue automatically by increasing the exchange rate of pool tokens to underlying tokens. The Pool contract includes a `totalAssets` function that returns the amount of underlying tokens in the pool and a `totalSupply` function that returns the amount of pool tokens in circulation.

Supports fiat, nonfiat and unpegged collateral.

### Opyn

Opyn strategies accrue automatically by increasing the exchange rate of pool tokens to underlying tokens. The StrategyBase contract includes a `getVaultDetails` function that returns the amount of underlying tokens in collateral and a `totalSupply` function that returns the amount of pool tokens in circulation. The LeverageZen contract includes a `calcWethToWithdraw` contract that can convert pool tokens to underlying tokens.

Supports Crab and Zen Bull strategies.
