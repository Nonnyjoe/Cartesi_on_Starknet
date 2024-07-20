// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)

use starknet::{ContractAddress};
use super::InputBox::IInputBoxDispatcher;

#[starknet::interface]
pub trait IPortal<TContractState> {
    /// @notice Get the input box used by this portal.
    /// @return The input box
    fn getInputBox(self: @TContractState) -> IInputBoxDispatcher;
}

/// @title Portal
/// @notice This component serves as a base for all the other portals.
#[starknet::component]
pub mod Portal_component {
    use core::num::traits::zero::Zero;
    use super::{ContractAddress, IInputBoxDispatcher};

    #[storage]
    struct Storage{
        inputBox: IInputBoxDispatcher,
    }

    #[generate_trait]
    pub impl PortalInternalImpl<TContractState, +HasComponent<TContractState>> of PortalInternalTraits<TContractState> {
        /// @notice serve as a constructor to set the inputbox address.
        fn init(ref self: ComponentState<TContractState>, inputBox: ContractAddress) {
            assert(!inputBox.is_zero(), 'Invalid inputbox Address');
            self.inputBox.write(IInputBoxDispatcher{contract_address:inputBox});
        }
    }

    #[embeddable_as(Portal)]
    impl PortalImpl<TContractState, +HasComponent<TContractState>> of super::IPortal<ComponentState<TContractState>> {
        fn getInputBox(self: @ComponentState<TContractState>) -> IInputBoxDispatcher {
            return self.inputBox.read();
        }
    }
}