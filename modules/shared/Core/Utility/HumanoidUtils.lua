--- General humanoid utility code.
-- @classmod HumanoidUtils
-- @author frick

local BODY_PART_NAMES = {
    Head = true;
    UpperTorso = true;
    LowerTorso = true;
    RightUpperArm = true;
    RightLowerArm = true;
    RightHand = true;
    LeftUpperArm = true;
    LeftLowerArm = true;
    LeftHand = true;
    RightUpperLeg = true;
    RightLowerLeg = true;
    RightFoot = true;
    LeftUpperLeg = true;
    LeftLowerLeg = true;
    LeftFoot = true;
}

local HumanoidUtils = {}

function HumanoidUtils.getHumanoid(descendant)
	local character = descendant
	while character do
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			return humanoid
		end

		character = character:FindFirstAncestorOfClass("Model")
    end

	return nil
end

local function cleanDesc(humanoid)
    local description = humanoid:GetAppliedDescription()

	local userAvatarDescription = humanoid:FindFirstChild("UserAvatarDescription")
	if not userAvatarDescription then
		userAvatarDescription = description:Clone()
		userAvatarDescription.Name = "UserAvatarDescription"
		userAvatarDescription.Parent = humanoid
	end

	description.Head = 0
	description.Torso = 0
	description.LeftArm = 0
	description.RightArm = 0
	description.LeftLeg = 0
	description.RightLeg = 0

	description.HeadColor = Color3.new()
	description.TorsoColor = Color3.new()
	description.LeftArmColor = Color3.new()
	description.RightArmColor = Color3.new()
	description.LeftLegColor = Color3.new()
	description.RightLegColor = Color3.new()

	description.Pants = 0
	description.Shirt = 0
	description.GraphicTShirt = 0

	description:SetAccessories({}, true)
	humanoid:ApplyDescription(description)
end

-- stolen from Hexcede!!
function HumanoidUtils.cleanDescription(humanoid)
    if not humanoid:IsDescendantOf(game) then
        local event; event = humanoid.AncestryChanged:Connect(function()
            if humanoid:IsDescendantOf(game) then
                cleanDesc(humanoid)
                event:Disconnect()
            end
        end)
    else
        cleanDesc(humanoid)
    end
end

function HumanoidUtils.getBodyVolume(character)
    local totalVolume = 0

    for _, child in ipairs(character:GetChildren()) do
        if not child:IsA("BasePart") then
            continue
        end

        if not BODY_PART_NAMES[child.Name] then
            continue
        end

        totalVolume += child.Size.X * child.Size.Y * child.Size.Z
    end

    return totalVolume
end

function HumanoidUtils.ragdoll(humanoid, upperAngle)
    local character = humanoid.Parent

    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("Motor6D") then
            local newJoint = Instance.new("BallSocketConstraint")
            local attachment0 = Instance.new("Attachment")
            local attachment1 = Instance.new("Attachment")

            attachment0.Parent = v.Part0
            attachment1.Parent = v.Part1

            newJoint.Parent = v.Parent
            newJoint.Attachment0 = attachment0
            newJoint.Attachment1 = attachment1

            attachment0.CFrame = v.C0
            attachment1.CFrame = v.C1

            newJoint.LimitsEnabled = true
            newJoint.UpperAngle = upperAngle or 45

            newJoint.TwistLimitsEnabled = true
            newJoint.TwistLowerAngle = -20
            newJoint.TwistUpperAngle = 20

            v:Destroy()
        end
    end
end

return HumanoidUtils