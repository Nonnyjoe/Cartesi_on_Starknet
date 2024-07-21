// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)

use starknet::{ContractAddress};

#[starknet::interface]
pub trait IERC1155BatchPortal<TContractState> {
    fn depositBatchERC1155Token(self: @TContractState, token: ContractAddress, appContract: ContractAddress, tokenIds: Span<u256>, values: Span<u256>, baseLayerData: Span<felt252>, execLayerData: ByteArray);
}


/// @title ERC-1155 Batch Transfer Portal
///
/// @notice This contract allows anyone to perform batch transfers of
/// ERC-1155 tokens to an application contract while informing the off-chain machine.
#[starknet::contract]
mod Erc1155BatchPortal {
    use super::super::Erc1155SinglePortal::{IERC1155Dispatcher, IERC1155DispatcherTrait};
    use core::serde::Serde;
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use super::super::Portal::Portal_component;
    use super::super::super::inputbox::InputBox::{IInputBoxDispatcher, IInputBoxDispatcherTrait};

    component!(path: Portal_component, storage: portal, event: PortalEvent);

    #[abi(embed_v0)]
    impl PortalImpl = Portal_component::Portal<ContractState>;

    impl PortalInternalImpl = Portal_component::PortalInternalImpl<ContractState>;


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PortalEvent: Portal_component::Event,
    }

    #[storage]
    struct Storage {
        #[substorage(v0)]
        portal: Portal_component::Storage
    }

    /// @notice Constructs the portal.
    /// @param inputBox The input box used by the portal
    #[constructor]
    fn constructor(ref self: ContractState, inputBox: ContractAddress) {
        self.portal.init(inputBox);
    }

    #[abi(embed_v0)]
    impl Erc1155BatchPortalImpl of super::IERC1155BatchPortal<ContractState> {
        /// @notice Transfer a batch of ERC-1155 tokens of multiple types to an application contract
        /// and add an input to the application's input box to signal such operation.
        ///
        /// The caller must enable approval for the portal to manage all of their tokens
        /// beforehand, by calling the `setApprovalForAll` function in the token contract.
        ///
        /// @param token The ERC-1155 token contract
        /// @param appContract The application contract address
        /// @param tokenIds The identifiers of the tokens being transferred
        /// @param values Transfer amounts per token type
        /// @param baseLayerData Additional data to be interpreted by the base layer
        /// @param execLayerData Additional data to be interpreted by the execution layer
        ///
        /// @dev Please make sure the arrays `tokenIds` and `values` have the same length.
        fn depositBatchERC1155Token( self: @ContractState, token: ContractAddress, appContract: ContractAddress, tokenIds: Span<u256>, values: Span<u256>, baseLayerData: Span<felt252>, execLayerData: ByteArray) {
            IERC1155Dispatcher{contract_address: token}.safe_batch_transfer_from(get_caller_address(), appContract, tokenIds, values, baseLayerData);

            let mut payload: Array<felt252> = array![];
            token.serialize(ref payload);
            get_caller_address().serialize(ref payload);
            tokenIds.serialize(ref payload);
            values.serialize(ref payload);
            baseLayerData.serialize(ref payload);
            execLayerData.serialize(ref payload);

            self.portal.inputBox.read().addInput(appContract, payload);
        }
    }

}