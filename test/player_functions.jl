import JokerJailBreak: AbstractPlayer, decide
using JokerJailBreak: get_top_card, get_color
using StatsBase

struct Player <: AbstractPlayer

end

function decide(player::Player, board, card_counts, deck_size)
    indices = Int[]
    cnt = 0
    while cnt < 1000 
        cnt += 1
        indices = sample(1:9, 2, replace=false)
        is_zero_sum(board, indices) ? break : nothing
    end
    stop = cnt < 1000 ? false : true 
    cnt == 1000 ? empty!(indices) : nothing
    return stop,indices
end