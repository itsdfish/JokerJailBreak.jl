abstract type AbstractGame end

abstract type AbstractPlayer end

mutable struct Data 
    n_rounds::Int
    outcome::Symbol
end
struct Card 
    suit::Symbol 
    rank::Int 
end

mutable struct Game{T} <: AbstractGame
    deck::Vector{Card}
    board::Array{Vector{Card},2}
    card_counts::Array{Int,2}
    top_cards::Array{Union{Card,Nothing},2}
    combos::T
end

function Game()
    deck = make_deck()
    shuffle!(deck)
    joker = Card(:🃏, 0)
    board = Array{Vector{Card},2}(undef,3,3)
    top_cards = Array{Union{Nothing,Card},2}(undef,3,3)
    card_counts = [3 7 3; 7 1 7; 3 7 3]
    for i ∈ 1:9
        if i == 5
            board[i] = [joker]
        else
            board[i] = splice!(deck, 1:card_counts[i])
        end
    end
    top_cards .= get_top_card.(board)
    combos = map(i -> combinations(1:9, i), 2:9)
    return Game(deck, board, card_counts, top_cards, combos)
end

