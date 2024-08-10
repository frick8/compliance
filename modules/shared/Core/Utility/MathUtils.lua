---
-- @classmod MathUtils
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local DebugVisualizer = require("DebugVisualizer")

local MathUtils = {}

function MathUtils.shortestSegmentBetweenLines(P1, P2, P3, P4)
	local d1343 = (P1 - P3):Dot(P4 - P3)
	local d4321 = (P4 - P3):Dot(P2 - P1)
	local d1321 = (P1 - P3):Dot(P2 - P1)
	local d4343 = (P4 - P3):Dot(P4 - P3)
	local d2121 = (P2 - P1):Dot(P2 - P1)

	local denom = d2121 * d4343 - d4321 * d4321
	if denom == 0 then
		return nil
	end

	local mua = (d1343 * d4321 - d1321 * d4343) / denom
	local mub = (d1343 + mua * d4321) / d4343

	local Pa = P1 + mua * (P2 - P1)
	local Pb = P3 + mub * (P4 - P3)

	return Pa, Pb
end

function MathUtils.closestPointOnLineSegment(point, lineStart, lineEnd)
	local lineDir = lineEnd - lineStart
	local u = ((point - lineStart):Dot(lineDir)) / lineDir:Dot(lineDir)
	local uC = u

	u = math.clamp(u, 0, 1)

	return lineStart + u * lineDir, u
end

function MathUtils.calculateIntersectionVolume_X(cframeA, sizeA, cframeB, sizeB)
    local aMin = cframeA.Position - sizeA / 2
    local aMax = cframeA.Position + sizeA / 2

    local bMin = cframeB.Position - sizeB / 2
    local bMax = cframeB.Position + sizeB / 2

    local intersectionMin = Vector3.new(
        math.max(aMin.X, bMin.X),
        math.max(aMin.Y, bMin.Y),
        math.max(aMin.Z, bMin.Z)
    )
    local intersectionMax = Vector3.new(
        math.min(aMax.X, bMax.X),
        math.min(aMax.Y, bMax.Y),
        math.min(aMax.Z, bMax.Z)
    )

    local intersectionSize = intersectionMax - intersectionMin

    if intersectionSize.X < 0 or intersectionSize.Y < 0 or intersectionSize.Z < 0 then
        return 0
    end

    local intersectionVolume = intersectionSize.X * intersectionSize.Y * intersectionSize.Z

    local volumeA = sizeA.X * sizeA.Y * sizeA.Z
    local volumeB = sizeB.X * sizeB.Y * sizeB.Z

    local proportionA = intersectionVolume / volumeA
    local proportionB = intersectionVolume / volumeB

    return math.min(proportionA, proportionB)
end

function MathUtils.calculateIntersectionVolume(cframeA, sizeA, cframeB, sizeB)
    local function getCorners(cframe, size)
        local halfSize = size * 0.5
        local corners = {}
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    table.insert(corners, cframe * Vector3.new(x * halfSize.X, y * halfSize.Y, z * halfSize.Z))
                end
            end
        end
        return corners
    end

    local function getMinMax(corners)
        local minX, minY, minZ = corners[1].X, corners[1].Y, corners[1].Z
        local maxX, maxY, maxZ = corners[1].X, corners[1].Y, corners[1].Z

        for _, corner in ipairs(corners) do
            minX = math.min(minX, corner.X)
            minY = math.min(minY, corner.Y)
            minZ = math.min(minZ, corner.Z)
            maxX = math.max(maxX, corner.X)
            maxY = math.max(maxY, corner.Y)
            maxZ = math.max(maxZ, corner.Z)
        end

        return Vector3.new(minX, minY, minZ), Vector3.new(maxX, maxY, maxZ)
    end

    local cornersA = getCorners(cframeA, sizeA)
    local cornersB = getCorners(cframeB, sizeB)

    local minA, maxA = getMinMax(cornersA)
    local minB, maxB = getMinMax(cornersB)

    local minIntersection = Vector3.new(
        math.max(minA.X, minB.X),
        math.max(minA.Y, minB.Y),
        math.max(minA.Z, minB.Z)
    )

    local maxIntersection = Vector3.new(
        math.min(maxA.X, maxB.X),
        math.min(maxA.Y, maxB.Y),
        math.min(maxA.Z, maxB.Z)
    )

    local intersectionSize = maxIntersection - minIntersection
    if intersectionSize.X > 0 and intersectionSize.Y > 0 and intersectionSize.Z > 0 then
        local intersectionVolume = intersectionSize.X * intersectionSize.Y * intersectionSize.Z
        local volumeA = sizeA.X * sizeA.Y * sizeA.Z
        local volumeB = sizeB.X * sizeB.Y * sizeB.Z
        local ratioA = intersectionVolume / volumeA
        local ratioB = intersectionVolume / volumeB
        return (ratioA + ratioB) / 2
    else
        return 0
    end
end

function MathUtils.areLinesIntersecting(line1Start, line1End, line2Start, line2End, tolerance)
	local a, b = MathUtils.shortestSegmentBetweenLines(line1Start, line1End, line2Start, line2End)
    -- local color = BrickColor.random()
    -- local part1 = DebugVisualizer:LookAtPart(line1Start, line1End, 0.2, 0.2)
    -- part1.BrickColor = color
    -- local part2 = DebugVisualizer:LookAtPart(line2Start, line2End, 0.2, 0.2)
    -- part2.BrickColor = color
    if not a then
        return false
    end

    -- DebugVisualizer:LookAtPart(a, b, 0.15, 0.15).BrickColor = BrickColor.Red()

	local mid = a + ((b - a)/2)

	local closestA = MathUtils.closestPointOnLineSegment(mid, line1Start, line1End)
	local closestB = MathUtils.closestPointOnLineSegment(mid, line2Start, line2End)

    -- DebugVisualizer:LookAtPart(closestA, closestB, 0.15, 0.15)

    local isIntersecting = (closestA - closestB).Magnitude <= tolerance
    -- if isIntersecting then
    --     DebugVisualizer:LookAtPart(closestA, closestB, 0.15, 0.15)
    -- end

	return isIntersecting, closestA, closestB
end

return MathUtils