include("State.jl")

export TMK, TM1, Movement, execute_tm, execute_1tm

# Define movement symbols
const Left = :L
const Right = :R  
const Stay = :O

# Define Movement type as Union of symbols
Movement = Union{typeof(Left), typeof(Right), typeof(Stay)}

# show a single Movement just as its name
function Base.show(io::IO, m::Movement)
  print(io, string(m))
end

# show a Vector of Movement as “[L, O, …]”
function Base.show(io::IO, v::Vector{Movement})
  print(io, "[" * join(string.(v), ", ") * "]")
end

# Multy Band TuringMaschine
"""
no_bands: Number of bands\n
initial_state: Start state\n
final_state: End state\n
f: Transition function
````julia
M = TMK(k = 2, z_0 = "z0", z_e = "z1", f = Dict([
		#z0
		("z0", ['a','□']) => ("z0", ['a','a'], [:R, :R]),
		("z0", ['b','□']) => ("z0", ['b','b'], [:R, :R]),
		("z0", ['□','□']) => ("z2", ['□','□'], [:O, :L]),
		# z2
		("z2", ['□','b']) => ("z2", ['b','□'], [:R, :L]),
		("z2", ['□','a']) => ("z2", ['a','□'], [:R, :L]),
		("z2", ['□','□']) => ("z3", ['□','□'], [:L, :O]),
		# z3
		("z3", ['a','□']) => ("z3", ['a','□'], [:L, :O]),
		("z3", ['b','□']) => ("z3", ['b','□'], [:L, :O]),
		("z3", ['□','□']) => ("z1", ['□','□'], [:R, :O])
  ])
)
execute_tm(M, "abb");
````
"""
Base.@kwdef struct TMK
  # Anzahl der Bänder
  no_bands::Int
  # Startzustand
  initial_state::State
  # Endzustand
  final_state::State
  # Überführungsfunktion
  f::Dict{Tuple{State, Vector{Char}}, # ⟹
          Tuple{State, Vector{Char}, Vector{Movement}}}
end

"""
initial_state: Start state\n
final_state: End state\n
f: Transition function
````julia
M = TMK(k = 2, z_0 = "z0", z_e = "z1", f = Dict([
    #z0
    ("z0", ['a','□']) => ("z0", ['a','a'], [:R, :R]),
    ("z0", ['b','□']) => ("z0", ['b','b'], [:R, :R]),
    ("z0", ['□','□']) => ("z2", ['□','□'], [:O, :L]),
    # z2
    ("z2", ['□','b']) => ("z2", ['b','□'], [:R, :L]),
    ("z2", ['□','a']) => ("z2", ['a','□'], [:R, :L]),
    ("z2", ['□','□']) => ("z3", ['□','□'], [:L, :O]),
    # z3
    ("z3", ['a','□']) => ("z3", ['a','□'], [:L, :O]),
    ("z3", ['b','□']) => ("z3", ['b','□'], [:L, :O]),
    ("z3", ['□','□']) => ("z1", ['□','□'], [:R, :O])
  ])
)
execute_tm(M, "abb");
````
"""
Base.@kwdef struct TM1
  # Startzustand
  initial_state::State
  # Endzustand
	final_state::State
  # Überführungsfunktion
  f::Dict{Tuple{State, Char}, Tuple{State, Char, Movement}}
end

