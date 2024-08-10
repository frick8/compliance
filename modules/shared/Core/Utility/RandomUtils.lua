---
-- @classmod RandomUtils
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local characters = {}
for i = 33, 126 do
    table.insert(characters, string.char(i))
end

local RandomUtils = {}

function RandomUtils.randIntNoRepeats(x, y, count)
    if x > y or count > (y - x + 1) then
        warn("[RandomUtils] - Invalid args")
        return {1}
    end

    local resultTable = {}
    local availableNumbers = {}

    for i = x, y do
        table.insert(availableNumbers, i)
    end

    for i = 1, count do
        local index = math.random(1, #availableNumbers)
        local randomValue = table.remove(availableNumbers, index)
        table.insert(resultTable, randomValue)
    end

    return resultTable
end

function RandomUtils.generateRAID(len, randomObject)
    randomObject = randomObject or Random.new()

    local chosenCharacters = {}
    for _ = 1, len do
        table.insert(chosenCharacters, characters[randomObject:NextInteger(1, #characters)])
    end

    return table.concat(chosenCharacters)
end

function RandomUtils.randomChance(chance, randomObject)
    if chance <= 0 then
        return false
    end

    randomObject = randomObject or Random.new()

    return randomObject:NextNumber(0, 100) <= chance
end

return RandomUtils