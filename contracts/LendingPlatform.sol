// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function balanceOf(address account) external view returns (uint);

    function transferFrom(address, address, uint) external returns (bool);
}

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract LendingPlatform {
    error NotEnoughEth(uint amount, uint required);
    error SentFailed(address adres, uint amount);
    error TokenLocked(uint time, uint actualTime);

    IERC20 public immutable LPToken;
    IERC20 public usdc = IERC20(0x8267cF9254734C6Eb452a7bb9AAF97B392258b21);

    constructor(address _LPtoken) {
        LPToken = IERC20(_LPtoken);
    }

    uint public constant collateralRate = 80; //Collateral Rate
    uint public constant apy7 = 1;

    uint public collateralEth;
    uint public totalEth;
    uint public totalShare;
    uint public totalUsdc;
    uint public totalBorrowedUsdc;

    struct Lender {
        uint lendedAmount;
        uint lpShare;
        uint startAt;
        uint endAt;
    }

    struct Borrower {
        uint borrowedAmount;
        uint startAt;
        uint liqPrice;
    }

    mapping(address => Lender) public lender;
    mapping(address => Borrower) public borrowers;
    mapping(address => uint) public collateral;

    function lendEth() external payable {
        if (msg.value <= 0) revert NotEnoughEth(msg.value, 1);

        Lender storage lenderUser = lender[msg.sender];

        lenderUser.startAt = block.timestamp;
        lenderUser.lendedAmount = msg.value;
        lenderUser.endAt = block.timestamp + 7 days;

        if (totalEth == 0) {
            uint share = msg.value;
            totalShare += share;
            lenderUser.lpShare += share;
        } else {
            uint share = (msg.value * totalShare) / address(this).balance;
            totalShare += share;
            lenderUser.lpShare += share;
        }
    }

    function lendUsdc(uint _amount, address _usdc) external {
        /* require(_amount > 0 && _usdc == address(usdc));
        usdc.transferFrom(msg.sender, address(this), _amount); */
    }

    function withdrawEth(uint _share) external {
        Lender storage lenderUser = lender[msg.sender];
        if (lenderUser.endAt < block.timestamp)
            revert TokenLocked(lenderUser.endAt, block.timestamp);
        if (_share <= 0 || lenderUser.lpShare <= _share)
            revert NotEnoughEth(_share, 1);

        lenderUser.lpShare -= _share;
        totalShare -= _share;

        uint amount = (((_share * address(this).balance) / totalShare) * 103) /
            100;

        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert SentFailed(msg.sender, amount);
    }

    function depositCollateral() external payable {
        if (msg.value <= 0) revert NotEnoughEth(msg.value, 1);

        collateralEth += msg.value;
        collateral[msg.sender] += msg.value;
    }

    function borrow(uint _usdcAmount) external {
        require(_usdcAmount > 0, "Invalid Amount");

        uint ethPrice = getPrice();

        uint userMaxBorrowAmount = ((collateral[msg.sender] *
            collateralRate *
            ethPrice) / 100) / 1e18;

        require(userMaxBorrowAmount <= _usdcAmount, "You exceed your limit!");

        totalUsdc -= _usdcAmount;

        totalBorrowedUsdc += _usdcAmount;

        Borrower storage borrower = borrowers[msg.sender];

        borrower.borrowedAmount += _usdcAmount;
        borrower.startAt = block.timestamp;
        borrower.liqPrice = (ethPrice * collateralRate) / 100;

        usdc.transfer(msg.sender, _usdcAmount);
    }

    function repayUsdcDebt(uint _amount, address _usdc) external {
        uint userDebt = ((borrowers[msg.sender].borrowedAmount * 107) / 100);
        require(_amount <= userDebt, "Amount exceeds real debt!");
        require(
            _usdc == address(usdc),
            "Please repay the debt with same currency you borrowed"
        );

        usdc.transferFrom(msg.sender, address(this), _amount);
        totalUsdc += _amount;
        totalBorrowedUsdc -= _amount;

        if (userDebt == _amount) {
            delete borrowers[msg.sender];
            (bool success, ) = msg.sender.call{value: collateral[msg.sender]}(
                ""
            );
            require(success, "Send Eth failed!");
        } else {
            uint debtFreeEth = (_amount * collateral[msg.sender]) /
                ((borrowers[msg.sender].borrowedAmount * 107) / 100);
            borrowers[msg.sender].borrowedAmount -= _amount;
            (bool success, ) = msg.sender.call{value: debtFreeEth}("");
            require(success, "Failed!");
        }
    }

    /*
     */
    /* 
        Helper Functions
      */
    /*
     */

    function getPrice() public view returns (uint256) {
        // goerli eth-usd address 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int price, , , ) = priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }
}
