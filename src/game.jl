"""
    simulate!(game, player; kwargs...)

Simulate a single game of Joker Jail Break and return data. Default `Data` object is used and collected
with `update_data_round!` and `update_data_end!`.

# Arguments

- `game`: a Joker Jail Break game object
- `player`: a player which is a subtype of 'AbstractPlayer'

# Keywords

- `kwargs...`: optional keyword arguments passed to `decide`, `update_data_round!`, and `update_data_end!`
"""
simulate!(game, player; kwargs...) = simulate!(game, player, Data(0, :_); kwargs...)

"""
    simulate!(game, player, data; kwargs...)

Simulate a single game of Joker Jail Break and return data. 

# Arguments

- `game`: a Joker Jail Break game object
- `player`: a player which is a subtype of 'AbstractPlayer'
- `data`: an arbitrary data type passed to `update_data_round!` and `update_data_end!`.  

# Keywords

- `kwargs...`: optional keyword arguments passed to `decide`, `setup!`, `update_data_round!`, and `update_data_end!`
"""
function simulate!(game, player, data; kwargs...)
    (player, game.board, game.card_counts)
    stop = false
    status = :in_progress
    while !stop && status == :in_progress
        stop = play_round!(game, player; kwargs...)
        update_data_round!(game, player, data, stop; kwargs...)
        status = get_status(game)
    end
    update_data_end!(game, player, data, stop; kwargs...)
    return data
end

"""
    play_round!(game, player; kwargs...)

Play one round which involves making a decision and updating the card piles. 

# Arguments

- `game`:
- `player`:

# Keywords

- `kwargs...`: optional keyword arguments passed to `setup!`, `decide`, `update_data_round!`, and 
`update_data_end!`
"""
function play_round!(game, player; kwargs...)
    game.top_cards .= get_top_card.(game.board)
    game.card_counts .= length.(game.board)
    deck_size = length(game.deck)
    stop, indices = decide(player, game.top_cards, game.card_counts, deck_size; kwargs...)
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
        elseif (i == CartesianIndex(2, 2)) || (i == 5)
            length(game.board[i]) == 1 ? (return false) : nothing
        end
    end
    return true
end

function can_add_to_joker(game)
    return (length(game.board[2, 2]) ≥ 1) &&
           (length(game.board[2, 2]) < 4) && !isempty(game.deck)
end

function is_zero_sum(game::AbstractGame, indices)
    return is_zero_sum(game.board, indices)
end

"""
    is_zero_sum(board, indices)

Tests whether the sum of card values for card indices is zero.

# Arguments

- `board`: a 3 X 3 matrix representing a wall around the Joker, who is located in the center. Each element 
is an up turned card 
- `indices`: a vector of indices i ∈ [1:9] or `CartesianIndex`
"""
function is_zero_sum(board, indices)
    return sum(board, indices) == 0
end

function get_status(game)
    is_joker_free(game) ? (return :win) : nothing
    is_winnable(game) ? (return :in_progress) : nothing
    return :not_winnable
end

is_joker_free(game::AbstractGame) = is_joker_free(game.board)

"""
    is_joker_free(board)

Tests whether the Joker has been freed. 

# Arguments

- `board`: a 3 X 3 matrix representing a wall around the Joker, who is located in the center. Each element 
is an up turned card 
"""
function is_joker_free(board)
    if length(board[5]) > 1
        return false
    elseif isempty(board[1, 2])
        return true
    elseif isempty(board[2, 1])
        return true
    elseif isempty(board[2, 3])
        return true
    elseif isempty(board[3, 2])
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
        (game.card_counts[5] == 1) && (5 ∈ c) ? continue : nothing
        sum(game.board, c) == 0 ? (return true) : nothing
    end
    return false
end

