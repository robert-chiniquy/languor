local Space = lpeg.S(' \t')^0
local String = lpeg.C(lpeg.R('az', 'AZ', '09')^1) * Space
local SetOp = lpeg.P('%') * Space
local FactorOp = lpeg.C(lpeg.S("+-")) * Space
local TermOp = lpeg.C(lpeg.S("&")) * Space
local Open = "{" * Space
local Close = "}" * Space
local Comma = lpeg.P(',') * Space

-- creates temporary sets out of tables of intermediate results
local temp_sets = {}
local tmp = function(values) 
  local name = "languor_tmp:" .. (#temp_sets + 1)
  redis.pcall('SADD', name, unpack(values))
  table.insert(temp_sets, name)
  return name
end

-- owns SMEMBERS
local expand_set = function(one) 
  if (type(one) == "string") then return redis.pcall('SMEMBERS', one)
  elseif (type(one) == "table") then 
    if (#one == 0) then return {} end
    local all = {}
    for i = 1, #one do
      local t = redis.pcall('SMEMBERS', one[i])
      for j = 1, #t do
        table.insert(all, t[j])
      end
    end
    return redis.pcall('SMEMBERS', tmp(all))
  end
end

local inter = function(one, two) 
  return redis.pcall('SINTER', one, two)
end

local add = function(one, two) 
  return redis.pcall('SUNION', one, two)
end

local diff = function(one, two) 
  return redis.pcall('SDIFF', one, two)
end

local binary_op = function(one, op, two)
  if (type(one) == "table") then one = tmp(one) end
  if (type(two) == "table") then two = tmp(two) end
  if (op == "&") then return inter(one, two)
  elseif (op == "+") then return add(one, two)
  elseif (op == "-") then return diff(one, two)
  end
end

local G = lpeg.P{ "Exp",
  Exp = lpeg.Cf(lpeg.V"Factor" * lpeg.Cg(FactorOp * lpeg.V"Factor")^0, binary_op);
  Factor = lpeg.Cf(lpeg.V"Set" * lpeg.Cg(TermOp * lpeg.V"Set")^0, binary_op);
  Set = lpeg.Cg(SetOp^1 * lpeg.V"Term") / expand_set + lpeg.V"Term";
  Term = String + Open * lpeg.V"Exp" * Close;
}

local eval = function(languor) 
  local ret = lpeg.match(G, languor)
  redis.pcall('DEL', unpack(temp_sets))
  return ret
end

return eval(table.concat(ARGV, ' '))
