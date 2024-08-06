// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)

use starknet::{ContractAddress, ClassHash};

/// @notice Perform a low level call and automatically reverts if it fails.
/// @param destination The address that will be called
/// @param selector: The function selector that will be called
/// @param payload The payload, which—in the case of Solidity
/// contracts—encodes a function call
fn safeCall(destination: ContractAddress, selector: felt252, payload: Array<felt252>) {
    let res = starknet::syscalls::call_contract_syscall(destination, selector, payload.span()).unwrap();
}

/// @notice Perform a delegate call and automatically reverts if it fails
/// @param destination The class hash that will be called
/// @param selector: The function selector that will be called
/// @param payload The payload, which—in the case of Solidity
/// libraries—encodes a function call
fn safeDelegateCall(destination: ClassHash, selector: felt252, payload: Array<felt252>) {
    let res = starknet::syscalls::library_call_syscall(destination, selector, payload.span()).unwrap();
}

