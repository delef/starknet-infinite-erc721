#[cfg(test)]
mod tests {
    use debug::PrintTrait;

    use openzeppelin::access::ownable::interface::{IOwnableDispatcher, IOwnableDispatcherTrait};
    use openzeppelin::upgrades::interface::{IUpgradeableDispatcher, IUpgradeableDispatcherTrait};

    // Import the deploy syscall to be able to deploy the contract.
    use starknet::class_hash::Felt252TryIntoClassHash;
    use starknet::{
        deploy_syscall, ContractAddress, get_contract_address,
        contract_address_const, class_hash_const
    };

    // Use starknet test utils to fake the transaction context.
    use starknet::testing::{set_caller_address, set_contract_address};

    // Import the interface and dispatcher to be able to interact with the contract.
    use nft_queue::erc721::interface::{
        InfiniteNftInterfaceDispatcher, InfiniteNftInterfaceDispatcherTrait
    };

    // Contract
    use nft_queue::erc721::token::InfiniteNftContract;

    // Deploy the contract and return its dispatcher.
    fn deploy(
        owner: ContractAddress
    ) -> (InfiniteNftInterfaceDispatcher, IOwnableDispatcher, IUpgradeableDispatcher) {
        // Set up constructor arguments.
        let mut calldata = ArrayTrait::new();
        owner.serialize(ref calldata);

        // Declare and deploy
        let (contract_address, _) = deploy_syscall(
            InfiniteNftContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        // Return dispatchers.
        // The dispatcher allows to interact with the contract based on its interface.
        (
            InfiniteNftInterfaceDispatcher { contract_address },
            IOwnableDispatcher { contract_address },
            IUpgradeableDispatcher { contract_address }
        )
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_deploy() {
        let owner = contract_address_const::<1>();
        let (contract, ownable, _) = deploy(owner);
        assert(ownable.owner() == owner, 'wrong admin');
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_mint() {
        let owner = contract_address_const::<123>();
        set_contract_address(owner);
        let (contract, _, _) = deploy(owner);

        let recipient = contract_address_const::<1>();
        contract.mint_to(recipient);
        contract.mint_to(recipient);

        assert(contract.balance_of(recipient) == 2, 'wrong balance after mint');
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_mint_batch() {
        let owner = contract_address_const::<123>();
        set_contract_address(owner);
        let (contract, _, _) = deploy(owner);

        let total = contract.total_supply();
        let recipient = contract_address_const::<1>();
        contract.mint_to(recipient);
        contract.mint_to(recipient);

        assert(contract.balance_of(recipient) == 2, 'wrong balance after mint');
        // reversed order
        assert(contract.owner_of(total - 2) == recipient, 'wrong owner');
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_mintkey() {
        let owner = contract_address_const::<123>();
        set_contract_address(owner);

        let (contract, _, _) = deploy(owner);
        let exist_key = 'hi';
        let unexist_key = 'bye';

        contract.mintkey(exist_key);
        assert(contract.getkey(exist_key) == 1, 'wrong keyval after mint');

        contract.mintkey(exist_key);
        contract.mintkey(exist_key);
        assert(contract.getkey(exist_key) == 3, 'wrong keyval after mint');
        assert(contract.getkey(unexist_key) == 0, 'wrong keyval for unexisting key');
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_mint_not_admin() {
        let admin = contract_address_const::<1>();
        set_contract_address(admin);

        let (contract, _, _) = deploy(admin);

        let not_admin = contract_address_const::<2>();
        set_contract_address(not_admin);

        contract.mint_to(not_admin);
    }

    #[test]
    #[ignore]
    #[available_gas(2000000000)]
    fn test_can_upgrade() {
        let owner = contract_address_const::<123>();
        set_contract_address(owner);

        let (contract, _, upgradeable) = deploy(owner);

        // TODO make it work actually
        let new_class_hash = class_hash_const::<234>();
        upgradeable.upgrade(new_class_hash);
    }
}