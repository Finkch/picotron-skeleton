--[[
    imports/exports skeleton from/to pod

]]

include("lib/tstr.lua")
include("lib/vec.lua")

include("skeleton/skeleton.lua")
include("skeleton/bone.lua")
include("skeleton/necromancer.lua")
include("skeleton/animation.lua")
include("skeleton/keyframe.lua")
include("skeleton/transform.lua")



function export(skeleton)

    -- dissects the skeleton into a table
    local tbl = skeleton:pod()

    -- transforms into a compressed pod
    return pod(tbl, 0x7)
end


function import(new_skeleton)

    -- gets the table
    local tbl = unpod(new_skeleton)

    -- obtains the core and all its children from the table
    local core = getbones(tbl.core)

    -- gets all animations
    local necromancer = getnecromancer(tbl.necromancer)

    -- puts it all together
    local skeleton = Skeleton:new(core, necromancer, tbl.debug)

    return skeleton
end





-- recursively makes bones from the pod
function getbones(bonetbl, parent)
    local bone = Bone:new(
        bonetbl.name,
        Vec:new(bonetbl.bone.x, bonetbl.bone.y),
        bonetbl.z,
        Vec:new(bonetbl.joint.x, bonetbl.joint.y)
    )

    -- add the child bone to the parent bone
    if (parent) parent:add(bone)
    
    -- recurses to find children
    for _, childtbl in pairs(bonetbl.children) do
        local child = getbones(childtbl, bone)
    end

    return bone
end


-- makes the necromancer from the pod
function getnecromancer(necromancertbl)
    local animations = {}
    for name, animationtbl in pairs(necromancertbl) do
        animations[name] = getanimation(animationtbl)
    end

    return Necromancer:new(animations)
end

function getanimation(animationtbl)
    local keyframes = {}
    for i = 1, #animationtbl.keyframes do
        keyframes[i] = getkeyframe(animationtbl.keyframes[i])
    end

    return Animation:new(animationtbl.name, keyframes)
end

function getkeyframe(keyframetbl)
    local transforms = {}
    for bone, transformtbl in pairs(keyframetbl.transforms) do
        transforms[bone] = gettransform(transformtbl)
    end

    return Keyframe:new(keyframetbl.duration, transforms)
end

function gettransform(transformtbl)
    return Transform:new(
        Vec:new(transformtbl.pos.x, transformtbl.pos.y),
        transformtbl.rot
    )
end