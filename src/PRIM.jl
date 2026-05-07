export MIN, PR, SUB, SIM2, SIM3, SIM4, ID, LV, ZV, I, C, S, md

import Base: sum, prod

"""
MIN(φ) = the least y such that φ(args..., y) = 0
"""
function MIN(φ::Function)
  return function (xs...)
    y = 0
    while φ(xs..., y) != 0
      y = y + 1
    end
    return y
  end
end

"""
PR(φ, ψ) = primitive recursion with IA φ and IS ψ
"""
function PR(φ::Function, ψ::Function)
  return function (args...)
    xs = args[1:end-1]
    y = args[end]
    if y == 0
      return φ(xs...)
    else
      return ψ(xs..., y - 1, PR(φ, ψ)(xs..., y - 1))
    end
  end
end

"""
SUB(φ, ψ)(x1, ..., xk, y1, ..., ym) = φ(x1, ..., xk, ψ(y1, ..., ym))
"""
function SUB(φ::Function, ψ::Function)
  m = minimum(met.nargs - 1 for met in methods(ψ) if !met.isva)
  return function (args...)
    k = length(args) - m
    return φ(args[1:k]..., ψ(args[k+1:end]...))
  end
end

function SIM2(φ::Function, ψ1::Function, ψ2::Function)
  return function (xs...)
    return φ(ψ1(xs...), ψ2(xs...))
  end
end

function SIM3(φ::Function, ψ1::Function, ψ2::Function, ψ3::Function)
  return function (xs...)
    return φ(ψ1(xs...), ψ2(xs...), ψ3(xs...))
  end
end

function SIM4(φ::Function, ψ1::Function, ψ2::Function, ψ3::Function, ψ4::Function)
  return function (xs...)
    return φ(ψ1(xs...), ψ2(xs...), ψ3(xs...), ψ4(xs...))
  end
end

function ID(φ::Function)
  return function (args...)
    xn = args[end]
    return φ(args..., xn)
  end
end

function LV(φ::Function)
  return function (args...)
    n = length(args)
    prefix = args[1:n-2]
    return φ(prefix..., args[n], args[n-1])
  end
end

function ZV(φ::Function)
  return function (x1, xs...)
    return φ(xs..., x1)
  end
end

"""
I^n_i = I(n,i)(x1, x2, ..., xn) = xi
"""
function I(n, i)
  return function (xs...)
    if length(xs) != n
      throw(ArgumentError("I(n, i) expects n arguments"))
    end
    return xs[i]
  end
end

"""
C^n_i = C(n,i)(x1, x2, ..., xn) = i
"""
function C(n, i)
  return function (xs...)
    if length(xs) != n
      throw(ArgumentError("C(n, i) expects n arguments"))
    end
    return i
  end
end

"""
Increment, S(x) = x + 1
"""
S(x) = x + 1

sum(x, y) = x + y

md(x, y) = max(x - y, 0)

prod(x, y) = x * y

function div(x, y)
  if y == 0
    return x
  else
    return x ÷ y
  end
end

exp(x, y) = x^y