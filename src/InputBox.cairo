// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)

use starknet::{ContractAddress};

#[starknet::interface]
pub trait IInputBox<TContractState> {
    /// @notice Send an input to an application.
    /// @param appContract The application contract address
    /// @param payload The input payload
    /// @return The hash of the input blob
    /// @dev MUST fire an `InputAdded` event.
    fn addInput(ref self: TContractState, appContract: ContractAddress, payload: Array<felt252>) -> felt252;
    fn getNumberOfInputs(self: @TContractState, appContract: ContractAddress) -> u256;
    fn getInputHash(self: @TContractState, appContract: ContractAddress, index: u256) -> felt252;
}


/// @notice Provides data availability of inputs for applications.
/// @notice Each application has its own append-only list of inputs.
/// @notice Off-chain, inputs can be retrieved via events.
/// @notice On-chain, only the input hashes are stored.
/// @notice See `LibInput` for more details on how such hashes are computed.
#[starknet::contract]
mod InputBox {
    use core::array::ArrayTrait;
    use starknet::{ContractAddress};
    use starknet::{get_tx_info, get_caller_address, get_block_number, get_block_timestamp, };
    use core::{poseidon::PoseidonTrait, poseidon::poseidon_hash_span};
    use core::hash::{HashStateTrait, HashStateExTrait};

    #[storage]
    struct Storage {
        appContractInputCount: LegacyMap::<ContractAddress, u256>,
        inputBoxes: LegacyMap::<(ContractAddress, u256), felt252>,
    }

    #[event]
    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        InputAdded: InputAdded,
    }


    /// @notice MUST trigger when an input is added.
    /// @param appContract The application contract address
    /// @param index The input index
    /// @param input The input blob
    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub struct InputAdded {
        #[key]
        pub appContract: ContractAddress,
        #[key]
        pub index: u256,
        #[key]
        pub input: Array<felt252>
    }

    #[abi(embed_v0)]
    impl InputBoxImpl of super::IInputBox<ContractState> {
        fn addInput(ref self: ContractState, appContract: ContractAddress, payload: Array<felt252>) -> felt252 {
            let index: u256 = self.appContractInputCount.read(appContract);
            let chainId: felt252 = get_tx_info().unbox().chain_id;

            let mut input: Array<felt252> = array![];
            chainId.serialize(ref input);
            appContract.serialize(ref input);
            get_caller_address().serialize(ref input);
            get_block_number().serialize(ref input);
            get_block_timestamp().serialize(ref input);
            // Prevrando unavailable on starknet
            index.serialize(ref input);
            payload.serialize(ref input);
            
            // @todo(Chinonso): Confirm the length of the input later.

            let inputHash: felt252 = PoseidonTrait::new().update(poseidon_hash_span(input.span())).finalize();
            self.inputBoxes.write((appContract, index), inputHash);
            self.appContractInputCount.write(appContract, index + 1);
            self.emit(InputAdded{appContract: appContract, index: index, input: input});
            return inputHash;
        }

        /// @notice Get the number of inputs sent to an application.
        /// @param appContract The application contract address
        fn getNumberOfInputs(self: @ContractState, appContract: ContractAddress) -> u256 {
            self.appContractInputCount.read(appContract)
        }

        /// @notice Get the hash of an input in an application's input box.
        /// @param appContract The application contract address
        /// @param index The input index
        /// @dev The provided index must be valid.
        fn getInputHash(self: @ContractState, appContract: ContractAddress, index: u256) -> felt252 {
            self.inputBoxes.read((appContract, index))
        }
    }
}