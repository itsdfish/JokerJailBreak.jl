function simulate!(game, player, data)
    setup!(player, game.board, game.card_counts)
    stop = false
    status = :in_progress
    while !stop && status == :in_progress
        stop = play!(game, player)
        collect_data!(game, player, data, stop)
        status = get_status(game)
    end
    return nothing
end

function play!(game, player)
    game.top_cards .= get_top_card.(game.board)
    game.card_counts .= length.(game.board)
    stop,indices = decide(player, game.top_cards, game.card_counts)
    stop ? (return true) : nothing
    is_valid(game, indices) ? nothing : error("not a valid selection")
    update!(game, indices)
    return stop 
end

function is_valid(game, indices)
    if isempty(indices) 
        return can_add_to_joker(game)
    elseif !is_zero_sum(game, indices)
        return false 
    end
    return can_select(game, indices)
end 

function can_select(game, indices)
    for i ∈ indices 
        if isempty(game.board[i])
            return false
        elseif (i == CartesianIndex(2,2)) || (i == 5)
            length(game.board[i]) == 1 ? (return false) : nothing 
        end
    end
    return true
end

function can_add_to_joker(game)
    return (length(game.board[2,2]) ≥ 1) && 
        (length(game.board[2,2]) < 3) && !isempty(game.deck)
end

function is_zero_sum(game, indices)
    return sum(game.board, indices) == 0
end

function get_status(game)
    is_joker_free(game) ? (return :win) : nothing
    is_winnable(game) ? (return :in_progress) : nothing 
    return :not_winnable
end

function is_joker_free(game)
    if length(game.board[5]) > 1
        return false
    elseif isempty(game.board[1,2])
        return true 
    elseif isempty(game.board[2,1])
        return true
    elseif isempty(game.board[2,3])
        return true
    elseif isempty(game.board[3,2])
        return true
    end
    return false
end

function is_winnable(game)
    can_add_to_joker(game) ? (return true) : (return false)
    for c ∈ game.combos
        is_winable(game, c) ? (return true) : nothing 
    end
    return false
end

function is_winnable(game, combos)
    for c ∈ combos
        any_depleted(game.card_counts, c) ? continue : nothing
        (5 ∈ c) && (game.card_counts[5] == 1) ? (continue) : nothing
        sum(game.board, c) == 0 ? (return true) : nothing
    end
    return false 
end

function any_depleted(card_counts, indices)
    return any(i -> card_counts[i] == 0, indices)
end

function get_top_card(pile)
    return isempty(pile) ? nothing : pile[1]
end

function make_deck()
    suits = [:♥, :♦, :♣, :♠]
    deck =  [Card(s, v) for s ∈ suits for v ∈ 1:13]
    return deck 
end

function sum(board, indices)
    v = 0
    for i ∈ indices
        c = board[i][1]
        if get_color(c) == :black 
            v += c.rank
        else
            v -= c.rank 
        end
    end
    return v 
end

function get_color(card)
    if card.suit ∈ [:♥, :♦]
        return :red
    end
    return :black 
end

update!(game, indices) = update!(game.board, game.deck, indices)

function update!(board, deck, indices)
    if isempty(indices)
        push!(board[5], pop!(deck))
    else
        for i ∈ indices 
            popfirst!(board[i])
        end
    end
    return nothing
end

function setup!(player::AbstractPlayer, board, card_counts)
    # intentionally blank
end

"""
    decide(player::AbstractPlayer, board, card_counts) -> stop,indices

Implements decision logic on each turn and returns `stop` and `indices`. If `stop` is true, the game will stop. If 
`stop` is true, the game will continue, and the cards in the vector `indices` will be selected and removed if 
valid. `indices` can be a vector of `CartesianIndex` or a vector of integers with allowable values 1 through 9.
If `stop` is true and `indices` is empty, a card will be placed on top of the Joker if allowable. 

# Arguments 

- `player::AbstractPlayer`: a player object
- `board`: a 3 X 3 matrix representing a wall around the Joker, who is located in the center. Each element 
is an up turned card 
- `card_counts`: each element in the 3 x 3 matrix represnts the number of cards in each position.  
"""
function decide(player::AbstractPlayer, board, card_counts)
    # intentionally blank
end

function collect_data!(game, player, data, stop)

end
