include("State.jl")

export DEA, NEA, execute_dea, execute_nea
# Deterministic Finite Automaton (DEA)
Base.@kwdef struct DEA
  initial_state::State  # Startzustand
  accepting_states::Vector{State}  # Endzustände 
  f::Dict{Tuple{State, Char}, State}  # Übergangsfunktion
end

# Non-deterministic Finite Automaton (NEA)
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
