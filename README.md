# Lending and Borrowing Protocol

This smart contract implements a basic lending and borrowing protocol. Users can create loans by posting collateral, and other users can fund these loans. Borrowers repay the loan with interest, and lenders can liquidate collateral if the loan is not repaid.

## Features

- Users can create loans with specified collateral, interest rate, and duration.
- Other users can lend funds to these loans.
- Borrowers can repay loans, and lenders can liquidate collateral if the loan is not repaid on time.

## How to Use

1. Deploy the contract with an ERC20 token.
2. Use `createLoan()` to create a new loan.
3. Lenders can fund the loan using `lend()`.
4. Borrowers repay the loan using `repayLoan()` before the due date.
5. If the loan is not repaid, lenders can liquidate the collateral using `liquidateLoan()`.

## Security Considerations

- Ensure collateral value is adequate before lending.
- Interest rates and durations should be agreed upon mutually to avoid disputes.
- The contract uses reentrancy guards to prevent reentrancy attacks.
