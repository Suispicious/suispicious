#[test_only]
module chess::leaderboard_tests;

use sui::test_scenario::{Self as ts};

const ADMIN: address = @0xAD;

#[test]
public fun test_new_leaderboard() {
    let mut ts = ts::begin(ADMIN);
    let leaderboard = chess::leaderboard::new(ts.ctx());
    assert!(chess::leaderboard::get_num_players(&leaderboard) == 0, 1);
    sui::object::delete(chess::leaderboard::extract_id(leaderboard));
    ts.end();
}

#[test]
public fun test_increment_player_score_first_time() {
    let mut ts = ts::begin(ADMIN);
    let mut leaderboard = chess::leaderboard::new(ts.ctx());
    let player = @0x1;
    chess::leaderboard::increment_player_score(&mut leaderboard, player);
    assert!(chess::leaderboard::get_player_score(&leaderboard, player) == 1, 2);
    let mut players = vector::empty<address>();
    vector::push_back(&mut players, player);
    chess::leaderboard::clear_leaderboard(&mut leaderboard, players);
    sui::object::delete(chess::leaderboard::extract_id(leaderboard));
    ts.end();
}

#[test]
public fun test_increment_player_score_multiple_times() {
    let mut ts = ts::begin(ADMIN);
    let mut leaderboard = chess::leaderboard::new(ts.ctx());
    let player = @0x2;
    chess::leaderboard::increment_player_score(&mut leaderboard, player);
    chess::leaderboard::increment_player_score(&mut leaderboard, player);
    chess::leaderboard::increment_player_score(&mut leaderboard, player);
    assert!(chess::leaderboard::get_player_score(&leaderboard, player) == 3, 3);
    let mut players = vector::empty<address>();
    vector::push_back(&mut players, player);
    chess::leaderboard::clear_leaderboard(&mut leaderboard, players);
    sui::object::delete(chess::leaderboard::extract_id(leaderboard));
    ts.end();
}

#[test]
public fun test_increment_multiple_players() {
    let mut ts = ts::begin(ADMIN);
    let mut leaderboard = chess::leaderboard::new(ts.ctx());
    let player1 = @0x3;
    let player2 = @0x4;
    chess::leaderboard::increment_player_score(&mut leaderboard, player1);
    chess::leaderboard::increment_player_score(&mut leaderboard, player2);
    chess::leaderboard::increment_player_score(&mut leaderboard, player1);
    assert!(chess::leaderboard::get_player_score(&leaderboard, player1) == 2, 4);
    assert!(chess::leaderboard::get_player_score(&leaderboard, player2) == 1, 5);
    let mut players = vector::empty<address>();
    vector::push_back(&mut players, player1);
    vector::push_back(&mut players, player2);
    chess::leaderboard::clear_leaderboard(&mut leaderboard, players);
    sui::object::delete(chess::leaderboard::extract_id(leaderboard));
    ts.end();
}
