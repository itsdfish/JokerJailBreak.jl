module JokerJailBreak
    using Random 
    using Combinatorics: combinations
    export Card
    export Game 
    export make_deck
    export play!
    export simulate!
    
    include("structs.jl")
    include("game.jl")

end