function execute_tm(tm::TMK, input::String)
  # Startzustand
  z = tm.initial_state
  # Bänder initialisieren
  band1::Vector{Char} = collect(input)
  band::Matrix{Char} =  fill('□', tm.no_bands, length(band1))
  band[1, :] = band1
  # Position auf dem Band
  pos::Vector = fill(1, tm.no_bands)
  while z != tm.final_state
    # Neue Zeichen einfügen?
    for i in 1:tm.no_bands
      while pos[i] < 1
        band = hcat(fill('□', tm.no_bands, 1), band)
        pos += ones(Int, tm.no_bands)
      end
      while pos[i] > size(band, 2)
        band = hcat(band, fill('□', tm.no_bands, 1))
      end
    end
    # Aktuelle Zeichen auf dem Band
    c::Vector{Char} = [pos[i] <= size(band, 2) ? band[i, pos[i]] : '□' for i ∈ 1:tm.no_bands]
    # Überführungsregel finden
    if haskey(tm.f, (z, c))
      (z´, c´, m) = tm.f[(z, c)]
      # Iteriere über alle Bänder
      for i ∈ 1:tm.no_bands
        # Zeige das Band mit den zeigern
        println(String(band[i, :]))
        # Aktuelle Position auf dem Band
        println(String(fill(' ', pos[i] - 1)), '↑')
        # Zeichen auf dem Band aktualisieren
        if pos[i] <= size(band, 2)
          band[i, pos[i]] = c´[i]
        else
          push!(band[i, :], c´[i])
        end
      end
      # Zeige die Aktuelle Regel
      println("⤷ f($z,$c)  ⟶  ($z´, $c´, $m) \n")
      # Zustand aktualisieren
      z = z´
      # Positionen aktualisieren
      for i ∈ 1:tm.no_bands
        if m[i] == Left::Movement
          pos[i] -= 1
        elseif m[i] == Right::Movement
          pos[i] += 1
        end
      end
    else
      @error "no rule for state $z and character $c found."
      break  # Keine Regel gefunden, TM stoppt
    end
  end

  println("final state $z reached!")
  for i ∈ 1:tm.no_bands
    println(String(band[i, :]))
    println(String(fill(' ', pos[i] - 1)), '↑')
  end
end

function execute_tm(tm::TM1, input::String)
  # Startzustand
  z = tm.initial_state
  # Band initialisieren
  band::Vector{Char} = collect(input)
  # Position auf dem Band
  pos = 1
  while z != tm.final_state
    # Neue Zeichen vorne einfügen?
    while pos < 1
      pushfirst!(band, '□')
      pos += 1
    end
    while pos > length(band)
      push!(band, '□')
    end
    # Aktuelles Zeichen auf dem Band
    c = band[pos]
    # Überführungsregel finden
    if haskey(tm.f, (z, c))
      (z´, c´, m) = tm.f[(z, c)]
      # Zeige das Band und die Aktuelle Regel
      println(String(band), " ⟹  f($z,$c)  ⟶  ($z´,$c´,$m)")
      # Aktuelle Position auf dem Band
      println(String(fill(' ', pos - 1)), '↑')
      # Zeichen auf dem Band aktualisieren
      if pos <= length(band)
        band[pos] = c´
      else
        push!(band, c´)
      end
      # Zustand aktualisieren
      z = z´

      # Position aktualisieren
      if m == Left::Movement
        pos = pos - 1
      elseif m == Right::Movement
        pos += 1
      end
    else
      @error "no rule for state $z and character $c found."
      break  # Keine Regel gefunden, TM stoppt
    end
  end
  # Ausgabe des Endzustands
  println("\nfinal state $z reached!")
  println(String(band))
  # Aktuelle Position auf dem Band
  println(String(fill(' ', pos - 1)), '↑')
end

function execute_1tm(_1tm::TM1, input::String)
  # Startzustand
  z = _1tm.initial_state
  # Band initialisieren
  band::Vector{Char} = collect(input)
  # Position auf dem Band
  pos = 1
  while z != _1tm.final_state
    # Neue Zeichen vorne einfügen?
    if pos < 1
      @error "position $pos is less than 1. Cannot continue."
      break
    end
    while pos > length(band)
      push!(band, '□')
    end
    # Aktuelles Zeichen auf dem Band
    c = band[pos]
    # Überführungsregel finden
    if haskey(_1tm.f, (z, c))
      (z´, c´, m) = _1tm.f[(z, c)]
      # Zeige das Band und die Aktuelle Regel
      println(String(band), " ⟹  f($z,$c) → ($z´,$c´,$m)")
      # Aktuelle Position auf dem Band
      println(String(fill(' ', pos - 1)), '↑')
      # Zeichen auf dem Band aktualisieren
      if pos <= length(band)
        band[pos] = c´
      else
        push!(band, c´)
      end
      # Zustand aktualisieren
      z = z´

      # Position aktualisieren
      if m == Left::Movement
        pos = pos - 1
      elseif m == Right::Movement
        pos += 1
      end
    else
      @error "no rule for state $z and character $c found."
      break  # Keine Regel gefunden, TM stoppt
    end
  end
  # Ausgabe des Endzustands
  println("\nfinal state $z reached!")
  println(String(band))
  # Aktuelle Position auf dem Band
  println(String(fill(' ', pos - 1)), '↑')
end