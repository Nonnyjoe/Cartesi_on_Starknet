// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)

use starknet::{ContractAddress};

#[starknet::interface]
pub trait IErc721Portal<TContractState> {
    fn depositERC721Token( self: @TContractState, token: ContractAddress, appContract: ContractAddress, tokenId: u256, baseLayerData: Span<felt252>, execLayerData: ByteArray);
}


#[starknet::interface]
pub trait IERC721<TContractState> {
    // IERC721
    fn safe_transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>);
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256);
}


/// @title ERC-721 Portal
///
/// @notice This contract allows anyone to perform transfers of
/// ERC-721 tokens to an application contract while informing the off-chain machine.
#[starknet::contract]
mod Erc721Portal {
    use core::serde::Serde;
use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use super::super::Portal::Portal_component;
    use super::super::InputBox::{IInputBoxDispatcher, IInputBoxDispatcherTrait};
    use super::{IERC721Dispatcher, IERC721DispatcherTrait};

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
    impl Erc721PortalImpl of super::IErc721Portal<ContractState> {
        /// @notice Transfer an ERC-721 token to an application contract
        /// and add an input to the application's input box to signal such operation.
        ///
        /// The caller must change the approved address for the ERC-721 token
        /// to the portal address beforehand, by calling the `approve` function in the
        /// token contract.
        ///
        /// @param token The ERC-721 token contract
        /// @param appContract The application contract address
        /// @param tokenId The identifier of the token being transferred
        /// @param baseLayerData Additional data to be interpreted by the base layer
        /// @param execLayerData Additional data to be interpreted by the execution layer
        fn depositERC721Token( self: @ContractState, token: ContractAddress, appContract: ContractAddress, tokenId: u256, baseLayerData: Span<felt252>, execLayerData: ByteArray) {
            IERC721Dispatcher{contract_address: token}.safe_transfer_from(get_caller_address(), appContract, tokenId, baseLayerData);

            let mut payload: Array<felt252> = array![];
            token.serialize(ref payload);
            get_caller_address().serialize(ref payload);
            tokenId.serialize(ref payload);
            baseLayerData.serialize(ref payload);
            execLayerData.serialize(ref payload);

            self.portal.inputBox.read().addInput(appContract, payload);
        }
    }
}
