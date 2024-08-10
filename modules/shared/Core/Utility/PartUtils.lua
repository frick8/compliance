---
-- @classmod PartUtils
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local PartUtils = {}

function PartUtils.calculateInsetPercentage(part, point)
	local halfSize = part.Size * 0.5
	local localPoint = part.CFrame:PointToObjectSpace(point)

	return math.min(
        1 - math.clamp(math.abs(localPoint.X) / halfSize.X, 0, 1),
        1 - math.clamp(math.abs(localPoint.Y) / halfSize.Y, 0, 1),
        1 - math.clamp(math.abs(localPoint.Z) / halfSize.Z, 0, 1)
    )
end

function PartUtils.calculateIntersectionVolume(partA, partB)
    local aMin = partA.Position - partA.Size / 2
    local aMax = partA.Position + partA.Size / 2

    local bMin = partB.Position - partB.Size / 2
    local bMax = partB.Position + partB.Size / 2

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

    local volumeA = partA.Size.X * partA.Size.Y * partA.Size.Z
    local volumeB = partB.Size.X * partB.Size.Y * partB.Size.Z

    local proportionA = intersectionVolume / volumeA
    local proportionB = intersectionVolume / volumeB

    return math.min(proportionA, proportionB)
end

return PartUtils