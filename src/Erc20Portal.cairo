// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)

use starknet::{ContractAddress};

#[starknet::interface]
pub trait IErc20Portal<TContractState> {
    fn depositErc20Tokens(self: @TContractState, token: ContractAddress, appContract: ContractAddress, value: u256, execLayerData: ByteArray);
}


//@notice This interface is simply used to implement the transferFrom function in the depositErc20Tokens function.
#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transferFrom(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}



/// @title ERC20Portal
///
/// @notice This contract allows anyone to perform transfers of
/// ERC-20 tokens to an application contract while informing the off-chain machine.
#[starknet::contract]
mod Erc20Portal {
    use cartesi_starknet::Portal::IPortal;
    use cartesi_starknet::Portal::Portal_component::PortalInternalTraits;
    use core::serde::Serde;
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use super::super::Portal::Portal_component;
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};
    use super::super::InputBox::{IInputBoxDispatcher, IInputBoxDispatcherTrait};

    component!(path: Portal_component, storage: portal, event: PortalEvent);

    #[abi(embed_v0)]
    impl PortalImpl = Portal_component::Portal<ContractState>;

    impl PortalInternalImpl = Portal_component::PortalInternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        portal: Portal_component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PortalEvent: Portal_component::Event,
    }

    pub mod Errors {
        pub const TRANSFER_FAILED: felt252 = 'ERC20 TRANSFER FAILED';
    }


    /// @notice Constructs the portal.
    /// @param inputBox The input box used by the portal
    #[constructor]
    fn constructor(ref self: ContractState, inputBox: ContractAddress) {
        self.portal.init(inputBox);
    }


    #[abi(embed_v0)]
    impl Erc20PortalImpl of super::IErc20Portal<ContractState> {
        /// @notice Transfer ERC20 tokens to an application contract
        /// and add an input to the application's input box to signal such operation.
        ///
        /// The caller must allow the portal to withdraw at least `value` tokens
        /// from their account beforehand, by calling the `approve` function in the
        /// token contract.
        ///
        /// @param token The ERC20 token contract
        /// @param appContract The application contract address
        /// @param value The amount of tokens to be transferred
        /// @param execLayerData Additional data to be interpreted by the execution layer
        fn depositErc20Tokens(self: @ContractState, token: ContractAddress, appContract: ContractAddress, value: u256, execLayerData: ByteArray) {
            let success: bool = IERC20Dispatcher{contract_address: token}.transferFrom(get_caller_address(), appContract, value);
            assert(success, Errors::TRANSFER_FAILED);

            let mut payload: Array<felt252> = array![];
            token.serialize(ref payload);
            get_caller_address().serialize(ref payload);
            value.serialize(ref payload);
            execLayerData.serialize(ref payload);

            self.portal.inputBox.read().addInput(appContract, payload);
        }
    }
}