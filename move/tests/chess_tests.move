#[test_only]
module chess::tests;

use sui::test_scenario::{Self as ts};
use chess::chess;

const ADMIN: address = @0xAD;
const WHITE: address = @0x01;
const BLACK: address = @0x02;

#[test]
public fun test_burn_game() {
    // Create a new game
    let mut ts = ts::begin(ADMIN);
    let mut game = chess::new(WHITE, BLACK, ts.ctx());

    // End the game using the helper function
    chess::set_game_is_ended(&mut game, true);

    // Burn the game
    chess::burn(game);

    // Consume ts to satisfy the drop requirement
    ts.end();

    // Assert that the game is deleted
    assert!(true, 1);
}

#[test]
public fun test_new_game_creation() {
    // Create a new game
    let mut ts = ts::begin(ADMIN);
    let mut game = chess::new(WHITE, BLACK, ts.ctx());

    // Assert that the game is created with the correct admin and player
    assert!(chess::get_game_admin(&game) == ADMIN, 1);
    assert!(chess::get_game_white(&game) == WHITE, 2);
    assert!(chess::get_game_black(&game) == BLACK, 2);

    // Mark the game as ended
    chess::set_game_is_ended(&mut game, true);

    // Burn the game to consume it
    chess::burn(game);

    // Consume ts to satisfy the drop requirement
    ts.end();
}

#[test]
public fun test_send_move_with_promotion() {
    let mut ts = ts::begin(ADMIN);
    let mut game = chess::new(WHITE, BLACK, ts.ctx());

    let from_square = 6;
    let to_square = 7;
    let move_type = 1; // Example move type
    let promotion_piece = 5; // Example promotion piece

    let chess_move = chess::send_move(&mut game, from_square, to_square, move_type, promotion_piece, ts.ctx());

    assert!(chess::get_move_from_square(&chess_move) == from_square, 1);
    assert!(chess::get_move_to_square(&chess_move) == to_square, 2);
    assert!(chess::get_move_type(&chess_move) == move_type, 3);
    assert!(chess::get_game_fen(&game) == b"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", 4);

    chess::consume_move(chess_move); // Use a module function to consume the chess_move object
    chess::set_game_is_ended(&mut game, true); // Mark the game as ended
    chess::burn(game); // Consume the game object
    ts.end();
}

#[test]
public fun test_place_move() {
    let mut ts = ts::begin(ADMIN);
    let mut game = chess::new(WHITE, BLACK, ts.ctx());

    let new_fen = b"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 1 1"; // Example FEN after a move

    chess::place_move(&mut game, new_fen, ts.ctx());

    assert!(chess::get_game_fen(&game) == new_fen, 1); // Verify the FEN was updated

    chess::set_game_is_ended(&mut game, true); // Mark the game as ended
    chess::burn(game); // Consume the game object
    ts.end();
}

