#[starknet::contract]
mod InfiniteNftContract {
    use array::ArrayTrait;
    use starknet::ContractAddress;
    use starknet::ClassHash;
    use starknet::get_caller_address;
    use openzeppelin::token::erc721::ERC721;
    use alexandria_ascii::integer::ToAsciiTrait;
    use openzeppelin::access::ownable::Ownable as ownable_component;
    use openzeppelin::upgrades::upgradeable::Upgradeable as upgradeable_component;
    use openzeppelin::upgrades::interface::IUpgradeable;

    use super::super::interface::InfiniteNftInterface;

    component!(path: ownable_component, storage: ownable, event: OwnableEvent);
    component!(path: upgradeable_component, storage: upgradeable, event: UpgradeableEvent);

    /// Ownable
    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::OwnableImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableCamelOnlyImpl =
        ownable_component::OwnableCamelOnlyImpl<ContractState>;
    impl InternalImpl = ownable_component::InternalImpl<ContractState>;

    /// Upgradeable
    impl UpgradeableInternalImpl = upgradeable_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        max_supply: u256,
        last_token_id: u256,
        is_possible_mint: bool,
        keymap: LegacyMap::<felt252, u256>,
        #[substorage(v0)]
        ownable: ownable_component::Storage,
        #[substorage(v0)]
        upgradeable: upgradeable_component::Storage
    }

    // The name of the token.
    const NAME: felt252 = 'Infinite Horizons: Open Edition';

    // The symbol of the token.
    const SYMBOL: felt252 = 'IHOE';

    // The amount of tokens that can be minted at once.
    // Attempt to mint too many tokens can lead
    // to large amount of gas being used and long gas estimation
    const MAX_MINT_AMOUNT: u256 = 5;

    mod Errors {
        const MINT_ZERO_AMOUNT: felt252 = 'mint amount should be >= 1';
        const MINT_AMOUNT_TOO_LARGE: felt252 = 'mint amount too large';
        const MINT_MAX_SUPPLY_EXCEEDED: felt252 = 'max supply exceeded';
        const MINT_NOT_POSSIBLE: felt252 = 'minting is not possible';
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
        #[flat]
        OwnableEvent: ownable_component::Event,
        #[flat]
        UpgradeableEvent: upgradeable_component::Event,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        #[key]
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        approved: ContractAddress,
        #[key]
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        #[key]
        owner: ContractAddress,
        #[key]
        operator: ContractAddress,
        approved: bool
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        // max supply is set to 2^256 - 1
        let u256_max = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_u256;
        self.max_supply.write(u256_max);
        self.last_token_id.write(u256_max);
        self.is_possible_mint.write(true);

        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::InternalImpl::initializer(ref unsafe_state, NAME, SYMBOL);

        self.ownable.initializer(owner);
    }

    #[external(v0)]
    impl UpgradeableImpl of IUpgradeable<ContractState> {
        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            // This function can only be called by the owner
            self.ownable.assert_only_owner();

            // Replace the class hash upgrading the contract
            self.upgradeable._upgrade(new_class_hash);
        }
    }

    #[external(v0)]
    impl InfiniteNftContractImpl of InfiniteNftInterface<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721MetadataImpl::name(@unsafe_state)
        }

        fn symbol(self: @ContractState) -> felt252 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721MetadataImpl::symbol(@unsafe_state)
        }

        fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
            self.base_uri()
        }

        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::SRC5Impl::supports_interface(@unsafe_state, interface_id)
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::balance_of(@unsafe_state, account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::owner_of(@unsafe_state, token_id)
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::get_approved(@unsafe_state, token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::is_approved_for_all(@unsafe_state, owner, operator)
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::approve(ref unsafe_state, to, token_id)
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::set_approval_for_all(ref unsafe_state, operator, approved)
        }

        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::transfer_from(ref unsafe_state, from, to, token_id)
        }

        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::safe_transfer_from(ref unsafe_state, from, to, token_id, data)
        }

        fn base_uri(self: @ContractState) -> Array<felt252> {
            let mut uri = ArrayTrait::new();
            uri.append('ipfs://QmPqnXuH6k6Dq4qf8Z2e');
            uri.append('eB27rTkEM4CbvkqDMjtRC2aCo3');
            uri
        }

        fn set_mint_possible(ref self: ContractState, possible: bool) {
            // This function can only be called by the owner
            self.ownable.assert_only_owner();

            self.is_possible_mint.write(possible);
        }

        fn getkey(self: @ContractState, key: felt252) -> u256 {
            self.keymap.read(key)
        }

        fn mintkey(ref self: ContractState, key: felt252) {
            self.mint();
            self.keymap.write(key, self.keymap.read(key) + 1);
        }

        fn mint(ref self: ContractState) {
            let address = get_caller_address();

            self.mint_to(address);
        }
        
        fn mint_to(ref self: ContractState, recipient: ContractAddress) {
            assert(self.is_possible_mint.read(), Errors::MINT_NOT_POSSIBLE);

            // get the last id
            let last_token_id = self.last_token_id.read();

            // calculate the last id after mint
            let token_id = last_token_id - 1;

            // don't mint more than the preconfigured max supply
            let max_supply = self.max_supply.read();
            assert(token_id <= max_supply, Errors::MINT_MAX_SUPPLY_EXCEEDED);

            // call mint sequentially
            let mut unsafe_state = ERC721::unsafe_new_contract_state();

            // call mint
            ERC721::InternalImpl::_mint(ref unsafe_state, recipient, token_id);

            // Save the id of last minted token
            self.last_token_id.write(token_id);
        }

        fn max_supply(self: @ContractState) -> u256 {
            self.max_supply.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.last_token_id.read()
        }

        // camelCase methods that duplicate the main snake_case interface for compatibility

        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::SRC5CamelImpl::supportsInterface(@unsafe_state, interfaceId)
        }

        fn tokenURI(self: @ContractState, tokenId: u256) -> Array<felt252> {
            InfiniteNftContractImpl::token_uri(self, tokenId)
        }

        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::balanceOf(@unsafe_state, account)
        }

        fn ownerOf(self: @ContractState, tokenId: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::ownerOf(@unsafe_state, tokenId)
        }

        fn getApproved(self: @ContractState, tokenId: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::getApproved(@unsafe_state, tokenId)
        }

        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::isApprovedForAll(@unsafe_state, owner, operator)
        }

        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::setApprovalForAll(ref unsafe_state, operator, approved)
        }

        fn transferFrom(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, tokenId: u256
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::transferFrom(ref unsafe_state, from, to, tokenId)
        }

        fn safeTransferFrom(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            tokenId: u256,
            data: Span<felt252>
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::safeTransferFrom(ref unsafe_state, from, to, tokenId, data)
        }

        fn setMintPossible(ref self: ContractState, possible: bool) {
            InfiniteNftContractImpl::set_mint_possible(ref self, possible)
        }

        fn mintTo(ref self: ContractState, recipient: ContractAddress) {
            InfiniteNftContractImpl::mint_to(ref self, recipient)
        }

        fn maxSupply(self: @ContractState) -> u256 {
            InfiniteNftContractImpl::max_supply(self)
        }

        fn totalSupply(self: @ContractState) -> u256 {
            InfiniteNftContractImpl::total_supply(self)
        }
    }
}
