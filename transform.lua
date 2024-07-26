--[[
    represents a bone's transform relative to its parent bone

]]

include("lib/vec.lua")

Transform = {}
Transform.__index = Transform
Transform.__type = "transform"

function Transform:new(pos, rot)
    pos = pos or Vec:new()

    if (pos.__type == "pod") return Transform.depod(nil, pos)

    rot = rot or 0
    local t = {
        pos = pos,
        rot = rot
    }

    setmetatable(t, Transform)
    return t
end


function Transform:copy()
    return Transform:new(
        self.pos:copy(),
        self.rot
    )
end



-- pods
function Transform:pod()
    local transform = {}

    transform["pos"] = {x = self.pos.x, y = self.pos.y}
    transform["rot"] = self.rot

    return transform
end

function Transform:depod(tbl)
    return Transform:new(
        Vec:new(tbl.pos.x, tbl.pos.y),
        tbl.rot
    )
end




-- metamethods
function Transform:__add(other)
    if (other.__type == "transform") then
        return Transform:new(
            self.pos + other.pos,
            self.rot + other.rot
        )
    else
        error("cannot add transform with type \"" .. type(other) .. "\" (" .. tostr(other.__type) .. ")")
    end
end

function Transform:__mul(other)
    if (type(other) == "number") then
        return Transform:new(
            self.pos * other,
            self.rot * other
        )

    elseif (other.__type == "vec") then
        return other:rotate(self.rot) + self.pos

    else
        error("cannot multiply transform with type \"" .. type(other) .. "\" (" .. tostr(other.__type) .. ")")
    end
end



function Transform:__tostring()
    return tostr(self.pos) .. " @ " .. self.rot
end