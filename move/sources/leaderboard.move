module chess::leaderboard;

use sui::{
    table,
};

public struct Leaderboard has key, store {
    id: UID,
    stats: table::Table<address, u64>, // Maps player addresses to their win counts
    top_player_ids: vector<address>, // List of top 10 player IDs
}

public fun new(ctx: &mut TxContext): Leaderboard {
    // Create and return the leaderboard
    let leaderboard: Leaderboard = Leaderboard {
        id: object::new(ctx),
        stats: table::new<address, u64>(ctx),
        top_player_ids: vector::empty<(address)>(),
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

public fun increment_player_score_with_top_players(leaderboard: &mut Leaderboard, player: address) {
    let _new_score = if (table::contains(&leaderboard.stats, player)) {
        let current_score = table::borrow_mut(&mut leaderboard.stats, player);
        *current_score = *current_score + 1;
        *current_score
    } else {
        table::add(&mut leaderboard.stats, player, 1);
        1
    };

    // Update the top_player_ids vector
    let mut found = false;
    let len = vector::length(&leaderboard.top_player_ids);
    let mut i = 0u64;

    while (i < len) {
        let top_player = *vector::borrow(&leaderboard.top_player_ids, i);
        if (top_player == player) {
            vector::swap_remove(&mut leaderboard.top_player_ids, i);
            found = true;
            break;
        };
        i = i + 1;
    };

    if (!found) {
        vector::push_back(&mut leaderboard.top_player_ids, player);
    };

    // Sort the top_player_ids based on scores in descending order
    let len = vector::length(&leaderboard.top_player_ids);
    let mut i = 0u64;
    while (i < len) {
        let mut j = 0u64;
        while (j < len - 1) {
            let a = *vector::borrow(&leaderboard.top_player_ids, j);
            let b = *vector::borrow(&leaderboard.top_player_ids, j + 1);
            let score_a = *table::borrow(&leaderboard.stats, a);
            let score_b = *table::borrow(&leaderboard.stats, b);
            if (score_a < score_b) {
                vector::swap(&mut leaderboard.top_player_ids, j, j + 1);
            };
            j = j + 1;
        };
        i = i + 1;
    };

    // Keep only the top 10 players
    if (vector::length(&leaderboard.top_player_ids) > 10) {
        vector::pop_back(&mut leaderboard.top_player_ids);
    };
}

public fun get_top_player_ids(leaderboard: &Leaderboard): vector<address> {
    leaderboard.top_player_ids
}

public fun burn(leaderboard: Leaderboard) {
    let Leaderboard { id, stats, top_player_ids } = leaderboard;
    table::destroy_empty(stats);
    id.delete();
    vector::destroy_empty(top_player_ids);
}

#[test_only]
public fun extract_id(leaderboard: Leaderboard): UID {
    let Leaderboard { id, stats, top_player_ids } = leaderboard;
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
