module chess::escrow;

use sui::coin::Coin;
use sui::sui::SUI;

public struct EscrowVault has key {
    id: UID,
    coins: vector<Coin<SUI>>,
}

public fun new(ctx: &mut TxContext): EscrowVault {
    EscrowVault {
        id: object::new(ctx),
        coins: vector::empty(),
    }
}

public fun deposit(vault: &mut EscrowVault, coin: Coin<SUI>) {
    vector::push_back(&mut vault.coins, coin);
}