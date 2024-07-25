--[[
    what sprite/textures are associated with each bone in a skeleton.

]]

include("lib/vec.lua")
include("lib/tstr.lua")

Skin = {}
Skin.__index = Skin
Skin.__type = "skin"

function Skin:new(sprite_num, ismap, offset, tsize, toffset)
    if (ismap == nil)   ismap = true
    if (not offset)     offset = Vec:new()

    local sprite = nil
    if (ismap) then
        sprite = get_spr(sprite_num)
        if (not toffset)    toffset = Vec:new()
        if (not tsize)      tsize = Vec:new(sprite:width() - 1, sprite:height() - 1)
    end
    
    local s = {
        sprite = sprite,    -- sprite bitmap for the texture element
        sn = sprite_num,    -- sprite number
        ismap = ismap,      -- whether to draw map or just a sprite
        tsize = tsize,      -- texture coordinates of skin map
        offset = offset,    -- offset to draw position
        toffset = toffset,  -- offset to texture position
    }

    setmetatable(s, Skin)
    return s
end


function Skin:draw(bone, offset)

    if (self.ismap) then

        -- grabs the bone's range
        local s, e = bone:span(self.offset + offset)

        -- grabs texture element range
        local ts, te = self.toffset, self.toffset + self.tsize

        -- draws a textured line
        tline3d(
            self.sprite,    -- sprite data
            s.x, s.y,       -- x0, y0
            e.x, e.y,       -- x1, y1
            ts.x, ts.y,     -- texture x0, y0
            te.x, te.y      -- texture x1, y1
        )
    else
        local pos = self.offset + offset

        spr(
            self.sn,
            pos.x,
            pos.y
        )
    end
end



-- metamethods
function Skin:__tostring()
    local str   = "Skin (#" .. self.sprite .. ")"
    str       ..= "-> Size:\t" .. self.size.x .. "x" .. self.size.y .. " <- " .. self.tsize.x .. "x" .. self.tsize.y
    str       ..= "-> Offset:\t (" .. self.offset.x .. ", " .. self.offset.y .. ") <- (" .. self.toffset.x .. ", " .. self.toffset.y .. ")"

    return str
end