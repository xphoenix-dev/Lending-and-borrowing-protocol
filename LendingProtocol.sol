// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LendingProtocol is ReentrancyGuard {
    struct Loan {
        address borrower;
        address lender;
        uint256 amount;
        uint256 collateral;
        uint256 interestRate;
        uint256 dueDate;
        bool isRepaid;
    }

    IERC20 public token;
    uint256 public loanCount;
    mapping(uint256 => Loan) public loans;

    event LoanCreated(
        uint256 loanId,
        address borrower,
        uint256 amount,
        uint256 collateral,
        uint256 interestRate,
        uint256 dueDate
    );

    event LoanRepaid(uint256 loanId);
    event LoanLiquidated(uint256 loanId);

    constructor(IERC20 _token) {
        token = _token;
    }

    function createLoan(uint256 amount, uint256 collateral, uint256 interestRate, uint256 duration) external nonReentrant {
        require(amount > 0, "Loan amount must be greater than zero");
        require(collateral > 0, "Collateral must be greater than zero");
        require(interestRate > 0, "Interest rate must be greater than zero");

        loanCount += 1;
        uint256 dueDate = block.timestamp + duration;

        loans[loanCount] = Loan({
            borrower: msg.sender,
            lender: address(0),
            amount: amount,
            collateral: collateral,
            interestRate: interestRate,
            dueDate: dueDate,
            isRepaid: false
        });

        emit LoanCreated(loanCount, msg.sender, amount, collateral, interestRate, dueDate);
    }

    function lend(uint256 loanId) external nonReentrant {
        Loan storage loan = loans[loanId];
        require(loan.lender == address(0), "Loan already funded");
        require(block.timestamp < loan.dueDate, "Loan has expired");

        loan.lender = msg.sender;

        token.transferFrom(msg.sender, loan.borrower, loan.amount);
    }

    function repayLoan(uint256 loanId) external nonReentrant {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.borrower, "Only the borrower can repay the loan");
        require(!loan.isRepaid, "Loan already repaid");

        uint256 repaymentAmount = loan.amount + (loan.amount * loan.interestRate / 100);
        require(token.transferFrom(msg.sender, loan.lender, repaymentAmount), "Repayment failed");

        loan.isRepaid = true;
        token.transfer(msg.sender, loan.collateral);

        emit LoanRepaid(loanId);
    }

    function liquidateLoan(uint256 loanId) external nonReentrant {
        Loan storage loan = loans[loanId];
        require(block.timestamp > loan.dueDate, "Loan is still active");
        require(!loan.isRepaid, "Loan already repaid");

        loan.isRepaid = true;
        token.transfer(loan.lender, loan.collateral);

        emit LoanLiquidated(loanId);
    }

    function getLoanDetails(uint256 loanId) external view returns (
        address borrower,
        address lender,
        uint256 amount,
        uint256 collateral,
        uint256 interestRate,
        uint256 dueDate,
        bool isRepaid
    ) {
        Loan storage loan = loans[loanId];
        return (
            loan.borrower,
            loan.lender,
            loan.amount,
            loan.collateral,
            loan.interestRate,
            loan.dueDate,
            loan.isRepaid
        );
    }
}
