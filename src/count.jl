export n2nxn, nxn2n

"""
bijective function from ℕ -> ℕ²

```julia
> n2nxn(5)
(2, 1)
> nxn2n(2, 1)
5
```
"""
function n2nxn(n::Integer)::Tuple{Integer, Integer}
	if n < 0
		throw(ArgumentError("n must be a non-negative integer"))
	end
	if n == 0
		return (0, 0)
	end
	k = floor(Int, sqrt(n))
	m = n - k * k
	return (k, m)
end

"""
bijective function from ℕ² -> ℕ

```julia
> n2nxn(5)
(2, 1)
> nxn2n(2, 1)
5
```
"""
function nxn2n(x::Integer, y::Integer)::Integer
	if x < 0 || y < 0
		throw(ArgumentError("x and y must be non-negative integers"))
	end
	return x * x + y
end