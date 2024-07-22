--[[pod_format="raw",created="2024-07-19 20:04:12",modified="2024-07-19 20:04:12",revision=0]]
--[[
    (re)animates movement between keyframes.

    i really should have more serious names. maybe necrodancer?

]]

include("skeleton/animation.lua")

include("lib/tstr.lua")

Necromancer = {}
Necromancer.__index = Necromancer
Necromancer.__type = "necromancer"

function Necromancer:new(animations)

    if (not animations) then
        animations = {}
        animations["idle"] = Animation:new("idle")
    end

    -- ensures there is an empty animation (to play skeleton default)
    animations["empty"] = Animation:new("empty", {})

    local n = {
        animations = animations,
        current = animations["idle"],   -- current animation
        previous = nil,                 -- previous animation
        interpolator = nil,             -- function used to interpolate between poses
        frame = 0,                      -- frame/time
        paused = false,                 -- whether to increment frames on update
        skeleton = nil                  -- will be set once given to skeleton
    }

    setmetatable(n, Necromancer)
    return n
end


-- sets new animation
function Necromancer:set(animation)
    self.previous = self.current    -- we'll want to keep transforms of last animation, not whole animation
    self.current = self.animations[animation]
    self.frame = 0
end

-- updates frame count
function Necromancer:update()

    -- if no keyframes in current animation, use skeleton default
    if (#self.current.keyframes == 0) return self:emptypose()

    if (not self.paused) self.frame += 1
    if (self.frame >= self.current.duration) self.frame = 0 -- loops

    -- gets frames and progress
    local k1, k2 = self:findkeyframes()
    local progress = self:progress(k1, k2)

    -- finds the pose
    return self:interpolate(k1, k2, progress)
end


-- figures out which pair of keyframes to use
function Necromancer:findkeyframes()
    local keyframes = self.current.keyframes
    local k1, k2 = keyframes[1], keyframes[1]   -- need to initialise for comparisons

    for i = 2, #keyframes do
        k2 = keyframes[i]

        if (k2.frame > self.frame) return k1, k2
        if (self.frame >= k2.frame and i == #keyframes) return k2, keyframes[1] -- allows k(-1) -> k(1)

        k1 = keyframes[i]
    end

    return k1, k2
end

-- finds the progress [0, 1) between the pair of keyframes
function Necromancer:progress(k1, k2) -- er, we don't need to pass k2
    return (self.frame - k1.frame) / k1.duration
end

function Necromancer:interpolate(k1, k2, progress)
    if (self.interpolator) return self:interpolator(k1, k2, progress, self)

    -- gets linear interpolation, if provided no other interpolator
    local transforms = {}

    for bone, _ in pairs(k1.transforms) do
        transforms[bone] = (k1:get(bone) * (1 - progress) + k2:get(bone) * progress)
    end

    return transforms
end


-- adds a bone to all animations.
-- shouldn't be used at runtime, but to build skeletons while
-- seeing the output.
function Necromancer:addbone(bone)
    for _, animation in pairs(self.animations) do
        animation:addbone(bone)
    end
end


-- returns default skeleton state
function Necromancer:emptypose()
    local transforms = {}
    
    for name, bone in pairs(self.skeleton.bones) do
        transforms[bone] = Transform:new()
    end

    return transforms
end


-- places necromancer in the grave (pod)
function Necromancer:pod()
    local necromancer = {}

    for name, animation in pairs(self.animations) do
        necromancer[name] = animation:pod()
    end

    return necromancer
end


-- metamethods
function Necromancer:__tostring()

    local tbl = {}

    tbl["current"] = self.current.name
    tbl["frame"] = self.frame
    tbl["paused"] = self.paused
    tbl["animations"] = self.animations

    return "Necromancer" .. tstr(tbl)
end