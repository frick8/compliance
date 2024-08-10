--- Handles sound playing
-- @classmod SoundPlayer
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local SoundConstants = require("SoundConstants")
local Network = require("Network")
local TemplateProvider = require("TemplateProvider")
local SoundModifier = require("SoundModifier")
local DebugVisualizer = require("DebugVisualizer")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local SoundPlayer = {}

function SoundPlayer:Init()
    self._provider = TemplateProvider.new(ReplicatedStorage[SoundConstants.SOUND_DIRECTORY_NAME])
    self._provider:Init()

    if RunService:IsClient() then
        Network:GetRemoteEvent(SoundConstants.REMOTE_EVENT_NAME).OnClientEvent:Connect(function(action, ...)
            self[action](self, ...)
        end)
    end
end

function SoundPlayer:PlaySound(soundName, endedFunc)
    return self:PlaySoundAtPart(soundName, nil, endedFunc)
end

function SoundPlayer:PlaySoundAtPart(soundName, part, endedFunc)
    local sound = self._provider:Get(soundName)
    SoundModifier:ProcessSound(sound)

    sound.Parent = part or SoundService
    sound.Ended:Connect(function()
        if endedFunc then
            task.spawn(endedFunc)
        end
        sound:Destroy()
    end)
    sound:Play()

    return sound
end

function SoundPlayer:PlaySoundAtPosition(soundName, position, endedFunc)
    local part = DebugVisualizer:GhostPart()
    part.Transparency = 1
    part.Position = position
    part.Parent = workspace:WaitForChild("Effects")

    return self:PlaySoundAtPart(soundName, part, function()
        part:Destroy()
        if endedFunc then
            endedFunc()
        end
    end)
end

return SoundPlayer