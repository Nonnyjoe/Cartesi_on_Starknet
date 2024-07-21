// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)
use starknet::{ContractAddress};

#[starknet::interface]
pub trait IErc1155SinglePortal<TContractState> {
    fn depositSingleERC1155Token(self: @TContractState, token: ContractAddress, appContract: ContractAddress, tokenId: u256, value: u256, baseLayerData: Span<felt252>, execLayerData: ByteArray);
}

#[starknet::interface]
pub trait IERC1155<TContractState> {
    fn safe_transfer_from( ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256, value: u256, data: Span<felt252> );
    fn safe_batch_transfer_from( ref self: TContractState, from: ContractAddress, to: ContractAddress, token_ids: Span<u256>, values: Span<u256>, data: Span<felt252> );
}


#[starknet::contract]
mod Erc1155SinglePortal {
    use core::serde::Serde;
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use super::super::Portal::Portal_component;
    use super::super::InputBox::{IInputBoxDispatcher, IInputBoxDispatcherTrait};
    use super::{IERC1155Dispatcher, IERC1155DispatcherTrait};

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
    impl Erc1155SinglePortalImpl of super::IErc1155SinglePortal<ContractState> {
        fn depositSingleERC1155Token( self: @ContractState, token: ContractAddress, appContract: ContractAddress, tokenId: u256, value: u256, baseLayerData: Span<felt252>, execLayerData: ByteArray) {
            IERC1155Dispatcher{contract_address: token}.safe_transfer_from(get_caller_address(), appContract, tokenId, value, baseLayerData);

            let mut payload: Array<felt252> = array![];
            token.serialize(ref payload);
            get_caller_address().serialize(ref payload);
            tokenId.serialize(ref payload);
            value.serialize(ref payload);
            baseLayerData.serialize(ref payload);
            execLayerData.serialize(ref payload);

            self.portal.inputBox.read().addInput(appContract, payload);
        }
    }
}
