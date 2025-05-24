module chess::leaderboard;

use sui::{
    table,
};

public struct Leaderboard has key, store {
    id: UID,
    stats: table::Table<address, u64>, // Maps player addresses to their win counts
    top_player_ids: vector<address>, // List of top 10 player IDs
    top_player_scores: vector<u64>, // List of top 10 player scores in the same order as top_player_ids
}

public fun new(ctx: &mut TxContext): Leaderboard {
    // Create and return the leaderboard
    let leaderboard: Leaderboard = Leaderboard {
        id: object::new(ctx),
        stats: table::new<address, u64>(ctx),
        top_player_ids: vector::empty<(address)>(),
        top_player_scores: vector::empty<(u64)>(),
    };

    leaderboard
}

public fun increment_player_score_with_top_players(leaderboard: &mut Leaderboard, player: address) {
    let new_score = if (table::contains(&leaderboard.stats, player)) {
        let current_score = table::borrow_mut(&mut leaderboard.stats, player);
        *current_score = *current_score + 1;
        *current_score
    } else {
        table::add(&mut leaderboard.stats, player, 1);
        1
    };

    // Update the top_player_ids and top_player_scores vectors
    let mut found = false;
    let len = vector::length(&leaderboard.top_player_ids);
    let mut i = 0u64;

    while (i < len) {
        let top_player = *vector::borrow(&leaderboard.top_player_ids, i);
        if (top_player == player) {
            vector::swap_remove(&mut leaderboard.top_player_ids, i);
            vector::swap_remove(&mut leaderboard.top_player_scores, i);
            found = true;
            break;
        };
        i = i + 1;
    };

    if (!found) {
        vector::push_back(&mut leaderboard.top_player_ids, player);
        vector::push_back(&mut leaderboard.top_player_scores, new_score);
    };

    // Sort the top_player_ids and top_player_scores based on scores in descending order
    let mut indices = vector::empty<u64>();
    let len = vector::length(&leaderboard.top_player_ids);
    let mut i = 0u64;
    while (i < len) {
        vector::push_back(&mut indices, i);
        i = i + 1;
    };

    let len = vector::length(&indices);
    let mut i = 0u64;
    while (i < len) {
        let mut j = i + 1;
        while (j < len) {
            let index_a = *vector::borrow(&indices, i);
            let index_b = *vector::borrow(&indices, j);
            let score_a = *vector::borrow(&leaderboard.top_player_scores, index_a);
            let score_b = *vector::borrow(&leaderboard.top_player_scores, index_b);
            if (score_b > score_a) {
                vector::swap(&mut indices, i, j);
            };
            j = j + 1;
        };
        i = i + 1;
    };

    let mut sorted_ids = vector::empty<address>();
    let mut sorted_scores = vector::empty<u64>();
    let len = vector::length(&indices);
    let mut i = 0u64;
    while (i < len) {
        let index = *vector::borrow(&indices, i);
        vector::push_back(&mut sorted_ids, *vector::borrow(&leaderboard.top_player_ids, index));
        vector::push_back(&mut sorted_scores, *vector::borrow(&leaderboard.top_player_scores, index));
        i = i + 1;
    };

    leaderboard.top_player_ids = sorted_ids;
    leaderboard.top_player_scores = sorted_scores;

    // Keep only the top 10 players
    while (vector::length(&leaderboard.top_player_ids) > 10) {
        vector::pop_back(&mut leaderboard.top_player_ids);
        vector::pop_back(&mut leaderboard.top_player_scores);
    };
}

public fun get_top_player_ids(leaderboard: &Leaderboard): vector<address> {
    leaderboard.top_player_ids
}

public fun burn(leaderboard: Leaderboard) {
    let Leaderboard { id, stats, top_player_ids, top_player_scores } = leaderboard;
    table::destroy_empty(stats);
    id.delete();
    vector::destroy_empty(top_player_ids);
    vector::destroy_empty(top_player_scores);
}

#[test_only]
public fun extract_id(leaderboard: Leaderboard): UID {
    let Leaderboard { id, stats, top_player_ids, top_player_scores } = leaderboard;
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
