# Automated Memo Validation and Reversal System for STX Transfers

## Overview

This project implements an automated system for validating memos in STX transfers on the Stacks blockchain. The smart contract ensures that transactions include a memo of sufficient length, or automatically reverses the transaction if the memo is missing or inadequate. Exceptions are made for transfers originating from approved Stacks-supported wallets.

## Features

- Automatic memo validation for STX transfers
- Configurable minimum memo length
- Whitelist for wallets exempt from memo requirements
- Admin functions for managing system parameters

## Smart Contract

The main smart contract (`memo-validation-contract`) is written in Clarity and includes the following key components:

1. Constants for contract owner and error codes
2. Data variables for minimum memo length
3. Data maps for allowed wallets
4. Public function for STX transfer with memo validation
5. Admin functions for system configuration
6. Read-only functions for querying system state

## Installation

To deploy this contract on the Stacks blockchain:

1. Ensure you have the Stacks CLI installed
2. Clone this repository
3. Navigate to the project directory
4. Deploy the contract using the Stacks CLI:

```
stacks deploy memo-validation-contract.clar
```

## Usage

### For Users

To transfer STX using this system:

1. Call the `transfer-stx-with-memo` function
2. Provide the amount, recipient, and a memo
3. Ensure your memo meets the minimum length requirement

Example:
```clarity
(contract-call? .memo-validation-contract transfer-stx-with-memo u1000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM (some "Transaction purpose"))
```

### For Administrators

As the contract owner, you can:

1. Set the minimum memo length:
   ```clarity
   (contract-call? .memo-validation-contract set-minimum-memo-length u5)
   ```

2. Add an allowed wallet:
   ```clarity
   (contract-call? .memo-validation-contract add-allowed-wallet 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
   ```

3. Remove an allowed wallet:
   ```clarity
   (contract-call? .memo-validation-contract remove-allowed-wallet 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
   ```

## Development

This project is under active development. Future improvements will include:

- Enhanced validation logic
- Automatic reversal mechanism implementation
- Integration with popular Stacks wallets
- Extensive testing suite

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your proposed changes.

## License

[MIT License](LICENSE)

## Contact

For questions or support, please open an issue in the GitHub repository.
