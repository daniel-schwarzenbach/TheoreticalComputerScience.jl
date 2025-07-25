export set_registers!, execute_ramcode, execute_ramfile

# registers
R = Vector{Integer}([])

# execute a = "Ri" <- value
function set_value(a::String, value::Int)
    # a = RRi
    if startswith(a, "RR")
        m = match(r"RR(\d+)", a)
        i = parse(Int , m.captures[1])
        R[R[i+1]+1] = value
    elseif startswith(a, "R")
        m = match(r"R(\d+)", a)
        i = parse(Int, m.captures[1])
        R[i+1] = value
    else
        @error "no assignment for: $a <- value"
    end
end

"""
evaluate an expression:

i,j,k ∈ ℕ
````
RRi
Ri + Rj
Ri - Rj
Ri
k 
````
"""
function eval_expr(expr::String)::Int
    if startswith(expr, "RR")
        m = match(r"RR(\d+)", expr)
        i = parse(Int, m.captures[1])
        return R[R[i+1]+1]
    elseif startswith(expr, r"\s*R(\d+)\s*\+\s*R(\d+)\s*")
        m = match(r"\s*R(\d+)\s*\+\s*R(\d+)\s*", expr)
        i =  parse(Int, m.captures[1])
        j = parse(Int, m.captures[2])
        return R[i+1] + R[j+1]
    elseif startswith(expr, r"\s*R(\d+)\s*(-|−)\s*R(\d+)\s*")
        m = match(r"\s*R(\d+)\s*(-|−)\s*R(\d+)\s*", expr)
        i = parse(Int, m.captures[1])
        j = parse(Int, m.captures[3])
        return max(R[i+1] - R[j+1], 0)
    elseif startswith(expr, r"\s*R(\d+)\s*(-|−)\s*(\d+)\s*")
        m = match(r"\s*R(\d+)\s*(-|−)\s*(\d+)\s*", expr)
        i = parse(Int, m.captures[1])
        j = parse(Int, m.captures[3])
        return max(R[i+1] - j, 0)
      elseif startswith(expr, r"\s*R(\d+)\s*\+\s*(\d+)\s*")
        m = match(r"\s*R(\d+)\s*\+\s*(\d+)\s*", expr)
        i = parse(Int, m.captures[1])
        j = parse(Int, m.captures[2])
        return R[i+1] + j
    elseif startswith(expr, "R")
        m = match(r"R(\d+)", expr)
        i = parse(Int, m.captures[1])
        return R[i+1]
    else
        return parse(Int, expr)
    end
end

function execute_ramcode(code::Vector{String})
    # Program counter
    pc = 0
    while pc < length(code)
        line::String = code[pc+1]
        @show R
        let txt = rpad(line, 18)  # pads with spaces to length 20
          print("\033[1;33m$pc: $txt\033[0m")
        end
        print("  ⟹  ")
        # test for STOP
        if startswith(line, "STOP")
            break
        end
        # test for goto
        if startswith(line, "GOTO")
            m = match(r"GOTO\s+(\w+)", line)
            pc = eval_expr(String(m.captures[1]))
            continue
        end
        # test for IF
        if startswith(line, "IF")
            m = match(r"IF\s+(\w+)\s*(=|<|>|>=|<=)\s*(\w+)\s+GOTO\s+(\w+)", line)
            a = eval_expr(String(m.captures[1]))
            op = String(m.captures[2])
            b = eval_expr(String(m.captures[3]))
            c = eval_expr(String(m.captures[4]))
            if op == "="  && a == b
              pc = c
            elseif op == "<"  && a < b
              pc = c
            elseif op == "<="  && a <= b
              pc = c
            elseif op == ">"  && a > b
              pc = c
            elseif op == ">="  && a >= b
              pc = c
            else
              pc += 1
            end
            continue
        end
        # test for assignment
        m = match(r"(\w+)\s+(<-|←)\s+(.+)", line)
        if m !== nothing
            value = eval_expr(String(m.captures[3]))
            set_value(String(m.captures[1]), value)
        else
            @error "no assignment for: $line"
        end
        # increment program counter
        pc += 1
    end#while
    println("Final register state: $R \n")
end

"""
Set the initial values of the registers.
````julia
set_registers!([8, 4, 0, 0]) => # R0 = 8, R1 = 4, R2 = 0, R3 = 0
````
"""
function set_registers!(new_R::Vector{Int})
  global R = new_R
end

function fill_in_ram(code::Vector{String})
    for line ∈ code
        m = match(r"(\w+)\s*=\s*(\d+)", line)
        b = parse(Int, m.captures[2])
        set_value(String(m.captures[1]), b)
    end
end

"""
Execute a RAM file.

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

this will then execute the code line by line.
"""
function execute_ramfile(file::String) 
	lines = readlines(file)
	cleaned_lines::Vector{String} = []
	# remove all comments and line numbers
	for line ∈ lines
		if startswith(line, "#") || isempty(line)
			continue  # skip comments and empty lines
		end
		m = match(r"\d*\s*(.*)", line)
		if m === nothing
			push!(cleaned_lines, line)  # no match, keep the line
		end
		push!(cleaned_lines, String(m.captures[1]))
	end
	execute_ramcode(cleaned_lines)
end