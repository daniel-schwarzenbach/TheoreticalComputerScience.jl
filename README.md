# TheoreticalComputerScience

![](./doc/pic/TCS.gif)

[![Build Status](https://github.com/daniel-schwarzenbach/TheoreticalComputerScience.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/daniel-schwarzenbach/TheoreticalComputerScience.jl/actions/workflows/CI.yml?query=branch%3Amaster)

This package provides implementations of various theoretical computer science concepts in Julia, including:

- [**Turing Machines**](#turing-machines): A simple implementation of Turing machines.
- [**Pushdown Automata**](#pushdown-automata): A basic implementation of pushdown automata.
- [**Finite Atomata**](#finite-automata-ea): An implementation of finite automata.
- [**Random Access Machines**](#random-access-machines-ram): An implementation of random access machines.
- [**Dyadic Codes**](#dyadic-codes): Functions to convert between dyadic codes and integers.
- [**Count Functions**](#count-functions): Bijective functions to convert between natural numbers and pairs of natural numbers.

## Installation

To install the package, use the Julia package manager:

``` julia
using Pkg
Pkg.add(url="https://github.com/daniel-schwarzenbach/TheoreticalComputerScience.jl")
```

### Usage

``` julia
using TheoreticalComputerScience
```

## Turing Machines

### TMK

You can create a Turing machine with $k$ bands.

- `no_bands`: The number of bands.
- `initial_state`: The initial state.
- `final_state`: The final state.
- `f`: `Tuple{String, Vector{Char}} => Tuple{String, Vector{Char}, Vector{Movement}}`

`□`: Represents the blank symbol.

``` julia
M = TMK(no_bands = 2, initial_state = "z0", final_state = "z1", f = Dict([
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
```

to execute the Turing machine, you can use the `execute_tm` function:

``` julia
execute_tm(M, "abb")
```

this will then execute the Turing machine on the input string "abb" and print the steps taken by the machine.

``` default
abb
↑
□□□
↑
⤷ f(z0,['a', '□'])  ⟶  (z0, ['a', 'a'], [R, R]) 

abb
 ↑
a□□
 ↑
⤷ f(z0,['b', '□'])  ⟶  (z0, ['b', 'b'], [R, R])

abb
  ↑
ab□
  ↑
⤷ f(z0,['b', '□'])  ⟶  (z0, ['b', 'b'], [R, R])

abb□
   ↑
abb□
   ↑
⤷ f(z0,['□', '□'])  ⟶  (z2, ['□', '□'], [O, L])

... (continues until the final state is reached)
```

### TM1

You can create a Turing machine with just 1 band.

- `initial_state`: The initial state.
- `final_state`: The final state.
- `f`: `Tuple{String, Char} => Tuple{String, Char, Movement}`

`□`: Represents the blank symbol.

``` julia
M = TM1(initial_state = "z0", final_state = "z1", f = Dict([
  ("z0", 'a') => ("za", '□', :R),
  ("z0", '□') => ("z1", '□', :R),
  ("z0", 'b') => ("zb", 'b', :R),
  ("za", 'a') => ("za", 'a', :R),
  ("za", 'b') => ("za", 'b', :R),
  ("za", '□') => ("z´", 'a', :L),
  ("zb", 'a') => ("za", 'a', :R),
  ("zb", 'b') => ("za", 'b', :R),
  ("zb", '□') => ("z´", 'b', :L),
  ("z´", '□') => ("z1", '□', :R),
  ("z´", 'a') => ("z´", 'a', :L),
  ("z´", 'b') => ("z´", 'b', :L)
 ])
)
```

you can execute the Turing machine using the `execute_tm` function, or with the `execute_1tm` function if you want to test it with a 1-∞-sided Band and simulate an 1-TM

``` julia
# two-∞-sided Band
execute_tm(M, "abbabba")
# right-∞-sided Band
execute_1tm(M, "abbabba")
```

output will look like this:

``` default
abbabba ⟹  f(z0,a)  ⟶  (za,□,R)
↑
□bbabba ⟹  f(za,b)  ⟶  (za,b,R)
 ↑
□bbabba ⟹  f(za,b)  ⟶  (za,b,R)
  ↑
□bbabba ⟹  f(za,a)  ⟶  (za,a,R)
   ↑
□bbabba ⟹  f(za,b)  ⟶  (za,b,R)
    ↑
□bbabba ⟹  f(za,b)  ⟶  (za,b,R)
     ↑
□bbabba ⟹  f(za,a)  ⟶  (za,a,R)
      ↑
□bbabba□ ⟹  f(za,□)  ⟶  (z´,a,L)
       ↑
□bbabbaa ⟹  f(z´,a)  ⟶  (z´,a,L)
      ↑
□bbabbaa ⟹  f(z´,b)  ⟶  (z´,b,L)
     ↑
□bbabbaa ⟹  f(z´,b)  ⟶  (z´,b,L)
    ↑
□bbabbaa ⟹  f(z´,a)  ⟶  (z´,a,L)
   ↑
□bbabbaa ⟹  f(z´,b)  ⟶  (z´,b,L)
  ↑
□bbabbaa ⟹  f(z´,b)  ⟶  (z´,b,L)
 ↑
□bbabbaa ⟹  f(z´,□)  ⟶  (z1,□,R)
↑

final state z1 reached!
```

## Pushdown Automata

PDA come in two variants: Nondeterministic and Deterministic.

### Nondeterministic PD

You can create a nondeterministic pushdown automaton (NPDA) with the following parameters:

- `initial_state`: The initial state.
- `f`: `Tuple{String, Char, Char} => Vector{Tuple{String, String}}`

`ε`: Represents the empty string/character.

``` julia
# acept all palindromes
npda = NPDA(initial_state = "z1", f = Dict([
  ("z1", 'a', '⊥') => [("z1", "A")],
  ("z1", 'b', '⊥') => [("z1", "B")],
  ("z1", 'a', 'A') => [("z1", "AA"), ("z2", "AA")],
  ("z1", 'a', 'B') => [("z1", "BA"), ("z2", "BA")],
  ("z1", 'b', 'A') => [("z1", "AB"), ("z2", "AB")],
  ("z1", 'b', 'B') => [("z1", "BB"), ("z2", "BB")],
  ("z2", 'a', 'A') => [("z2", "")],
  ("z2", 'b', 'B') => [("z2", "")]
 ])
)
```

to execute the NPDA, you can use the `execute_npda` function:

``` julia
execute_npda(npda, "aabbaa")
```

output will look like this:

``` default
1-element Vector{Tuple{String, Vector{Char}}}:
 ("z1", [])
f(z1, a, ⊥)  ⟹  [("z1", "A")]

1-element Vector{Tuple{String, Vector{Char}}}:
 ("z1", ['A'])
f(z1, a, A)  ⟹  [("z1", "AA"), ("z2", "AA")]

2-element Vector{Tuple{String, Vector{Char}}}:
 ("z1", ['A', 'A'])
 ("z2", ['A', 'A'])
f(z1, b, A)  ⟹  [("z1", "AB"), ("z2", "AB")]

2-element Vector{Tuple{String, Vector{Char}}}:
 ("z1", ['A', 'A', 'B'])
 ("z2", ['A', 'A', 'B'])
f(z1, b, B)  ⟹  [("z1", "BB"), ("z2", "BB")]
f(z2, b, B)  ⟹  [("z2", "")]

3-element Vector{Tuple{String, Vector{Char}}}:
 ("z1", ['A', 'A', 'B', 'B'])
 ("z2", ['A', 'A', 'B', 'B'])
 ("z2", ['A', 'A'])
f(z1, a, B)  ⟹  [("z1", "BA"), ("z2", "BA")]
f(z2, a, A)  ⟹  [("z2", "")]

3-element Vector{Tuple{String, Vector{Char}}}:
 ("z1", ['A', 'A', 'B', 'B', 'A'])
 ("z2", ['A', 'A', 'B', 'B', 'A'])
 ("z2", ['A'])
f(z1, a, A)  ⟹  [("z1", "AA"), ("z2", "AA")]
f(z2, a, A)  ⟹  [("z2", "")]
f(z2, a, A)  ⟹  [("z2", "")]

4-element Vector{Tuple{String, Vector{Char}}}:
 ("z1", ['A', 'A', 'B', 'B', 'A', 'A'])
 ("z2", ['A', 'A', 'B', 'B', 'A', 'A'])
 ("z2", ['A', 'A', 'B', 'B'])
 ("z2", [])
input accepted
```

### Deterministic PDA

You can create a deterministic pushdown automaton (DPDA) with the following parameters:

- `z_0`: The initial state.
- `f`: `Tuple{String, Char, Char} => Tuple{String, String}`

`ε`: Represents the empty string/character.

``` julia
# acept all palindromes that are separated by a '|'
dpda = DPDA(initial_state = "z1", f = Dict([
  ("z1", 'a', '⊥') => ("z1", "A"),
  ("z1", 'b', '⊥') => ("z1", "A"),
  ("z1", 'a', 'A') => ("z1", "AA"),
  ("z1", 'a', 'B') => ("z1", "BA"),
  ("z1", 'b', 'A') => ("z1", "AB"),
  ("z1", 'b', 'B') => ("z1", "BB"),
  ("z1", '|', 'A') => ("z2", "A"),
  ("z1", '|', 'B') => ("z2", "B"),
  ("z2", 'a', 'A') => ("z2", ""),
  ("z2", 'b', 'B') => ("z2", "")
 ])
)
```

to execute the DPDA, you can use the `execute_dpda` function:

``` julia
execute_dpda(dpda, "aab|baa")
```

output will look like this:

``` default
f(z1, a, ⊥)  ⟹  z1, A
Stack: ['A']

f(z1, a, A)  ⟹  z1, AA
Stack: ['A', 'A']

f(z1, b, A)  ⟹  z1, AB
Stack: ['A', 'A', 'B']

f(z1, |, B)  ⟹  z2, B
Stack: ['A', 'A', 'B']

f(z2, b, B)  ⟹  z2,
Stack: ['A', 'A']

f(z2, a, A)  ⟹  z2,
Stack: ['A']

f(z2, a, A)  ⟹  z2,
Stack: Char[]

Final state: z2, Stack: Char[]
input accepted
```

## Finite Automata (EA)

EA come in two variants: Nondeterministic and Deterministic.

### Deterministic EA

You can create a deterministic finite automaton (DFA) with the following parameters:

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

output will look like this:

``` default
f(za,a)  ⟹  za
f(za,a)  ⟹  za
f(za,b)  ⟹  zb
f(zb,b)  ⟹  zb
f(zb,b)  ⟹  zb
f(zb,b)  ⟹  zb
Final state: zb
input accepted
```

### Nondeterministic EA

You can create a nondeterministic finite automaton (NFA) with the following parameters:

- `initial_state`: The initial state.
- `accepting_states`: The accepting states.
- `f`: `Tuple{String, Char} => Vector{String}`

``` julia
# regex: c+ | a+c*b* | a+b*c*
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

output will look like this:

``` default
f(["za"],a)  ⟹  ["za", "zb", "zc"]
f(["za", "zb", "zc"],a)  ⟹  ["za", "zb", "zc"]
f(["za", "zb", "zc"],a)  ⟹  ["za", "zb", "zc"]
f(["za", "zb", "zc"],b)  ⟹  ["zb"]
f(["zb"],b)  ⟹  ["zb"]
f(["zb"],c)  ⟹  ["zc"]
input accepted
```

## Random Access Machines (RAM)

You can create a random access machine (RAM) and execute them:

`test.ram:`

``` ram
0   R2 ← 1
1   R1 ← R0
2   R0 ← 0
3   IF R1 = 0 GOTO 8
4   R1 ← R1 − R0
5   R0 ← R0 + R2
6   R1 ← R1 − R0
7   GOTO 3
```

One can execute the File with:

``` julia
set_registers!([9, 0, 0, 0, 0])
execute_ramfile("./test.ram")
```

output will look like this:

``` default
0: R2 ← 1              ⟹  R = [9, 0, 1, 0, 0]
1: R1 ← R0             ⟹  R = [9, 9, 1, 0, 0]
2: R0 ← 0              ⟹  R = [0, 9, 1, 0, 0]
3: IF R1 = 0 GOTO 8    ⟹  R = [0, 9, 1, 0, 0]
4: R1 ← R1 − R0        ⟹  R = [0, 9, 1, 0, 0]
5: R0 ← R0 + R2        ⟹  R = [1, 9, 1, 0, 0]
6: R1 ← R1 − R0        ⟹  R = [1, 8, 1, 0, 0]
7: GOTO 3              ⟹  R = [1, 8, 1, 0, 0]
3: IF R1 = 0 GOTO 8    ⟹  R = [1, 8, 1, 0, 0]
4: R1 ← R1 − R0        ⟹  R = [1, 7, 1, 0, 0]
5: R0 ← R0 + R2        ⟹  R = [2, 7, 1, 0, 0]
6: R1 ← R1 − R0        ⟹  R = [2, 5, 1, 0, 0]
7: GOTO 3              ⟹  R = [2, 5, 1, 0, 0]
3: IF R1 = 0 GOTO 8    ⟹  R = [2, 5, 1, 0, 0]
4: R1 ← R1 − R0        ⟹  R = [2, 3, 1, 0, 0]
5: R0 ← R0 + R2        ⟹  R = [3, 3, 1, 0, 0]
6: R1 ← R1 − R0        ⟹  R = [3, 0, 1, 0, 0]
7: GOTO 3              ⟹  R = [3, 0, 1, 0, 0]
3: IF R1 = 0 GOTO 8    ⟹  Final register state: [3, 0, 1, 0, 0]
```

One can also write a RAM program in Julia and execute it:

``` julia
set_registers!([8, 4, 0, 0])
execute_ramcode([
 # ⌊R0 / R1⌋
 "IF R1 = 0 GOTO 7", # 0
 "R2 <- 1", # 1
 "R0 <- R0 + R2", # 2
 "R0 <- R0 - R1", # 3
 "R3 <- R3 + R2", # 4
 "IF R0 = 0 GOTO 7", # 5
 "GOTO 3", # 6
 "R0 <- R3 - R2", # 7
 "STOP" # 8
])
```

## Dyadic Codes

Dyadic codes are a way to represent natural numbers in a binary-like format that is bijective. The package provides functions to convert between dyadic codes and integers.

| x   | dya(x) |
|-----|--------|
| 0   | ε      |
| 1   | 1      |
| 2   | 2      |
| 3   | 11     |
| 4   | 12     |

```julia
> dya(0)
"ε"
> dya⁻¹("222")
14
```

## Count Functions

`n2nxn` is a bijective function that maps natural numbers to pairs of natural numbers, and `nxn2n` is its inverse.

```julia
> n2nxn(5)
(2, 1)
> nxn2n(2, 1)
5
```