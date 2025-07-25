export dya, dya⁻¹

"""
Convert an integer to a dyadic code.

````julia
"0" -> "ε"
"1" -> "1"
"2" -> "2"
"3" -> "11"
````
"""
function dya(n::Integer)::String
  if n ≤ 0
      return "ε"
  end
  result = ""
  while n > 0
      if n % 2 == 0
          result = "2" * result
          n = n - 2
      else
          result = "1" * result
          n = n - 1
      end
      n = n ÷ 2 
  end
  return result
end

"""
Convert a dyadic code to an integer.

````julia
"111" -> 7
"ε" -> 0
"1" -> 1
"2" -> 2
"11" -> 3
````
"""
function dya⁻¹(s::String)::Integer
	if s == "ε" || s == ""
		return 0
	end
  n = 0
  for c ∈ s
    n = n * 2
    if c == '1'
      n += 1
    elseif c == '2'
      n += 2
    end
  end
  return n
end