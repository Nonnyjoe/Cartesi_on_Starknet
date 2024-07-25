use core::serde::Serde;
// (c) Cartesi and individual authors (IDOGWU CHINONSO)
// SPDX-License-Identifier: Apache-2.0 (see LICENSE)


/// @title Input Encoding Library

/// @notice Defines the encoding of inputs added by core trustless and
/// permissionless contracts, such as portals.
use starknet::{ContractAddress};


/// @notice Encode an Ether deposit.
/// @param sender The Ether sender
/// @param value The amount of Wei being sent
/// @param execLayerData Additional data to be interpreted by the execution layer
/// @return The encoded input payload
fn encodeEtherDeposit(sender: ContractAddress, value: u256, execLayerData: ByteArray) -> Array<felt252> {
    let mut payload: Array<felt252> = array![];
    sender.serialize(ref payload);
    value.serialize(ref payload);
    execLayerData.serialize(ref payload);

    return payload;
}

/// @notice Encode an ERC-20 token deposit.
/// @param token The token contract
/// @param sender The token sender
/// @param value The amount of tokens being sent
/// @param execLayerData Additional data to be interpreted by the execution layer
/// @return The encoded input payload
fn  encodeERC20Deposit(token: ContractAddress, sender: ContractAddress, value: u256, execLayerData: ByteArray) -> Array<felt252> {
    let mut payload: Array<felt252> = array![];
    token.serialize(ref payload);
    sender.serialize(ref payload);
    value.serialize(ref payload);
    execLayerData.serialize(ref payload);
    return payload;
}

/// @notice Encode an ERC-721 token deposit.
/// @param token The token contract
/// @param sender The token sender
/// @param tokenId The token identifier
/// @param baseLayerData Additional data to be interpreted by the base layer
/// @param execLayerData Additional data to be interpreted by the execution layer
/// @return The encoded input payload
/// @dev `baseLayerData` should be forwarded to `token`.
fn encodeERC721Deposit(token: ContractAddress, sender: ContractAddress, tokenId: u256, baseLayerData: felt252, execLayerData: ByteArray) -> Array<felt252> { 
    let mut data: Array<felt252> = array![];
    baseLayerData.serialize(ref data);
    execLayerData.serialize(ref data);
    
    let mut payload: Array<felt252> = array![];
    token.serialize(ref payload);
    sender.serialize(ref payload);
    tokenId.serialize(ref payload);
    data.serialize(ref payload);

    return payload;
}

/// @notice Encode an ERC-1155 single token deposit.
/// @param token The ERC-1155 token contract
/// @param sender The token sender
/// @param tokenId The identifier of the token being transferred
/// @param value Transfer amount
/// @param baseLayerData Additional data to be interpreted by the base layer
/// @param execLayerData Additional data to be interpreted by the execution layer
/// @return The encoded input payload
/// @dev `baseLayerData` should be forwarded to `token`.
fn encodeSingleERC1155Deposit(token: ContractAddress, sender: ContractAddress, tokenId: u256, value: u256, baseLayerData: Span<felt252>, execLayerData: ByteArray) -> Array<felt252> { 
    let mut data: Array<felt252> = array![];
    baseLayerData.serialize(ref data);
    execLayerData.serialize(ref data);
    
    let mut payload: Array<felt252> = array![];
    token.serialize(ref payload);
    sender.serialize(ref payload);
    tokenId.serialize(ref payload);
    value.serialize(ref payload);
    data.serialize(ref payload);

    return payload;
}

/// @notice Encode an ERC-1155 batch token deposit.
/// @param token The ERC-1155 token contract
/// @param sender The token sender
/// @param tokenIds The identifiers of the tokens being transferred
/// @param values Transfer amounts per token type
/// @param baseLayerData Additional data to be interpreted by the base layer
/// @param execLayerData Additional data to be interpreted by the execution layer
/// @return The encoded input payload
/// @dev `baseLayerData` should be forwarded to `token`.
fn encodeBatchERC1155Deposit(token: ContractAddress, sender: ContractAddress, tokenIds: Span<u256>, values: Span<u256>, baseLayerData: ByteArray, execLayerData: ByteArray) -> Array<felt252> {
    let mut data: Array<felt252> = array![];
    baseLayerData.serialize(ref data);
    execLayerData.serialize(ref data);

    let mut payload: Array<felt252> = array![];
    token.serialize(ref payload);
    sender.serialize(ref payload);
    tokenIds.serialize(ref payload);
    values.serialize(ref payload);
    data.serialize(ref payload);

    return payload;
}

