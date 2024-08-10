--- Utility functions for models
-- @classmod ModelUtils
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local DebugVisualizer = require("DebugVisualizer")
local TableUtils = require("TableUtils")

local CollectionService = game:GetService("CollectionService")

local ModelUtils = {}

function ModelUtils.getParts(model)
    local parts = {}
    for _, part in ipairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then
            continue
        end

        table.insert(parts, part)
    end

    return parts
end

function ModelUtils.getPrimaryModel(descendant, parent)
    local model = descendant
    while model and model.Parent ~= parent and model.Parent ~= game do
        model = model.Parent
    end

    return model and model.Parent ~= game and model or nil
end

function ModelUtils.createBasePart(model)
	local modelCFrame = model:GetBoundingBox()
    modelCFrame = CFrame.new(modelCFrame.Position)

	local basePart = DebugVisualizer:DebugPart()

	basePart.Size = Vector3.zero
	basePart.Name = "BasePart"

	basePart.CFrame = modelCFrame
    basePart.Parent = model

	model.PrimaryPart = basePart

	return basePart
end

function ModelUtils.getBoundingBoxWithBlacklist(model, blacklist)
    blacklist = blacklist or {}

    for _, instance in ipairs(blacklist) do
        if not typeof(instance) == "Instance" then
            continue
        end

        for _, descendant in ipairs(instance:GetDescendants()) do
            table.insert(blacklist, descendant)
        end
    end

    local blacklistHash = TableUtils.createHash(blacklist)
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

    for _, part in ipairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then
            continue
        end

        if blacklistHash[part] then
            continue
        end

        local cframe = part.CFrame
        local size = part.Size
        local corners = {
            cframe * Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
            cframe * Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
            cframe * Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
            cframe * Vector3.new(-size.X/2, size.Y/2, size.Z/2),
            cframe * Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
            cframe * Vector3.new(size.X/2, -size.Y/2, size.Z/2),
            cframe * Vector3.new(size.X/2, size.Y/2, -size.Z/2),
            cframe * Vector3.new(size.X/2, size.Y/2, size.Z/2),
        }

        for _, corner in ipairs(corners) do
            minX = math.min(minX, corner.X)
            minY = math.min(minY, corner.Y)
            minZ = math.min(minZ, corner.Z)
            maxX = math.max(maxX, corner.X)
            maxY = math.max(maxY, corner.Y)
            maxZ = math.max(maxZ, corner.Z)
        end
    end

    local center = Vector3.new((minX + maxX) / 2, (minY + maxY) / 2, (minZ + maxZ) / 2)
    local size = Vector3.new(maxX - minX, maxY - minY, maxZ - minZ)

    return CFrame.new(center), size
end

function ModelUtils.createDisplayClone(model)
    model = model:Clone()
    if model:IsA("Tool") then
        local vModel = Instance.new("Model")
        vModel.Name = model.Name
        for _, child in ipairs(model:GetChildren()) do
            child.Parent = vModel
        end

        model:Destroy()
        model = vModel
    end

    ModelUtils.createBasePart(model)

    for _, tag in ipairs(CollectionService:GetTags(model)) do
        CollectionService:RemoveTag(model, tag)
    end
    for _, obj in ipairs(model:GetDescendants()) do
        if not obj:IsA("BasePart") and not obj:IsA("Model") and not obj:IsA("SurfaceAppearance") then
            obj:Destroy()
        end
    end

    return model
end

return ModelUtils