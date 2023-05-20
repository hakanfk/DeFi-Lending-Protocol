# Lending Platform

This smart contract is a decentralized lending platform built on Ethereum. It allows users to lend and borrow ETH and USDC, while using their ETH as collateral.

Note = Please be advised that this contract is neither audited nor completed. Please use this contract only for educational purposes.

## Prerequisites

The contract assumes you are familiar with Solidity, Ethereum, smart contracts, and the ERC20 token standard.

## Contract Details

### Constructor

```bash
constructor(address _LPtoken)
```

The constructor initializes the contract by setting the LPToken to an instance of IERC20 interface. \_LPtoken is the address of the liquidity pool token.

## Public/External Functions

```bash
function lendEth() external payable
```

This function allows users to lend Ether to the platform. The amount of Ether lent is stored in the Lender struct, which also records the timestamp when the lending process begins and ends (set to 7 days from start).

withdrawEth()

```bash
function withdrawEth(uint _share) external
```

This function allows lenders to withdraw their lent Ether after the lending period has passed. The amount to be withdrawn is based on the user's share of the total pool.

depositCollateral()

```bash
function depositCollateral() external payable
```

This function allows users to deposit Ether as collateral for borrowing. The deposited Ether is stored in the collateral mapping.

borrow()

```bash
function borrow(uint _usdcAmount) external
```

This function allows users to borrow USDC from the platform, up to a limit determined by their deposited collateral. Borrowed amounts are recorded in the Borrower struct.

repayUsdcDebt()

```bash
function repayUsdcDebt(uint _amount, address _usdc) external
```

This function allows users to repay their borrowed USDC. If the repayment is equal to the outstanding debt, the collateral is returned to the user. If the repayment is less than the debt, a proportionate amount of collateral is returned.

getPrice()

```bash
function getPrice() public view returns(uint256)
```

This function returns the latest ETH/USD price from Chainlink's AggregatorV3Interface. The current implementation uses a placeholder contract address, which should be replaced with the address of the actual Chainlink price feed contract.

## Structs

The contract has two struct types, Lender and Borrower, which record the relevant details of lending and borrowing transactions.

```bash
struct Lender{
    uint lendedAmount;
    uint lpShare;
    uint startAt;
    uint endAt;
}

struct Borrower{
    uint borrowedAmount;
    uint startAt;
    uint liqPrice;
}
```

## Mappings

lender: This mapping tracks all the lenders in the platform. Each lender is represented with a struct that contains the lended amount, LP share, and lending start and end times.

borrowers: This mapping tracks all the borrowers in the platform. Each borrower is represented with a struct that includes the borrowed amount, the borrowing start time, and the liquidation price.

collateral: This mapping tracks the Ether collateral deposited by the users. The key is the user's address and the value is the collateral amount.

## Errors

The contract defines several custom errors, which are thrown in specific circumstances:

NotEnoughEth - Thrown if a function requiring Ether is called with insufficient or no Ether.
SentFailed - Thrown if a transfer of Ether fails.
TokenLocked - Thrown if a lender attempts to withdraw their lent Ether before the lending period has ended.

## Interfaces and Imports

The contract uses the ERC20 and AggregatorV3Interface interfaces from the Chainlink library. The ERC20 interface is used to interact with the USDC token, and the AggregatorV3Interface is used to get the latest ETH/USD price.

## AggregatorV3Interface

The AggregatorV3Interface is an interface provided by the Chainlink protocol. It is used to interact with Chainlink price feeds, which are decentralized oracle networks that securely and reliably deliver high-quality real-world data to smart contracts.

In this platform, the AggregatorV3Interface is used to get the latest ETH/USD price. This price is used to calculate the collateral requirements and to value the collateral during the borrowing and repayment processes.

## License

This project is licensed under the MIT License.
