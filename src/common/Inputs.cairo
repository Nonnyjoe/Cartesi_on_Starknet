// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)

use starknet::{ContractAddress};
/// @title Inputs
/// @notice Defines the signatures of inputs.


/// @notice An advance request from an EVM-compatible blockchain to a Cartesi Machine.
/// @param chainId The chain ID
/// @param appContract The application contract address
/// @param msgSender The address of whoever sent the input
/// @param blockNumber The number of the block in which the input was added
/// @param blockTimestamp The timestamp of the block in which the input was added
/// @param index The index of the input in the input box
/// @param payload The payload provided by the message sender
/// @dev See EIP-4399 for safe usage of `prevRandao`.
/// 

#[starknet::interface]
pub trait IInputs<TContractState> {
    fn EvmAdvance(self: @TContractState, chainId: u256, appContract: ContractAddress, msgSender: ContractAddress, blockNumber: u256, blockTimestamp: u256, index: u256, payload: Array<felt252>);
}