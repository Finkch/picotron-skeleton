--[[
    skins make bone visible as more than just a line

]]

include("lib/vec.lua")
include("lib/tstr.lua")


--[[
    regular skins place sprites at the joint

]]

Skin = {}
Skin.__index = Skin
Skin.__type = "skin"

function Skin:new(sprite_num, offset)
    if (not offset) offset = Vec:new()

    local s = {
        sn = sprite_num,
        offset = offset
    }

    setmetatable(s, Skin)
    return s
end


function Skin:draw(bone, offset)

    -- grabs the bone's range
    local s, e = bone:span(self.offset + offset)

    spr(self.sn, s.x, s.y)
end


-- metamethods
function Skin:__tostring()
    local str   = "Skin (#" .. self.sprite .. ")"
    str       ..= "-> Size:\t" .. self.size.x .. "x" .. self.size.y
    str       ..= "-> Offset:\t (" .. self.offset.x .. ", " .. self.offset.y .. ")"

    return str
end



--[[
    texture skins texture map (tline3d) a sprite onto the bone.
    this allows the sprite to rotate.
    however, it only works with 1-wide sprites (due to technical issues).

]]

TextureSkin = {}
TextureSkin.__index = TextureSkin
TextureSkin.__type = "textureskin"
setmetatable(TextureSkin, Skin)

function TextureSkin:new(sprite_num, offset, tsize, toffset)

    local sprite = get_spr(sprite_num)
    if (not toffset)    toffset = Vec:new()
    if (not tsize)      tsize = Vec:new(sprite:width() - 1, sprite:height() - 1)
    
    local ts = Skin:new(sprite_num, offset)
    ts["sprite"]    = sprite
    ts["tsize"]     = tsize
    ts["toffset"]   = toffset

    setmetatable(ts, TextureSkin)
    return ts
end


function TextureSkin:draw(bone, offset)

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
end

-- metamethods
function Skin:__tostring()
    local str   = "Skin (#" .. self.sprite .. ")"
    str       ..= "-> Size:\t" .. self.size.x .. "x" .. self.size.y .. " <- " .. self.tsize.x .. "x" .. self.tsize.y
    str       ..= "-> Offset:\t (" .. self.offset.x .. ", " .. self.offset.y .. ") <- (" .. self.toffset.x .. ", " .. self.toffset.y .. ")"

    return str
end