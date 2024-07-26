--[[
    a class for the heirarchy of bones and their skins.

    hm, i would have expected the joint/bone to hold the skin information...

]]

include("picotron-skeleton/bone.lua")
include("picotron-skeleton/necromancer.lua")
include("picotron-skeleton/transform.lua")

Skeleton = {}
Skeleton.__index = Skeleton
Skeleton.__type = "skeleton"

function Skeleton:new(core, necromancer, debug)

    if (core.__type == "pod") return Skeleton:depod(core)
    
    if (not necromancer) necromancer = Necromancer:new()

    if (not core) then
        core = Bone:new(
            "core",
            Vec:new(0, -6),     -- points from hips to skull
            0,                  -- default depth
            Vec:new(0, -12)      -- starts off the ground
        )

        -- adds core to all animations
        necromancer:addbone(core)
    end

    debug = debug or false

    local s = {
        core = core,
        bones = {},
        necromancer = necromancer,
        debug = debug       -- shows skeleton as coloured lines
    }

    necromancer.skeleton = s

    -- skin map

    setmetatable(s, Skeleton)
    s:findbones() -- updates bones
    return s
end


-- draws the skeleton
function Skeleton:draw(offset)
    offset = offset or {x = 0, y = 0} -- converts model coordinates to world coordinates
    for _, bone in pairs(self.bones) do
        bone:draw(offset)
    end

    -- draws origin
    if (self.debug) circfill(offset.x, offset.y, 1, 8)
end

-- updates skeleton
function Skeleton:update()
    local pose = self.necromancer:update()
    self:dance(pose)
end


-- sets the list of bones, recursing down children
-- also gives the bones a reference to their owner
function Skeleton:findbones()
    self.bones[self.core.name] = self.core
    self.core.skeleton = self
    self:_findbones(self.core)
end

function Skeleton:_findbones(current_bone)
    local tip = current_bone:tip()
    for bone in all(current_bone.children) do
        self.bones[bone.name] = bone
        bone.skeleton = self
        bone.transform.pos += tip   -- attatches bone

        self:_findbones(bone)       -- recurses, finding bones of current's children
    end
end


-- adds and removes bones, allowing for live modifications
function Skeleton:add(bone, parent)
    self.bones[parent.name]:add(bone)
    self.bones = {}
    self:findbones()
end

function Skeleton:remove(bone)  -- recursively finds the parent bone
    local current = self.core
    self:_remove(bone, current)
    self.bones = {}
    self:findbones()
end

function Skeleton:_remove(bone, current)
    for child in all(current.children) do
        if (child.name == bone.name) then
            del(current.children, child)
            return
        end
        self:_remove(bone, child)
    end
end

-- applies a pose to the skeleton
function Skeleton:dance(pose)   -- pose is a table of joint transforms
    self.core:dance(    -- applies to core; will cascade down from there
        pose
    )
end


-- puts the skeleton into a grave
-- (returns a pod for the skeleton).
function Skeleton:pod()
    local skeleton = {}

    -- adds types to the pod
    skelton["__type"] = "pod"
    skelton["__totype"] = "skeleton"

    -- adds each bone to the grave
    skeleton["core"] = self.core:pod()
    skeleton["debug"] = self.debug

    -- adds the necromancer to the grave
    skeleton["necromancer"] = self.necromancer:pod(skeleton)

    return skeleton
end

function Skeleton:depod(tbl)
    local core = Bone:new(tbl.core)

    local necromancer = Necromancer:new(tbl.necromancer)

    local skeleton = Skeleton:new(core, necromancer, tbl.debug)

    return skeleton
end



-- metamethods
function Skeleton:__tostring()
    local str = "Skeleton (" .. self.core.name .. ")\t"

    for _, bone in pairs(self.bones) do
        str ..= "\n" .. tostr(bone)
    end

    str ..= "\n" .. tostr(self.necromancer)

    return str
end




--[[
    a procedural skeleton is one where in addition to a main necromancer,
    procedural animation can be used of specified limbs

]]

ProceduralSkeleton = {}
ProceduralSkeleton.__index = ProceduralSkeleton
ProceduralSkeleton.__type = "proceduralskeleton"
setmetatable(ProceduralSkeleton, Skeleton)

function ProceduralSkeleton:new(core, necromancer, debug)
    local ps = Skeleton:new(core, necromancer, debug)
    ps["necromancers"] = {}

    setmetatable(ps, ProceduralSkeleton)
    return ps
end

-- updates skeleton
function ProceduralSkeleton:update()

    -- gets the regular animation pose
    local pose = self.necromancer:update()

    -- adds the suggested change given by all other necromancers
    for necromancer in all(self.necromancers) do
        if (not necromancer.paused) then
            local new_pose = necromancer:update()

            for bone, transform in pairs(new_pose) do
                pose[bone] += new_pose[bone]
            end
        end
    end

    self:dance(pose)
end

-- adds a procedural necromancer to the array
function ProceduralSkeleton:addnecromancer(necromancer)
    necromancer.skeleton = self
    add(self.necromancers, necromancer)
end


-- puts the skeleton into a grave
-- (returns a pod for the skeleton).
function ProceduralSkeleton:pod()
    local pskeleton = Skeleton.pod(self)

    pskeleton.__totype = "proceduralskeleton"

    pskeleton["necromancers"] = {}
    for necromancer in all(self.necromancers) do
        add(pskeleton.necromancers, necromancer)
    end

    return pskeleton
end