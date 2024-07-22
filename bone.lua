--[[
    a class for a bone/joint in a skeleton

]]

include("lib/vec.lua")
include("skeleton/transform.lua")

Bone = {}
Bone.__index = Bone
Bone.__type = "bone"

function Bone:new(name, bone, z, joint, transform)
    joint = joint or Vec:new()
    transform = transform or Transform:new()
    transform.pos += joint
    z = z or 1
    local b = {
        name = name,
        bone = bone,            -- vector that represents the bone itself; length and orientation
        children = {},
        z = z,                  -- depth, used to determine draw order
        skelton = nil,          -- tracks owner
        transform = transform,
        joint = joint           -- offset to its joint
    }

    -- skin?

    setmetatable(b, Bone)
    return b
end

-- draws the bone
function Bone:draw(offset)
    local s, e = self:span(offset)

    -- for now, just draws a red line and a circle
    if (self.skeleton.debug) then
        line(s.x, s.y, e.x, e.y, 18)
        circfill(s.x, s.y, 1, 2)
    end
end


-- adds child
function Bone:add(child)
    add(self.children, child)
end

-- gets the tip of the bone
function Bone:tip()
    return self.transform * self.bone
end

-- gets the two points for the bone's span
function Bone:span(offset) -- not sure about the how of this one yet
    offset = offset or {x = 0, y = 0}
    return self.transform.pos + offset, self:tip() + offset
end

-- rotates the bone and all of its children.
-- should NOT be used to dance; only used to build.
-- dancing uses transforms to rotate, bone rotation
-- is used for default, unrotated position.
function Bone:rotate(rot)
    self.bone = self.bone:rotate(rot)
    for child in all(self.children) do
        child:rotate(rot)
    end
    return self
end


-- applies a pose to this bone and to all of its children
function Bone:dance(pose, parenttip, parentrot)

    -- builds new transform for this pose
    local transform = Transform:new(self.joint, 0)  -- !don't! add previous rotation (leads to exponential growth)
    if (parentrot) transform.rot = parentrot        -- depends on parent's amount
    if (pose[self.name]) then
        transform.pos += pose[self.name].pos
        transform.rot += pose[self.name].rot
    end
    
    if (parenttip) transform.pos += parenttip       -- sets joint position

    self.transform = transform

    for child in all(self.children) do
        child:dance(pose, self:tip(), transform.rot)
    end
end


-- copies a bone
function Bone:copy(name)
    name = name or self.name
    return Bone:new(
        name,
        self.bone:copy(),
        self.z,
        self.joint:copy(),
        Transform:new()
    )
end


-- places the bones into the skeleton's grave (pod)
function Bone:pod()
    local bone = {}

    -- adds each component to the pod.
    -- note: no need to care about transform since its transient
    bone["name"]    = tostr(self.name)
    bone["bone"]    = {x = self.bone.x, y = self.bone.y}
    bone["z"]       = self.z
    bone["joint"]   = {x = self.joint.x, y = self.joint.y}

    -- adds each child
    bone["children"] = {}
    for name, child in pairs(self.children) do
        bone.children[name] = child:pod()
    end

    return bone
end


 
--[[
    metamethods
]]

function Bone:__tostring()
    local str = self.__type .. ": " .. self.name .. "\n-> children:\t"

    -- lists children
    for i = 1, #self.children do
        str ..= self.children[i].name
        
        if (i != #self.children) str ..= ", "
        
    end
    if (#self.children == 0) str ..= "nil"

    -- shows transform
    str ..= "\n-> " .. tostr(self.transform)

    return str
end