module chess::matchmaker;

use chess::chess::Game;
use chess::chess;
use sui::coin::Coin;
use sui::sui::SUI;
use chess::escrow::EscrowVault;
use chess::escrow;

public struct Matchmaker has key, store {
    id: UID,
    vault_id: ID, // store the object ID, not UID
    players: vector<address>,
}

public fun create_matchmaker(vault_id: ID, ctx: &mut TxContext): Matchmaker {
    Matchmaker {
        id: object::new(ctx),
        vault_id: vault_id,
        players: vector::empty<address>(),
    }
}

const ENTRY_FEE: u64 = 100_000_000; // 0,1 SUI in MIST

public fun join_matchmaker(matchmaker: &mut Matchmaker, vault: &mut EscrowVault, fee: Coin<SUI>, ctx: &mut TxContext) {
    assert!(matchmaker.vault_id == object::id(vault), 101); // Ensure vault matches matchmaker
    assert!(fee.value() == ENTRY_FEE, 100);
    let sender: address = ctx.sender();
    let len: u64 = vector::length<address>(&matchmaker.players);
    let mut i: u64 = 0;
    while (i < len) {
        assert!(sender != *vector::borrow<address>(&matchmaker.players, i), 100);
        i = i + 1;
    };
    vector::push_back<address>(&mut matchmaker.players, sender);

    escrow::deposit(vault, fee)
}

public fun create_game_from_matchmaker(matchmaker: &mut Matchmaker, ctx: &mut TxContext): Game {
    let len: u64 = vector::length<address>(&matchmaker.players);
    assert!(len >= 2, 200);
    let player1: address = vector::remove<address>(&mut matchmaker.players, 0);
    let player2: address = vector::remove<address>(&mut matchmaker.players, 0);
    chess::new(player1, player2, ctx)
}

public fun burn(matchmaker: Matchmaker) {
    let Matchmaker { id, players, vault_id } = matchmaker;
    id.delete();
    // players and vault_id are dropped here, but that's fine as they are not UID
}