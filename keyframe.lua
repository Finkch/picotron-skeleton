--[[
    represents a keyframe in an animation

    i can't think of a clever name for this one

]]

include("lib/tstr.lua")

include("skeleton/transform.lua")

Keyframe = {}
Keyframe.__index = Keyframe
Keyframe.__type = "keyframe"

function Keyframe:new(duration, transforms)

    if (not duration) duration = 30
    if (not transforms) transforms = {}

    local k = {
        duration = duration,        -- frames for which to play this keyframe
        transforms = transforms,    -- a table of transforms for all joints (from base model to reach this pose)
        frame = nil                 -- timestampt at which keyframe is played (set by animation)
    }

    setmetatable(k, Keyframe)
    return k
end

-- adds a bone into the keyframe's transformations list
function Keyframe:addbone(bone, transform)
    if (not transform) transform = Transform:new()
    if (type(transform) == "number") transform = Transform:new(nil, transform)
    self.transforms[bone.name] = transform
end

-- returns bone's transform, with default for key not found
function Keyframe:get(bone)
    if (bone.name) bone = bone.name
    if (self.transforms[bone] == nil) self.transforms[bone] = Transform:new()

    return self.transforms[bone]
end



-- pod
function Keyframe:pod()
    local keyframe = {}

    keyframe["duration"] = self.duration

    -- adds transforms
    keyframe["transforms"] = {}
    for bone, transform in pairs(self.transforms) do
        keyframe.transforms[bone] = transform:pod()
    end

    return keyframe
end



-- metamethods
function Keyframe:__index(key) -- returns transform without overriding metamethods
    local datum = self.transforms[key]

    -- if we didn't find the item, it likely means it shoud look in the metatable
    if (not datum) return Keyframe[key]
    return datum
end

function Keyframe:__tostring()
    return "Keyframe (" .. self.duration .. "f @ " .. tostr(self.frame) .. ")\t" .. tstr(self.transforms, 1)
end