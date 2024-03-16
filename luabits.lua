local Bit = {
    as_decimal = 0,
    as_bits_str = "",
    as_bits = {},
}

function Bit:__tostring(t)
    return self.as_bits_str
    -- return inspect(self)
end

function Bit:__add(other)
    local wrap_sum = (self.as_decimal + other.as_decimal) % 256
    return Bit:from_decimal(wrap_sum)
end

function Bit:__sub(other)
    local wrap_sum = (self.as_decimal - other.as_decimal)
    if wrap_sum < 0 then
        wrap_sum = 256 + wrap_sum
    end
    print(wrap_sum)
    return Bit:from_decimal(wrap_sum)
end

function Bit:from_bits(bits)
    assert(type(bits) == "table", "expected table, got " .. type(bits))
    assert(#bits <= 8 and #bits >= 0, string.format("invalid size %s: min=0, max=8", #bits))

    local bits_with_zeros = {}
    for _ = 1, 8 do
        table.insert(bits_with_zeros, 0)
    end

    for i = 1, #bits do
        local bit = bits[8 - #bits_with_zeros + i]
        assert(bit == 1 or bit == 0, "expected binary, got " .. bit)
        bits_with_zeros[i] = bit
    end
    local o = {
        as_bits = bits_with_zeros
    }

    local result = 0
    for i = 1, #bits_with_zeros do
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
    for i = 1, #str do
        table.insert(as_bits, tonumber(str:sub(i, i)))
    end
    return Bit:from_bits(as_bits)
end

function Bit:from_decimal(decimal)
    assert(type(decimal) == "number", "invalid decimal of type " .. type(decimal))
    assert(tonumber(tostring(decimal), 10), "invalid type: should be integer")
    assert(decimal >= 0 and decimal < 256, "invalid range: use [0,255]")

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

    return Bit:from_bits(bits)
end

function Bit:print_bits()
    print(self.as_bits)
end

function Bit:b_and(other)
    local a = self.as_decimal
    local b = other.as_decimal
    local a_and_b = a & b
    return Bit:from_decimal(a_and_b)
end

function Bit:b_or(other)
    local a = self.as_decimal
    local b = other.as_decimal
    local a_and_b = a|b
    return Bit:from_decimal(a_and_b)
end

function Bit:b_xor(other)
    local a = self.as_decimal
    local b = other.as_decimal
    local a_and_b = a ~ b
    return Bit:from_decimal(a_and_b)
end

function Bit:b_not()
    local copy = {}
    for i = 1, #self.as_bits do
        table.insert(copy, 1 - self.as_bits[i])
    end
    return Bit:from_bits(copy)
end

function Bit:b_shiftL(amount)
    local copy_str = self.as_bits_str
    local shifted = string.sub(copy_str, amount + 1, 8)
    shifted = shifted .. string.rep("0", 8 - #shifted)
    return Bit:from_string(shifted)
end

function Bit:b_shiftR(amount)
    local copy_str = self.as_bits_str:reverse()
    local shifted = string.sub(copy_str, amount + 1, 8)
    shifted = shifted .. string.rep("0", 8 - #shifted)
    return Bit:from_string(shifted:reverse())
end

return Bit
