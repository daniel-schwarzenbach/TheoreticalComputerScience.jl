using TheoreticalComputerScience
using Test

@testset "dya" begin
	# Write your tests here.
	@test dya(0) == "ε"
	@test dya(1) == "1"
	@test dya(2) == "2"
	@test dya(3) == "11"
	@test dya⁻¹("ε") == 0
	@test dya⁻¹("1") == 1
	@test dya⁻¹("2") == 2
	@test dya⁻¹("11") == 3
	@test dya⁻¹("111") == 7
	@test dya⁻¹("222") == 14
end

@testset "TM1" begin
	# Write your tests here.
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
	execute_tm(M, "abbabba")
	execute_1tm(M, "abbabba")
end

@testset "TMK" begin
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
  execute_tm(M, "abb");
end

@testset "EA" begin
	# regex: a+b+
	AB = DEA(initial_state = "za", accepting_states = ["zb"], f = Dict([
		("za", 'a') => "za",
		("za", 'b') => "zb",
		("zb", 'b') => "zb"
	]))
	@test execute_dea(AB, "aabbbb") == true
	@test execute_dea(AB, "ababa") == false

	# regex: c+ | a+c*b* | a+b*c*
	ABC = NEA(initial_states = ["za"], accepting_states = ["zb","zc"], f = Dict([
		("za", 'a') => ["za", "zb", "zc"],
		("zb", 'b') => ["zb"],
		("zb", 'c') => ["zc"],
		("zc", 'c') => ["zc"],
		("za", 'c') => ["zb", "zc"]
	]))
	@test execute_nea(ABC, "aaabbc") == true
	@test execute_nea(ABC, "aaabbcaa") == false
end

@testset "PDA" begin
	# abba | abba
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
	]))
	@test execute_dpda(dpda, "aab|baa") == true
	@test execute_dpda(dpda, "aab|bba") == false


	# abba abba
	npda = NPDA(initial_state = "z1", f = Dict([
		("z1", 'a', '⊥') => [("z1", "A")],
		("z1", 'b', '⊥') => [("z1", "B")],
		("z1", 'a', 'A') => [("z1", "AA"), ("z2", "AA")],
		("z1", 'a', 'B') => [("z1", "BA"), ("z2", "BA")],
		("z1", 'b', 'A') => [("z1", "AB"), ("z2", "AB")],
		("z1", 'b', 'B') => [("z1", "BB"), ("z2", "BB")],
		# second part
		("z2", 'a', 'A') => [("z2", "")],
		("z2", 'b', 'B') => [("z2", "")]
	]))
	@test execute_npda(npda, "aabbaa") == true
	@test execute_npda(npda, "aabbba") == false
end

# RAM tests
@testset "RAM" begin
	# Test RAM code execution
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

	set_registers!([9, 0, 0, 0, 0])
	execute_ramfile("./test.ram")
end

# Count tests
@testset "Count" begin
	# Test count function
	for i in 1:100
		k,j = n2nxn(i)
		@test nxn2n(k, j) == i
		@show i, j, k
	end
end