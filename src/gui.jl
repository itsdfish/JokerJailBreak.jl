function is_valid(input, ids)
    !contains(input, " ") ? (return false) : nothing
    str = split(input, " ")
    length(str) ≠ 2 ? (return false) : nothing
    f(x, ids::Vector{T}) where {T<:Number} = isa(tryparse(T, x), Number)
    f(x, ids) = true 
    g(x) = x ∈ ("2","3","3","4","5","6","7","8","9","t","j","k","q","a")
    !f(str[1], ids) || !g(str[2]) ? (return false) : nothing 
    return true 
end

function parse_input(input, ids)
    str = split(input, " ")
    f(x, ids::Vector{T}) where {T<:Number} = parse(T, x)
    f(x, ids::Vector{T}) where {T} = T(x) 
    id = f(str[1], ids)
    dict = Dict("$i" => i for i in 1:9)
    dict["a"] = 1
    dict["t"] = 10
    dict["j"] = 11
    dict["q"] = 12
    dict["k"] = 13
    value = dict[str[2]]
    return id,value
end

function show_hand(player)
    cards = sort!(player.cards)
    str = show_cards(cards)
    println("hand: " * str)
end

function show_cards(cards)
    return mapreduce(c -> string(c) * "  ", *, cards)
end

function wait_for_key()
    println("Press enter to continue.")
    readline()
end