"""
    any_depleted(card_counts, indices)

Tests whether any of the piles referenced in `indices` have been depleted.

# Arguments

- `card_counts`: each element in the 3 x 3 matrix represnts the number of cards in each position. 
- `indices`: a vector of indices i ∈ [1:9] or `CartesianIndex`
"""
function any_depleted(card_counts, indices)
    return any(i -> card_counts[i] == 0, indices)
end

function get_top_card(pile)
    return isempty(pile) ? nothing : pile[1]
end

function make_deck()
    suits = [:♥, :♦, :♣, :♠]
    deck = [Card(s, v) for s ∈ suits for v ∈ 1:13]
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

"""
    sum(board::Matrix{Union{Nothing, Card}}, indices)

Returns the sum of cards on the board corresponding to  `indices`.

# Arguments

- `indices`: a vector of indices i ∈ [1:9] or `CartesianIndex`
- `board`: a 3 X 3 matrix representing a wall around the Joker, who is located in the center. Each element 
is an up turned card 
"""
function sum(board::Matrix{Union{Nothing, Card}}, indices)
    v = 0
    for i ∈ indices
        c = board[i]
        if get_color(c) == :black
            v += c.rank
        else
            v -= c.rank
        end
    end
    return v
end

"""
    get_color(card)

Returns the color of the card. 

# Arguments

- `card`: a card object with a suit and rank 
"""
function get_color(card)
    if card.suit ∈ [:♥, :♦]
        return :red
    end
    return :black
end

update!(game, indices) = update!(game.board, game.deck, indices)

"""
    update!(board, deck, indices)

Remove top card from selected piles.

# Arguments

- `board`: a 3 X 3 matrix representing a wall around the Joker, who is located in the center. Each element 
is an up turned card 
- `deck`: vector of cards not used yet
- `indices`: a vector of indices i ∈ [1:9] or `CartesianIndex`
"""
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

"""
    setup!(player::AbstractPlayer, board, card_counts; kwargs...)

Optionally setup player before starting game. 

# Arguments

- `player::AbstractPlayer`: a player object
- `board`: a 3 X 3 matrix representing a wall around the Joker, who is located in the center. Each element 
is an up turned card 
- `card_counts`: each element in the 3 x 3 matrix represnts the number of cards in each position.  
- `player::AbstractPlayer`: a player object
- `board`: a 3 X 3 matrix representing a wall around the Joker, who is located in the center. Each element 
is an up turned card 
- `card_counts`: each element in the 3 x 3 matrix represnts the number of cards in each position.  

# Keywords

- `kwargs...`: optional keyword arguments passed to `decide`, `setup!`, `update_data_round!`, and `update_data_end!`

"""
function setup!(player::AbstractPlayer, board, card_counts; kwargs...)
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

# Keywords

- `kwargs...`: optional keyword arguments passed to `decide`, `setup!`, `update_data_round!`, and `update_data_end!`
"""
function decide(player::AbstractPlayer, board, card_counts; kwargs...)
    # intentionally blank
end

"""
    update_data_round!(game, player, data, stop; kwargs...)

Updates data after each round. By default, the round counter is incremented. 

# Arguments 

- `game`: a Joker Jail Break game object
- `player::AbstractPlayer`: a player object
- `data`: a data object
- `stop`: the player has decided to stop if true 

# Keywords

- `kwargs...`: optional keyword arguments passed to `decide`, `setup!`, `update_data_round!`, and `update_data_end!`
"""
function update_data_round!(game, player, data, stop; kwargs...)
    data.n_rounds += 1
    return nothing
end

"""
    update_data_end!(game, player, data, stop; kwargs...)

Updates data object after the game has been completed. 

# Arguments 

- `game`: a Joker Jail Break game object
- `player::AbstractPlayer`: a player object
- `data`: a data object
- `stop`: the player has decided to stop if true 
# Keywords

- `kwargs...`: optional keyword arguments passed to `decide`, `setup!`, `update_data_round!`, and `update_data_end!`
"""
function update_data_end!(game, player, data, stop; kwargs...)
    data.outcome = get_status(game)
    return nothing
end
