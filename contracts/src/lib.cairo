use starknet::ContractAddress;

#[starknet::interface]
trait IStarkRandomness<TContractState> {
    fn get_random(self: @TContractState, request_id: u64) -> u128;
    fn request_randomness(ref self: TContractState, callback_fee_limit: u128,);
    fn receive_random_words(
        ref self: TContractState,
        requestor_address: ContractAddress,
        request_id: u64,
        random_words: Span<felt252>
    );
}

#[starknet::contract]
mod StarkRandomness {
    use core::starknet::event::EventEmitter;
    use super::{ContractAddress, IStarkRandomness};
    use starknet::info::{get_block_number, get_caller_address, get_contract_address};
    use pragma_lib::abi::{IRandomnessDispatcher, IRandomnessDispatcherTrait};
    use openzeppelin::token::erc20::{interface::{IERC20Dispatcher, IERC20DispatcherTrait}};

    #[storage]
    struct Storage {
        randomness_contract_address: ContractAddress,
        min_block_number: u64,
        request_count: u64,
        randoms: LegacyMap::<u64, u128>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RequestRandom: RequestRandom,
        ReceiveRandom: ReceiveRandom,
    }

    #[derive(Drop, starknet::Event)]
    struct RequestRandom {
        #[key]
        user: ContractAddress,
        request_id: u64
    }

    #[derive(Drop, starknet::Event)]
    struct ReceiveRandom {
        #[key]
        request_id: u64,
        random: u128
    }

    #[constructor]
    fn constructor(ref self: ContractState, randomness_contract_address: ContractAddress) {
        self.randomness_contract_address.write(randomness_contract_address);
    }

    #[external(v0)]
    impl IStarkRandomnessImpl of IStarkRandomness<ContractState> {
        fn get_random(self: @ContractState, request_id: u64) -> u128 {
            let last_random = self.randoms.read(request_id);
            return last_random;
        }

        fn request_randomness(ref self: ContractState, callback_fee_limit: u128,) {
            let randomness_contract_address = self.randomness_contract_address.read();

            // Approve the randomness contract to transfer the callback fee
            // You would need to send some ETH to this contract first to cover the fees
            let eth_dispatcher = IERC20Dispatcher {
                contract_address: 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7 // ETH Contract Address
                    .try_into()
                    .unwrap()
            };
            eth_dispatcher.approve(randomness_contract_address, callback_fee_limit.into());

            // Request the randomness
            let randomness_dispatcher = IRandomnessDispatcher {
                contract_address: randomness_contract_address
            };

            let publish_delay = 1_u64;
            let num_words = 1_u64;
            let seed = self.request_count.read();
            let callback_address = get_contract_address();
            let request_id = randomness_dispatcher
                .request_random(
                    seed, callback_address, callback_fee_limit, publish_delay, num_words
                );
            self.request_count.write(seed + 1);

            let current_block_number = get_block_number();
            self.min_block_number.write(current_block_number + publish_delay);

            self.emit(RequestRandom { user: get_caller_address(), request_id });

            return ();
        }


        fn receive_random_words(
            ref self: ContractState,
            requestor_address: ContractAddress,
            request_id: u64,
            random_words: Span<felt252>
        ) {
            // Have to make sure that the caller is the Pragma Randomness Oracle contract
            let caller_address = get_caller_address();
            assert(
                caller_address == self.randomness_contract_address.read(),
                'caller not randomness contract'
            );
            // and that the current block is within publish_delay of the request block
            let current_block_number = get_block_number();
            let min_block_number = self.min_block_number.read();
            assert(min_block_number <= current_block_number, 'block number issue');

            // and that the requestor_address is what we expect it to be (can be self
            // or another contract address), checking for self in this case
            let contract_address = get_contract_address();
            assert(requestor_address == contract_address, 'requestor is not self');

            // Optionally: Can also make sure that request_id is what you expect it to be,
            // and that random_words_len==num_words

            // Your code using randomness!
            let random_word = *random_words.at(0);

            let seed: u256 = random_word.into();
            let random = seed.low % 8 + 1;

            self.randoms.write(request_id, random);

            self.emit(ReceiveRandom { request_id, random });

            return ();
        }
    }
}
