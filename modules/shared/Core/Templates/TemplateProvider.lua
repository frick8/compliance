--- Template provider object
-- @classmod TemplateProvider
-- @author frick

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Compliance"))

local BaseObject = require("BaseObject")
local TableUtils = require("TableUtils")

local TemplateProvider = setmetatable({}, BaseObject)
TemplateProvider.__index = TemplateProvider

function TemplateProvider.new(obj)
    return setmetatable(BaseObject.new(obj), TemplateProvider)
end

function TemplateProvider:Init()
    self._templates = {}
    self._templatesTopmost = {}
    self:_storeTemplates(self._obj)
end

function TemplateProvider:_storeTemplates(folder)
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("Folder") then
            self:_storeTemplates(obj)
        else
            if obj == self._obj then
                table.insert(self._templatesTopmost, obj)
            end

            self._templates[obj.Name] = obj
        end
    end
end

function TemplateProvider:Get(templateName)
    local template = assert(self._templates[templateName], ("Invalid name %q"):format(templateName)):Clone()
    template.Name = template.Name:gsub("Template", "")
    return template
end

function TemplateProvider:GetRandom(recurse)
    if recurse then
        return TableUtils.getRandomDictVal(self._templates)
    else
        return self._templatesTopmost[Random.new():NextInteger(1, #self._templatesTopmost)]
    end
end

return TemplateProvider