module chess::adminstorage;

use sui::object::UID;
use sui::object;
use sui::tx_context::TxContext;
use sui::object::ID;
use std::option;

public struct AdminStorage has key, store {
    id: UID,
    escrow_id: option::Option<ID>,
    matchmaker_id: option::Option<ID>,
}

public fun new(ctx: &mut TxContext): AdminStorage {
    AdminStorage {
        id: object::new(ctx),
        escrow_id: option::none<ID>(),
        matchmaker_id: option::none<ID>(),
    }
}

public fun set_escrow_id(storage: &mut AdminStorage, escrow_id: ID) {
    storage.escrow_id = option::some<ID>(escrow_id);
}

public fun set_matchmaker_id(storage: &mut AdminStorage, matchmaker_id: ID) {
    storage.matchmaker_id = option::some<ID>(matchmaker_id);
}

public fun get_escrow_id(storage: &AdminStorage): option::Option<ID> {
    storage.escrow_id
}

public fun get_matchmaker_id(storage: &AdminStorage): option::Option<ID> {
    storage.matchmaker_id
}
