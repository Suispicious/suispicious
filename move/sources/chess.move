module chess::owned;

use sui::{
    event,
    object::{Self, UID, ID},
    tx_context::{Self, TxContext},
    transfer,
};
use std::vector;
use sui::transfer::Receiving;

// Piece type constants
const EMPTY: u8 = 0;
const WHITE_PAWN: u8 = 1;
const WHITE_KNIGHT: u8 = 2;
const WHITE_BISHOP: u8 = 3;
const WHITE_ROOK: u8 = 4;
const WHITE_QUEEN: u8 = 5;
const WHITE_KING: u8 = 6;
const BLACK_PAWN: u8 = 7;
const BLACK_KNIGHT: u8 = 8;
const BLACK_BISHOP: u8 = 9;
const BLACK_ROOK: u8 = 10;
const BLACK_QUEEN: u8 = 11;
const BLACK_KING: u8 = 12;

// Move type constants
const NORMAL_MOVE: u8 = 0;
const CASTLE_KINGSIDE: u8 = 1;
const CASTLE_QUEENSIDE: u8 = 2;
const EN_PASSANT: u8 = 3;
const PAWN_PROMOTION: u8 = 4;

// Error codes
const EInvalidMove: u64 = 0;
const ENotPlayerTurn: u64 = 1;
const EInvalidSquare: u64 = 2;
const ENoPieceAtSquare: u64 = 3;
const EInvalidPromotion: u64 = 4;
const EGameAlreadyEnded: u64 = 5;

// Game object
public struct Game has key, store {
    id: UID,
    board: vector<u8>,
    turn: u8,
    white: address,
    black: address,
    is_ended: bool,
}

/// Capability that allows a player to make a move
public struct TurnCap has key, store {
    id: UID,
    game: ID,
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

// Event emitted when a move is submitted by a player
public struct MoveSubmitted has copy, drop {
    game_id: ID,
    move_id: ID,
}

// Event emitted when a game ends
public struct GameEnd has copy, drop {
    game: ID,
    winner: address,
}

public fun new(white: address, black: address, ctx: &mut TxContext): Game {
    let game = Game {
        id: object::new(ctx),
        board: vector[
            BLACK_ROOK, BLACK_KNIGHT, BLACK_BISHOP, BLACK_QUEEN, BLACK_KING, BLACK_BISHOP, BLACK_KNIGHT, BLACK_ROOK,
            BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN,
            WHITE_ROOK, WHITE_KNIGHT, WHITE_BISHOP, WHITE_QUEEN, WHITE_KING, WHITE_BISHOP, WHITE_KNIGHT, WHITE_ROOK,
        ],
        turn: 0,
        white,
        black,
        is_ended: false,
    };

    let turn = TurnCap {
        id: object::new(ctx),
        game: object::id(&game),
    };

    transfer::transfer(turn, white);
    game
}

// The player calls this function to send their move
public fun send_move(
    cap: TurnCap,
    from_square: u8,
    to_square: u8,
    move_type: u8,
    promotion_piece: u8,
    ctx: &mut TxContext
) {
    assert!(from_square < 64 && to_square < 64, EInvalidSquare);
    let TurnCap { id, game } = cap;
    id.delete();

    let chess_move = Move {
        id: object::new(ctx),
        player: tx_context::sender(ctx),
        from_square,
        to_square,
        move_type,
        promotion_piece,
    };

    event::emit(MoveSubmitted {
        game_id: game,
        move_id: object::id(&chess_move),
    });

    // The admin service will handle transferring the move to the game object
    transfer::transfer(chess_move, tx_context::sender(ctx));
    // Destroy the turn capability to prevent multiple moves
}

/// Check if the game has ended (checkmate, stalemate, etc.)
public fun check_game_end(game: &Game, captured_piece: u8): bool {
    if (game.is_ended) {
        return true
    };
    
    // Check if a king was captured (simple checkmate condition)
    if (captured_piece == WHITE_KING || captured_piece == BLACK_KING) {
        return true
    };
    
    false
}


/// Called by the admin (who owns the `Game`), to commit a player's
/// intention to make a move. If the game should continue, a new `TurnCap` is
/// sent to the player who should make the next move.
public fun place_move(
    game: &mut Game,
    chess_move: Receiving<Move>,
    ctx: &mut TxContext
) {
    assert!(!game.is_ended, EGameAlreadyEnded);

    let Move { id, from_square, to_square, player, move_type, promotion_piece } = transfer::receive(&mut game.id, chess_move);
    id.delete();

    let (me, them) = game.next_player(game.turn);
    assert!(player == me, ENotPlayerTurn);

    let piece = *vector::borrow(&game.board, (from_square as u64));
    assert!(piece != EMPTY, ENoPieceAtSquare);

    // Get the piece at the destination square (if any)
    let captured_piece = *vector::borrow(&game.board, (to_square as u64));

    // Simply move the piece from source to destination
    *vector::borrow_mut(&mut game.board, (from_square as u64)) = EMPTY;
    *vector::borrow_mut(&mut game.board, (to_square as u64)) = piece;

    // Check if the game has ended
    if (check_game_end(game, captured_piece)) {
        game.is_ended = true;
        // Emit game end event with the winner (current player who made the winning move)
        event::emit(GameEnd {
            game: object::id(game),
            winner: player,
        });
        // Don't transfer turn capability if game is over
        return
    };

    // Update the turn
    game.turn = game.turn + 1;
    let cap = TurnCap { id: object::new(ctx), game: object::id(game) };
    transfer::transfer(cap, them);
}


fun next_player(game: &Game, turn_number: u8): (address, address) {
    if (turn_number % 2 == 0) {
        (game.black, game.white)
    } else {
        (game.white, game.black)
    }
}