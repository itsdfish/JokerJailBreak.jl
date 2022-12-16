using SafeTestsets

@safetestset "is_valid" begin
    using JokerJailBreak
    using Test
    using JokerJailBreak: is_valid

    game = Game()
    indices = [5]
    @test !is_valid(game, indices)

    indices = [CartesianIndex(2,2)]
    @test !is_valid(game, indices)

    game = Game()
    indices = [5]
    push!(game.board[5], pop!(game.deck))
    @test is_valid(game, indices)

    indices = Int[]
    @test is_valid(game, indices)

    game = Game()
    indices = Int[]
    empty!(game.deck)
    @test !is_valid(game, indices)

    game = Game()
    indices = Int[]
    push!(game.board[5], splice!(game.deck, 1:3)...)
    @test !is_valid(game, indices)

    game = Game()
    indices = Int[]
    @test is_valid(game, indices)

    indices = [1,2,3,4,6,7,8,9]
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                [[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♣, 1)]];
                [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test is_valid(game, indices)

    indices = [1,9]
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                [[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♣, 1)]];
                [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test is_valid(game, indices)

    indices = [1,2]
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                [[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♣, 1)]];
                [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test !is_valid(game, indices)
end

@safetestset "sum" begin
    using JokerJailBreak
    using Test
    using JokerJailBreak: sum

    game = Game()

    indices = [1,2]
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                [[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♣, 1)]];
                [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test sum(game.board, indices) == -2

    indices = [1,9]
    @test sum(game.board, indices) == 0

    indices = [CartesianIndex(1,1),CartesianIndex(3,3)]
    @test sum(game.board, indices) == 0
end

@safetestset "update!" begin
    using JokerJailBreak
    using Test
    using JokerJailBreak: update!

    game = Game()

    initial_board = [[[Card(:♥, 1),Card(:♥, 3)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                    [[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♣, 1)]];
                    [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1),Card(:♥, 3)]]]

    ground_truth = [[[Card(:♥, 3)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                    [[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♣, 1)]];
                    [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♥, 3)]]]

    game.board = deepcopy(initial_board)

    indices = [1,9]

    update!(game, indices)

    @test game.board == ground_truth
end

@safetestset "sum" begin
    using JokerJailBreak
    using Test
    using JokerJailBreak: sum

    game = Game()

    indices = [1,2]
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                [[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♣, 1)]];
                [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test sum(game.board, indices) == -2

    indices = [1,9]
    @test sum(game.board, indices) == 0

    indices = [CartesianIndex(1,1),CartesianIndex(3,3)]
    @test sum(game.board, indices) == 0
end

@safetestset "is_winable" begin
    using JokerJailBreak
    using Test
    using JokerJailBreak: is_winnable

    game = Game()

    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                 [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
                 [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]

    combos = game.combos[1]
    @test is_winnable(game, combos)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
                [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    combos = game.combos[2]
    @test !is_winnable(game, combos)

    game = Game()
    combos = game.combos[2]
    empty!(game.deck)
    @test !is_winnable(game)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
                [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    map(i -> empty!(game.board[i]), [1,2,3,4,6,7,8])
    combos = game.combos[1]
    game.card_counts .= length.(game.board)
    @test !is_winnable(game, combos)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                [[Card(:♥, 1)]] [[Card(:♥, 1),Card(:joker, 0)]] [[Card(:♣, 1)]];
                [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    map(i -> empty!(game.board[i]), [1,2,3,4,6,7,8])
    game.card_counts .= length.(game.board)
    combos = game.combos[1]
    @test is_winnable(game, combos)
end

@safetestset "is_joker_free" begin
    using JokerJailBreak
    using Test
    using JokerJailBreak: is_joker_free

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
             [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
             [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]


    game = Game()
    game.board = [[Card[]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
                 [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
                 [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test !is_joker_free(game)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [Card[]];
             [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
             [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test !is_joker_free(game)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
             [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
             [[Card(:♣, 1)]] [[Card(:♣, 1)]] [Card[]]]
    @test !is_joker_free(game)
   
    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
             [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
             [Card[]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test !is_joker_free(game)
   
    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
             [[Card(:♥, 1)]] [[Card(:joker, 0)]] [Card[]];
             [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test is_joker_free(game)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [Card[]] [[Card(:♥, 1)]];
             [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
             [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test is_joker_free(game)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
             [Card[]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
             [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]
    @test is_joker_free(game)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
             [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
             [[Card(:♣, 1)]] [Card[]] [[Card(:♣, 1)]]]
    @test is_joker_free(game)

    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
             [[Card(:♥, 1)]] [[Card(:♣, 1),Card(:joker, 0)]] [[Card(:♣, 1)]];
             [[Card(:♣, 1)]] [Card[]] [[Card(:♣, 1)]]]
    @test !is_joker_free(game)
end

@safetestset "play_round!" begin
    using JokerJailBreak
    using JokerJailBreak: play_round!
    using Test

    include("player_functions.jl")
    
    game = Game()
    game.board = [[[Card(:♥, 1)]] [[Card(:♥, 1)]] [[Card(:♥, 1)]];
             [[Card(:♥, 1)]] [[Card(:joker, 0)]] [[Card(:♣, 1)]];
             [[Card(:♣, 1)]] [[Card(:♣, 1)]] [[Card(:♣, 1)]]]

    player = Player()
    game.top_cards .= get_top_card.(game.board)
    game.card_counts .= length.(game.board)
    deck_size = length(game.deck)
    stop,indices = decide(player, game.top_cards, game.card_counts, deck_size)
    
    @test stop == false 
    @test !isempty(indices)

    @test !play_round!(game, player)
end