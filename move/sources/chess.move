module chess::chess;

use sui::{
    event,
};

const ENotFinished: u64 = 1;

// Event emitted when a move is submitted by a player
public struct MoveSubmitted has copy, drop {
    game_id: ID,
    move_id: ID,
}

// Game object
public struct Game has key, store {
    id: UID,
    fen: vector<u8>,
    white: address,
    black: address,
    is_ended: bool,
    admin: address,
}

// Move object
public struct Move has key, store {
    id: UID,
    player: address,
    from_square: u8,
    to_square: u8,
    move_type: u8,
    promotion_piece: u8,
}

public struct TurnCap has key, store {
    id: UID,
    game: ID,
}

public fun new(white: address, black: address, ctx: &mut TxContext): Game {
    let game = Game {
        id: object::new(ctx),
        fen: b"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
        white,
        black,
        is_ended: false,
        admin: ctx.sender(),
    };

    let turn_cap = TurnCap {
        id: object::new(ctx),
        game: object::id(&game),
    };

    // Transfer the TurnCap to the white player as they start the game
    transfer::transfer(turn_cap, white);

    game
}

// The player calls this function to send their move
public fun send_move(
    game: &mut Game,
    from_square: u8,
    to_square: u8,
    move_type: u8,
    promotion_piece: u8,
    ctx: &mut TxContext
): Move {
    let chess_move = Move {
        id: object::new(ctx),
        player: ctx.sender(),
        from_square,
        to_square,
        move_type,
        promotion_piece,
    };

    event::emit(MoveSubmitted {
        game_id: object::id(game),
        move_id: object::id(&chess_move),
    });

    chess_move
}

public fun burn(game: Game) {
    assert!(game.is_ended, ENotFinished);
    let Game { id, .. } = game;
    id.delete();
}

/// Called by the admin (who owns the `Game`), to commit a player's intention to make a move.
public fun place_move(
    game: &mut Game,
    fen: vector<u8>,
    _ctx: &mut TxContext
) {
    game.fen = fen;
}

public fun consume_move(chess_move: Move) {
    let Move { id, .. } = chess_move;
    id.delete();
}

// === Test Helpers ===
#[test_only]
public fun get_game_white(game: &Game): address {
    game.white
}

#[test_only]
public fun get_game_black(game: &Game): address {
    game.black
}

#[test_only]
public fun get_game_is_ended(game: &Game): bool {
    game.is_ended
}

#[test_only]
public fun get_game_fen(game: &Game): vector<u8> {
    game.fen
}

#[test_only]
public fun get_move_from_square(chess_move: &Move): u8 {
    chess_move.from_square
}

#[test_only]
public fun get_move_to_square(chess_move: &Move): u8 {
    chess_move.to_square
}

#[test_only]
public fun get_move_type(chess_move: &Move): u8 {
    chess_move.move_type
}

#[test_only]
public fun get_game_admin(game: &Game): address {
    game.admin
}

#[test_only]
public fun set_game_is_ended(game: &mut Game, value: bool) {
    game.is_ended = value;
}
