--- Utility functions for debug visualization
-- @classmod DebugVisualizer
-- @author frick

local DebugVisualizer = {}

function DebugVisualizer:DebugPart(cframe, size, transparency, shape)
    local part = self:GhostPart()

    if shape then
        part.Shape = shape
    end

    if transparency then
        part.Transparency = transparency
    end
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.Red()

    for _, faceName in ipairs(Enum.NormalId:GetEnumItems()) do
        part[("%sSurface"):format(faceName.Name)] = Enum.SurfaceType.SmoothNoOutlines
    end

    if typeof(cframe) == "CFrame" then
        part.CFrame = cframe
    elseif typeof(cframe) == "Vector3" then
        part.Position = cframe
    end
    part.Size = size or Vector3.one * 0.1
    part.Parent = workspace:WaitForChild("Effects")

    return part
end

function DebugVisualizer:GhostPart()
    local part = Instance.new("Part")

    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false

    return part
end

function DebugVisualizer:PointABPart(part, pointB, pointA)
    local distance = (pointA - pointB).Magnitude
    part.CFrame = CFrame.lookAt(pointA, pointB) * CFrame.Angles(0, -math.pi/2, 0) * CFrame.new(-distance/2, 0, 0)
    part.Size = Vector3.new(distance, part.Size.Y, part.Size.Z)
end

function DebugVisualizer:LookAtPart(pointA, pointB, transparency, thickness)
    local part = self:DebugPart(nil, Vector3.one * (thickness or 0.1), transparency)
    self:PointABPart(part, pointA, pointB)
    return part
end

return DebugVisualizer