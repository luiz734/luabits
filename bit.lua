local inspect = require 'inspect'
show = function (x)
   print(inspect(x))
end

Bit = {
    as_decimal = 0,
    as_bits_str = "",
    as_bits = {},
}

function Bit:__tostring(t)
    -- return self.as_bits_str
    return inspect(self)
end

function Bit:from_bits(bits)
    assert(type(bits) == "table", "expected table, got " .. type(bits))
    assert(#bits <= 8 and #bits >= 0, string.format("invalid size %s: min=0, max=8", #bits))

    local bits_with_zeros = {}
    for _ = 1, 8 do
        table.insert(bits_with_zeros, 0)
    end

    for i=1, #bits do
        local bit = bits[8 - #bits_with_zeros + i]
        assert(bit == 1 or bit == 0, "expected binary, got " .. bit)
        bits_with_zeros[i] = bit
    end
    local o = {
        as_bits = bits_with_zeros
    }

    local result = 0
    for i=1, #bits_with_zeros do
        local bit_value = tonumber(bits_with_zeros[i])
        local decimal_value = bit_value << (#bits_with_zeros - i)
        result = result + decimal_value
    end

    o.as_decimal = result

    o.as_bits_str = ""
    for _, b in ipairs(bits_with_zeros) do
        o.as_bits_str = o.as_bits_str .. tostring(b)
    end

    setmetatable(o, self)
    self.__index = self
    return o
end

function Bit:from_string(str)
    local as_bits = {}
    for i=1, #str do
        table.insert(as_bits, tonumber(str:sub(i, i)))
    end
    return Bit:from_bits(as_bits)
end

function Bit:from_decimal(decimal)
    assert(type(decimal) == "number", "invalid decimal of type " .. type(decimal))
    assert(tonumber(tostring(decimal), 10), "invalid type: should be integer")
    assert(decimal >= 0 and decimal < 256, "invalid range: use [0,255]")

    local o = {
        as_decimal = decimal
    }

    local bits = {}
    for _ = 1, 8 do
        table.insert(bits, 0)
    end
    local i = 8
    local tmp = decimal
    while tmp > 0 do
        local remainder = tmp % 2
        bits[i] = remainder
        tmp = math.floor(tmp / 2)
        i = i - 1
    end
    if #bits == 0 then
        table.insert(bits, 0)
    end
    o.as_bits = bits

    o.as_bits_str = ""
    for _, b in ipairs(bits) do
        o.as_bits_str = o.as_bits_str .. tostring(b)
    end

    setmetatable(o, self)
    self.__index = self
    return o
end

function Bit:print_bits()
    print(self.as_bits)
end

-- function Bit:and(other)
--     local output
-- end

local a = Bit:from_decimal(4)
local b = Bit:from_bits({1, 1, 0, 1, 1, 1, 1, 1})
local c = Bit:from_string("11111111")
print(a)
print(b)
print(c)

-- local function bits_to_decimal(bits)
--     return result
-- end
-- assert(bits_to_decimal{1, 1, 1, 1} == 15)
-- assert(bits_to_decimal{0, 0, 0, 0} == 0)
-- assert(bits_to_decimal{1, 1, 0, 0} == 12)
-- assert(bits_to_decimal{1, 0, 1, 1} == 11)
--
-- local function sample_bits(bits, amount)
--     assert(amount <= #bits)
--     local out = {}
--     for i=1, amount do
--         out[i] = bits[i]
--     end
--     return out
-- end
--
-- local function mask_bits(bits, mask)
--     -- local bits_decimal = bits_to_decimal(bits)
--     return tonumber(mask & bits)
-- end
--
-- local a = {1, 1, 0, 1}
-- local b = {1, 0, 0, 1}
--
-- local x1 = mask_bits(10, 2)
-- print(x1)
--
--
--
