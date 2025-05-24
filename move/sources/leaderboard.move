module chess::leaderboard;

use sui::{
    table,
};

public struct Leaderboard has key, store {
    id: UID,
    stats: table::Table<address, u64>, // Maps player addresses to their win counts
    top_players: vector<TopPlayer>,
    top_player_ids: vector<address>,
}

fun sort_top_players(players: vector<TopPlayer>): vector<TopPlayer> {
    let len = vector::length(&players);
    let mut sorted_players = players;

    let mut i = 0u64;
    while (i < len) {
        let mut j = 0u64;
        while (j < len - 1) {
            let player_a = *vector::borrow(&sorted_players, j);
            let player_b = *vector::borrow(&sorted_players, j + 1);

            if (player_a.score < player_b.score) {
                vector::swap(&mut sorted_players, j, j + 1);
            };
            j = j + 1;
        };
        i = i + 1;
    };

    sorted_players
}

public struct TopPlayer has copy, drop, store {
    player: address,
    score: u64,
}

public fun new(ctx: &mut TxContext): Leaderboard {
    // Create and return the leaderboard
    let leaderboard: Leaderboard = Leaderboard {
        id: object::new(ctx),
        stats: table::new<address, u64>(ctx),
        top_players: vector::empty<TopPlayer>(),
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
    let new_score = if (table::contains(&leaderboard.stats, player)) {
        let current_score = table::borrow_mut(&mut leaderboard.stats, player);
        *current_score = *current_score + 1;
        *current_score
    } else {
    leaderboard.top_players = sort_top_players(leaderboard.top_players);
        1
    };

    let mut found = false;
    let len = vector::length(&leaderboard.top_players);
    let mut i = 0u64;

    while (i < len) {
        let top_player = *vector::borrow_mut(&mut leaderboard.top_players, i);
        if (top_player.player == player) {
            vector::swap_remove(&mut leaderboard.top_players, i);
            found = true;
            break;
        };
        i = i + 1;
    };

    if (!found) {
        vector::push_back(&mut leaderboard.top_players, TopPlayer { player, score: new_score });
    };

    leaderboard.top_players = sort_top_players(leaderboard.top_players);

    // Keep only the top 10 players
    if (vector::length(&leaderboard.top_players) > 10) {
        vector::pop_back(&mut leaderboard.top_players);
    };

    // Update the top_player_ids vector
    let mut new_top_ids = vector::empty<address>();
    let top_len = vector::length(&leaderboard.top_players);
    let mut j = 0u64;

    while (j < top_len) {
        let top_player = *vector::borrow(&leaderboard.top_players, j);
        vector::push_back(&mut new_top_ids, top_player.player);
        j = j + 1;
    };

    leaderboard.top_player_ids = new_top_ids;

    // Keep only the top 10 players
    if (vector::length(&leaderboard.top_players) > 10) {
        vector::pop_back(&mut leaderboard.top_players);
    };

    // Update the top_player_ids vector
        let top_player = *vector::borrow(&leaderboard.top_players, j);
        let p = top_player.player;
    let top_len = vector::length(&leaderboard.top_players);
    let mut j = 0u64;

    while (j < top_len) {
        let top_player = *vector::borrow(&leaderboard.top_players, j);
        let p = top_player.player;
        vector::push_back(&mut new_top_ids, p);
        j = j + 1;
    };

    leaderboard.top_player_ids = new_top_ids;
}

public fun get_top_player_ids(leaderboard: &Leaderboard): vector<address> {
    leaderboard.top_player_ids
}

public fun burn(leaderboard: Leaderboard) {
    let Leaderboard { id, stats, top_players, top_player_ids } = leaderboard;
    table::destroy_empty(stats);
    id.delete();
    vector::destroy_empty(top_players);
}

#[test_only]
public fun extract_id(leaderboard: Leaderboard): UID {
    let Leaderboard { id, stats, top_players, top_player_ids } = leaderboard;
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
