module chess::leaderboard;

use sui::{
    table,
};

public struct Leaderboard has key, store {
    id: UID,
    stats: table::Table<address, u64>, // Maps player addresses to their win counts
}

public fun new(ctx: &mut TxContext): Leaderboard {
    // Create and return the leaderboard
    let leaderboard: Leaderboard = Leaderboard {
        id: object::new(ctx),
        stats: table::new<address, u64>(ctx),
    };

    leaderboard
}

public fun increment_player_score(leaderboard: &mut Leaderboard, player: address) {
  // Increment the player's score in the leaderboard
  if (table::contains(&leaderboard.stats, player)) {
    let current_score = table::borrow_mut(&mut leaderboard.stats, player);
    *current_score = *current_score + 1;
  } else {
    table::add(&mut leaderboard.stats, player, 1);
  }
}

public fun burn(leaderboard: Leaderboard) {
    let Leaderboard { id, stats } = leaderboard;
    table::destroy_empty(stats);
    id.delete();
}

#[test_only]
public fun extract_id(leaderboard: Leaderboard): UID {
    let Leaderboard { id, stats } = leaderboard;
    table::destroy_empty(stats);
    id
}

#[test_only]
public fun get_player_score(leaderboard: &Leaderboard, player: address): u64 {
    if (table::contains(&leaderboard.stats, player)) {
        *table::borrow(&leaderboard.stats, player)
    } else {
        0
    }
}

#[test_only]
public fun get_num_players(leaderboard: &Leaderboard): u64 {
    table::length(&leaderboard.stats)
}

#[test_only]
public fun clear_leaderboard(leaderboard: &mut Leaderboard, players: vector<address>) {
    let len = vector::length(&players);
    let mut i = 0u64;
    while (i < len) {
        let player = *vector::borrow(&players, i);
        if (table::contains(&leaderboard.stats, player)) {
            table::remove(&mut leaderboard.stats, player);
        };
        i = i + 1;
    }
}
