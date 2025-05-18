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
  if (table::contains(&leaderboard.stats, player)) {
    let current_score = table::borrow_mut(&mut leaderboard.stats, player);
    *current_score = *current_score + 1;
  } else {
    table::add(&mut leaderboard.stats, player, 1);
  }
}
