module chess::matchmaker;

use sui::tx_context::TxContext;
use chess::chess::Game;
use chess::chess;

public struct Matchmaker has key, store {
    id: UID,
    players: vector<address>,
    stakes: vector<u64>,
}

public fun create_matchmaker(ctx: &mut TxContext): Matchmaker {
    Matchmaker {
        id: object::new(ctx),
        players: vector::empty<address>(),
        stakes: vector::empty<u64>(),
    }
}

public fun join_matchmaker(matchmaker: &mut Matchmaker, stake: u64, ctx: &mut TxContext) {
    let sender: address = ctx.sender();
    let len: u64 = vector::length<address>(&matchmaker.players);
    let mut i: u64 = 0;
    while (i < len) {
        assert!(sender != *vector::borrow<address>(&matchmaker.players, i), 100);
        i = i + 1;
    };
    vector::push_back<address>(&mut matchmaker.players, sender);
    vector::push_back<u64>(&mut matchmaker.stakes, stake);
}

public fun create_game_from_matchmaker(matchmaker: &mut Matchmaker, ctx: &mut TxContext): Game {
    let len: u64 = vector::length<address>(&matchmaker.players);
    assert!(len >= 2, 200);
    let player1: address = vector::remove<address>(&mut matchmaker.players, 0);
    let _stake1: u64 = vector::remove<u64>(&mut matchmaker.stakes, 0);
    let player2: address = vector::remove<address>(&mut matchmaker.players, 0);
    let _stake2: u64 = vector::remove<u64>(&mut matchmaker.stakes, 0);
    chess::new(player1, player2, ctx)
}

public fun burn(matchmaker: Matchmaker) {
    let Matchmaker { id, .. } = matchmaker;
    id.delete();
}