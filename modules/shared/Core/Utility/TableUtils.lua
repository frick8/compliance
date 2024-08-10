--- Various utility functions for tables
-- @classmod TableUtils
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local RandomUtils = require("RandomUtils")

local TableUtils = {}

function TableUtils.swapArrange(t)
    local newTable = {}
    for i, v in pairs(t) do
        newTable[v] = i
    end

    return newTable
end

function TableUtils.count(t)
    local count = 0
    for _ in pairs(t) do
        count += 1
    end

    return count
end

function TableUtils.getRandomDictKey(dict)
    local keyTable = {}
    for key, _ in pairs(dict) do
        table.insert(keyTable, key)
    end

    return keyTable[math.random(1, #keyTable)]
end

function TableUtils.combineDict(t1, t2)
    local t = {}

    for i, v in pairs(t1) do
        t[i] = v
    end
    for i, v in pairs(t2) do
        t[i] = v
    end

    return t
end

function TableUtils.getWeightedDictKey(dict, randomObject)
    randomObject = randomObject or Random.new()

    local sum = 0
    for _, value in pairs(dict) do
        sum = sum + value.Weight
    end

    local rand = randomObject:NextNumber(0, sum)
    for key, value in pairs(dict) do
        rand = rand - value.Weight
        if rand <= 0 then
            return key
        end
    end
end

function TableUtils.shuffleWeightedCountedDictKeys(dict)
    local weightedKeys = {}

    for key, data in pairs(dict) do
        if data.Weight > 0 then
            for i = 1, data.Count do
                table.insert(weightedKeys, {key = key, weight = data.Weight})
            end
        end
    end

    math.randomseed(os.time())
    for i = #weightedKeys, 2, -1 do
        local j = math.random(1, i)
        weightedKeys[i], weightedKeys[j] = weightedKeys[j], weightedKeys[i]
    end

    local result = {}

    for _, data in ipairs(weightedKeys) do
        table.insert(result, data.key)
    end

    return result
end

function TableUtils.getRandomDictKeys(dict, count)
    local tableLen = 0
    local keyTable = {}
    local results = {}

    for key in pairs(dict) do
        tableLen += 1
        keyTable[tableLen] = key
    end

    for _, index in ipairs(RandomUtils.randIntNoRepeats(1, tableLen, count)) do
        table.insert(results, keyTable[index])
    end

    return results
end

function TableUtils.keyMapArray(dict)
    local keys = {}
    for key in pairs(dict) do
        table.insert(keys, key)
    end

    return keys
end

function TableUtils.getRandomDictVal(dict)
    local valTable = {}
    for _, val in pairs(dict) do
        table.insert(valTable, val)
    end

    return valTable[math.random(1, #valTable)]
end

function TableUtils.shallowCopy(t)
    local copy = {}
    for i, v in pairs(t) do
        copy[i] = v
    end
    return copy
end

function TableUtils.deepCopy(t)
    local copy = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = TableUtils.deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

function TableUtils.createHash(t)
    local hash = {}

    for _, value in pairs(t) do
        hash[value] = true
    end

    return hash
end

function TableUtils.shuffle(t)
    local j, temp
	for i = #t, 1, -1 do
		j = math.random(i)
		temp = t[i]
		t[i] = t[j]
		t[j] = temp
	end
end

return TableUtils