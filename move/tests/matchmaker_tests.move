#[test_only]
module chess::matchmaker_tests;

use sui::test_scenario;
use chess::chess;
use chess::matchmaker;

const ADMIN: address = @0xAD;
const PLAYER1: address = @0x01;
const PLAYER2: address = @0x02;
const PLAYER3: address = @0x03;
const PLAYER4: address = @0x04;

#[test]
public fun test_matchmaker_flow() {
    let mut scenario = test_scenario::begin(ADMIN);

    let mut matchmaker = matchmaker::create_matchmaker(scenario.ctx());

    scenario.next_tx(PLAYER1);
    matchmaker::join_matchmaker(&mut matchmaker, 100, scenario.ctx());

    scenario.next_tx(PLAYER2);
    matchmaker::join_matchmaker(&mut matchmaker, 100, scenario.ctx());

    scenario.next_tx(ADMIN);
    let mut game = matchmaker::create_game_from_matchmaker(&mut matchmaker, scenario.ctx());

    // Assert that both players are assigned, regardless of side
    let white = chess::get_game_white(&game);
    let black = chess::get_game_black(&game);
    assert!(
        (white == PLAYER1 && black == PLAYER2) || (white == PLAYER2 && black == PLAYER1),
        1
    );

    chess::set_game_is_ended(&mut game, true);
    chess::burn(game);
    matchmaker::burn(matchmaker);
    scenario.end();
}

#[test]
public fun test_matchmaker_flow_with_multiple_players() {
    let mut scenario = test_scenario::begin(ADMIN);

    let mut matchmaker = matchmaker::create_matchmaker(scenario.ctx());

    scenario.next_tx(PLAYER1);
    matchmaker::join_matchmaker(&mut matchmaker, 100, scenario.ctx());

    scenario.next_tx(PLAYER2);
    matchmaker::join_matchmaker(&mut matchmaker, 100, scenario.ctx());

    scenario.next_tx(PLAYER3);
    matchmaker::join_matchmaker(&mut matchmaker, 100, scenario.ctx());

    scenario.next_tx(PLAYER4);
    matchmaker::join_matchmaker(&mut matchmaker, 100, scenario.ctx());

    scenario.next_tx(ADMIN);
    let mut game = matchmaker::create_game_from_matchmaker(&mut matchmaker, scenario.ctx());

    // Assert that both players are assigned, regardless of side
    let white = chess::get_game_white(&game);
    let black = chess::get_game_black(&game);
    assert!(
        (white == PLAYER1 || white == PLAYER2 || white == PLAYER3 && white == PLAYER4),
        1
    );
    assert!(
        (black == PLAYER1 || black == PLAYER2 || black == PLAYER3 && black == PLAYER4),
        1
    );

    chess::set_game_is_ended(&mut game, true);
    chess::burn(game);
    matchmaker::burn(matchmaker);
    scenario.end();
}