use starknet::ContractAddress;

#[starknet::interface]
trait InfiniteNftInterface<TContractState> {
    // Standard ERC721 + ERC721Metadata methods
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn token_uri(self: @TContractState, token_id: u256) -> Array<felt252>;
    fn supports_interface(self: @TContractState, interface_id: felt252) -> bool;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn transfer_from(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    );
    fn safe_transfer_from(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    fn base_uri(self: @TContractState) -> Array<felt252>;
    fn set_mint_possible(ref self: TContractState, possible: bool);
    fn getkey(self: @TContractState, key: felt252) -> u256;
    // mint with a specific key
    fn mintkey(ref self: TContractState, key: felt252);
    // mint one token
    fn mint(ref self: TContractState);
    // mint one token to a specific address
    fn mint_to(ref self: TContractState, recipient: ContractAddress);
    // methods for retrieving supply
    fn max_supply(self: @TContractState) -> u256;
    fn total_supply(self: @TContractState) -> u256;

    // camelCase methods that duplicate the main snake_case interface for compatibility
    fn tokenURI(self: @TContractState, tokenId: u256) -> Array<felt252>;
    fn supportsInterface(self: @TContractState, interfaceId: felt252) -> bool;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn ownerOf(self: @TContractState, tokenId: u256) -> ContractAddress;
    fn getApproved(self: @TContractState, tokenId: u256) -> ContractAddress;
    fn isApprovedForAll(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn setApprovalForAll(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn transferFrom(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, tokenId: u256
    );
    fn safeTransferFrom(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        tokenId: u256,
        data: Span<felt252>
    );
     fn setMintPossible(ref self: TContractState, possible: bool);

    // and their camelCase equivalents
    fn mintTo(ref self: TContractState, recipient: ContractAddress);
    fn maxSupply(self: @TContractState) -> u256;
    fn totalSupply(self: @TContractState) -> u256;
}

