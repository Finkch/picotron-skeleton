--[[
    what sprite/textures are associated with each bone in a skeleton.

]]

include("lib/vec.lua")
include("lib/tstr.lua")

Skin = {}
Skin.__index = Skin
Skin.__type = "skin"

function Skin:new(sprite, offset, tsize, toffset)
    sprite = get_spr(sprite)
    
    if (not offset) offset = Vec:new()
    if (not toffset) toffset = Vec:new()
    if (not tsize) then
        tsize = Vec:new(sprite:get_width() - 1, sprite:get_height() - 1)
    end
    
    local s = {
        sprite = sprite,    -- sprite id of the texture element
        tsize = tsize,      -- texture coordinates of skin map
        offset = offset,    -- offset to draw position
        toffset = toffset,  -- offset to texture position
    }

    setmetatable(s, Skin)
    return s
end


function Skin:draw(bone, offset)

    -- grabs the bone's range
    local s, e = bone:span(self.offset + offset)

    -- grabs texture element range
    local ts, te = self.toffset, self.toffset + self.tsize

    -- draws a textured line
    tline3d(
        sprite,     -- sprite data
        s.x, s.y,   -- x0, y0
        e.x, e.y,   -- x1, y1
        ts.x, ts.y, -- texture x0, y0
        te.x, te.y  -- texture x1, y1
    )
end



-- metamethods
function Skin:__tostring()
    local str   = "Skin (#" .. self.sprite .. ")"
    str       ..= "-> Size:\t" .. self.size.x .. "x" .. self.size.y .. " <- " .. self.tsize.x .. "x" .. self.tsize.y
    str       ..= "-> Offset:\t (" .. self.offset.x .. ", " .. self.offset.y .. ") <- (" .. self.toffset.x .. ", " .. self.toffset.y .. ")"

    return str
end