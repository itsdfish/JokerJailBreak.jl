module JokerJailBreak
    using Random 
    using Combinatorics: combinations
    export Card
    export Game
    export Data 
    export make_deck
    export simulate!
    export any_depleted
    export is_joker_free
    export is_zero_sum
    
    include("structs.jl")
    include("game.jl")

end
