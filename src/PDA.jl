include("State.jl")

export DPDA, NPDA, execute_dpda, execute_npda

# Deterministic Pushdown Automaton (DPDA)
Base.@kwdef struct DPDA
	initial_state::State  # start state
	# f: Z × (Σ ∪ {ε}) × Δ  →  Z × Δ*
	f::Dict{Tuple{State, Char, Char}, Tuple{State, String}}  
end

# Non-deterministic Pushdown Automaton (NPDA)
Base.@kwdef struct NPDA
	initial_state::State  # start state
	# f: Z × (Σ ∪ {ε}) × Δ  →  P(Z × Δ*)
	f::Dict{Tuple{State, Char, Char}, Vector{Tuple{State, String}}}  
end

function execute_dpda(dpda::DPDA, input::String)::Bool
	z = dpda.initial_state
	stack::Vector{Char} = []  # stack
	i = 1
	while i ≤ length(input) || !isempty(stack)
		c = i ≤ length(input) ? input[i] : 'ε'
		i += 1
		top = '⊥' # empty stack symbol
		if !isempty(stack)
			# pop the top of the stack
			top = pop!(stack)  # remove top of stack
		end
		
		if haskey(dpda.f, (z, c, top))
			z´, symbols = dpda.f[(z, c, top)]
			println("f($z, $c, $top)  ⟹  $z´, $symbols")
			z = z´
			# push symbols onto the stack
			for symbol ∈ symbols
				if symbol != 'ε'
					push!(stack, symbol)
				end
			end
			println("Stack: ", stack, '\n')
		else
			println("no rule for state $z, character $c and stacktop $top found.")
			println("input rejected\n")
			return false  # invalid character
		end
	end
	println("Final state: $z, Stack: ", stack)
	if isempty(stack)
		println("input accepted\n")
		return true  # input accepted
	else
		println("input rejected\n")
		return false  # input not accepted
	end
end

function has_empty_stack(states::Vector{Tuple{State, Vector{Char}}})
	if isempty(states)
		return true  # no states, empty stack
	end
	for (_, stack) ∈ states
		if isempty(stack)
			return true  # at least one state has a non-empty stack
		end
	end
	return false  # all states have an empty stack
end

function execute_npda(npda::NPDA, input::String)::Bool
	states::Vector{Tuple{State, Vector{Char}}} = [(npda.initial_state, [])]
	i = 1
	while i ≤ length(input) || !has_empty_stack(states)
		c = i ≤ length(input) ? input[i] : 'ε'
		i += 1
		println("")
		display(states)
		next_states::Vector{Tuple{State, Vector{Char}}} = []
		for (z, stack) ∈ states
			top = '⊥' # empty stack symbol
			if !isempty(stack)
				# pop the top of the stack
				top = pop!(stack)  # remove top of stack
			end
			# check if there is a rule for the current state, character and stack top
			if haskey(npda.f, (z, c, top))
				statesNsymbols = npda.f[(z, c, top)]
				println("f($z, $c, $top)  ⟹  $statesNsymbols")
				# iterate over all next states and symbols
				for (z´, symbols) ∈ statesNsymbols
					# push the new state and stack onto the next state
					next_stack = copy(stack)
					# push symbols onto the stack
					for symbol ∈ symbols
						if symbol != 'ε'
							push!(next_stack, symbol)
						end
					end
					push!(next_states, (z´, next_stack))
				end
			end
			states = next_states
		end
	end
	println("")
	display(states)
	for (_, stack) ∈ states
		if isempty(stack)
			println("input accepted\n")
			return true  # input accepted
		end
	end
		println("input rejected\n")
		return false  # input not accepted
end