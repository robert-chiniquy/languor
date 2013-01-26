local languor_prefix = 'languor:'

-- insert and add reverse index
local reverse_prefix = languor_prefix .. "reverse:"
local insert = function(set, ...) 
  redis.pcall('SADD', set, ...)
  for i=1, select('#', ...) do
    local item = select(i, ...)
    redis.pcall('SADD', reverse_prefix .. item, set)
  end
end

-- creates temporary sets out of tables of intermediate results
local temp_sets = {}
local temp_set_names = {}
local tmp_prefix = languor_prefix .. "tmp:"
local tmp = function(values) 
  local name = tmp_prefix .. (#temp_sets + 1)
  redis.pcall('SADD', name, unpack(values))
  table.insert(temp_sets, name)
  temp_set_names[name] = true
  return name
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

local reverse = function(one) 
  if (type(one) == 'string') then 
    return expand_set(reverse_prefix .. one)
  end
end

local flatten = function(one) 
  local function collect_tables(tables, one)
    if (type(one) == 'string') then collect_tables(tables, expand_set(one))
    elseif (type(one) == 'table') then
      for i=1,#one do
        local found = false
        for j=1, #tables do
          if (tables[j] == one[i]) then
            found = true
            break
          end
        end
        if (not found) then
          if (1 == redis.pcall('EXISTS', one[i])) then
            table.insert(tables, one[i])
            collect_tables(tables, expand_set(one[i]))
          end
        end
      end
    end
    return tables;
  end

  local tables = collect_tables({}, one)
  local result = redis.pcall('SUNION', unpack(tables))
  return diff(tmp(result), tmp(tables))
end


local flatten_up = function(one) 
  local function collect_tables(tables, one)
    if (type(one) == 'string') then collect_tables(tables, reverse(one))
    elseif (type(one) == 'table') then
      for i=1,#one do
        local found = false
        for j=1, #tables do
          if (tables[j] == one[i]) then
            found = true
            break
          end
        end
        if (not found) then
          if (1 == redis.pcall('EXISTS', one[i])) then
            table.insert(tables, one[i])
            collect_tables(tables, reverse(one[i]))
          end
        end
      end
    end
    return tables
  end

  local tables = collect_tables({}, one)
  return tables
end

local binary_op = function(one, op, two)
  if (type(one) == "table") then one = tmp(one) end
  if (type(two) == "table") then two = tmp(two) end
  if (op == "&") then return inter(one, two)
  elseif (op == "+") then return add(one, two)
  elseif (op == "-") then return diff(one, two)
  end
end

local unary_op = function(op, one)
  print(op, one)
  if (type(one) == 'table') then 
    one = tmp(one) 
  end
  if (op == '%') then return expand_set(one)
  elseif (op == '_') then return flatten(one)
  elseif (op == '?') then return reverse(one)
  end
end

local Space = lpeg.S(' \t')^0
local Open = "{" * Space
local Close = "}" * Space
local Comma = lpeg.P(',') * Space
local FactorOp = lpeg.C(lpeg.S("+-")) * Space
local TermOp = lpeg.C(lpeg.S("&")) * Space
local SetOp = lpeg.P('%') * Space
local FlattenOp = lpeg.P('_') * Space
local FlattenUpOp = lpeg.P('^') * Space
local ReverseOp = lpeg.P('?') * Space
local UnaryOp = SetOp + ReverseOp + FlattenOp + FlattenUpOp
local String = lpeg.C(lpeg.R('az', 'AZ', '09')^1) * Space
local SetLiteral = Open * lpeg.Cf(String * lpeg.Cg(Comma * String)^0, tmp) * Close
local Set = lpeg.Cf(UnaryOp * String, unary_op) + SetLiteral

local G = lpeg.P{ "Exp",
  Exp = lpeg.Cf(lpeg.V"Factor" * lpeg.Cg(FactorOp * lpeg.V"Factor")^0, binary_op);
  Factor = lpeg.Cf(lpeg.V"Parents" * lpeg.Cg(TermOp * lpeg.V"Parents")^0, binary_op);
  Parents = lpeg.Cg(FlattenUpOp^1 * lpeg.V"Leaves") / flatten_up + lpeg.V"Leaves";
  Leaves = lpeg.Cg(FlattenOp^1 * lpeg.V"Set") / flatten + lpeg.V"Set";
  Set = lpeg.Cg(SetOp^1 * lpeg.V"RevTerm") / expand_set + lpeg.V"RevTerm";
  RevTerm = lpeg.Cg(ReverseOp^1 * lpeg.V"Term") / reverse + lpeg.V"Term";
  Term = String + Open * lpeg.V"Exp" * Close;
}

local eval = function(languor) 
  local ret = lpeg.match(G, languor)
  if (temp_set_names[ret]) then
    ret = expand_set(ret)
  end
  redis.pcall('DEL', unpack(temp_sets))
  return ret
end

