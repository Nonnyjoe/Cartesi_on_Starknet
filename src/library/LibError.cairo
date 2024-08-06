// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)

use starknet::{ContractAddress};

/// @notice Raise error data
/// @param errordata Data returned by failed low-level call
///

fn raise(errordata: felt252) {
    if errordata == ''{
        core::panic_with_felt252(' ');
    } else {
        core::panic_with_felt252(errordata);
    }
}