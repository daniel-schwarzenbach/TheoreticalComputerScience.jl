include("State.jl")

export DEA, NEA, execute_dea, execute_nea

"""
# Deterministic Finite Automaton (DEA)

- `initial_state`: The initial state.
- `accepting_states`: The accepting states.
- `f`: `Tuple{String, Char} => String`

``` julia
# regex: a*b+
AB = DEA(initial_state = "za", accepting_states = ["zb"], f = Dict([
  ("za", 'a') => "za",
  ("za", 'b') => "zb",
  ("zb", 'b') => "zb"
 ])
)
```

to execute the DFA, you can use the `execute_dea` function:

``` julia
execute_dea(AB, "aabbbb")
```

this will execute every state step by step return `true` if the input is accepted by the DFA, or `false` if it is rejected.
"""
Base.@kwdef struct DEA
  initial_state::State  # Startzustand
  accepting_states::Vector{State}  # Endzustände 
  f::Dict{Tuple{State, Char}, State}  # Übergangsfunktion
end

"""
# Non-deterministic Finite Automaton (NEA)

- `initial_state`: The initial state.
- `accepting_states`: The accepting states.
- `f`: `Tuple{String, Char} => Vector{String}`

``` julia
ABC = NEA(initial_states = ["za"], accepting_states = ["zb","zc"], f = Dict([
  ("za", 'a') => ["za", "zb", "zc"],
  ("zb", 'b') => ["zb"],
  ("zb", 'c') => ["zc"],
  ("zc", 'c') => ["zc"],
  ("za", 'c') => ["zb", "zc"]
 ])
)
```

to execute the NFA, you can use the `execute_nea` function:

``` julia
execute_nea(ABC, "aaabbc")
```

this will execute every state step by step and return `true` if the input is accepted by the NFA, or `false` if it is rejected.
"""
Base.@kwdef struct NEA
  initial_states::Vector{State}  # Startzustand
  accepting_states::Vector{State}  # Endzustände 
  f::Dict{Tuple{State, Char}, Vector{State}}  # Übergangsfunktion
end

function execute_dea(dea::DEA, input::String)::Bool
	z = dea.initial_state
	for c in input
		if haskey(dea.f, (z, c))
			z´ = dea.f[(z, c)]
			println("f($z,$c)  ⟹  $z´")
			z = z´
		else
			println("f($z,$c) is undefined.")
			println("input rejected\n")
			return false  # Ungültiges Zeichen
		end
	end
	println("Final state: $z")
	if z ∈ dea.accepting_states
		println("input accepted\n")
		return true  # Eingabe akzeptiert
	else
		println("input rejected\n")
		return false  # Eingabe nicht akzeptiert
	end
end

function execute_nea(nea::NEA, input::String)::Bool
	z = nea.initial_states
	for c ∈ input
		z´::Vector{State} = []
		for zi ∈ z
			if haskey(nea.f, (zi, c))
				for z´i ∈ nea.f[(zi, c)]
					push!(z´, z´i)
				end
			end
		end
		println("f($z,$c)  ⟹  $z´")
		z = z´  # NEA kann in mehrere Zustände übergehen
	end
	for zi ∈ z
		if zi ∈ nea.accepting_states
			println("input accepted\n")
			return true  # Eingabe akzeptiert
		end
	end
	println("input rejected\n")
	return false  # Eingabe nicht akzeptiert
end
