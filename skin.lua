--[[
    skins make bone visible as more than just a line

]]

include("lib/vec.lua")
include("lib/tstr.lua")
include("lib/rspr.lua")


--[[
    regular skins place sprites at the joint

]]

Skin = {}
Skin.__index = Skin
Skin.__type = "skin"
Skin.__parenttype = "skin"

function Skin:new(sprite_num, offset)

    if (type(sprite_num) == "table" and sprite_num.__type == "pod") return Skin:unpod(sprite_num)

    if (not offset) offset = Vec:new()

    local s = {
        sn = sprite_num,
        offset = offset,
        bone = nil  -- reference to bone that wears this skin
    }

    setmetatable(s, Skin)
    return s
end

function Skin:span(offset)
    return self.bone:span(offset + self.offset)
end

function Skin:draw(offset)

    -- grabs the bone's range
    local s, e = self:span(offset)

    spr(self.sn, s.x, s.y)
end

function Skin:pod()
    local skin = {}

    skin["__type"] = "pod"
    skin["__totype"] = "skin"

    skin["sn"] = self.sn
    skin["offset"] = {x = self.offset.x, y = self.offset.y}

    return skin
end

function Skin:unpod(tbl)
    return Skin:new(
        tbl.sn,
        Vec:new(tbl.offset.x, tbl.offset.y)
    )
end


function Skin:__tostring()
    local str   = "Skin (#" .. self.sn .. ", " .. self.bone.name .. ")"
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
    
    if (type(sprite_num) == "table" and sprite_num.__type == "pod") return TextureSkin:unpod(sprite_num)

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

function TextureSkin:draw(offset)

    -- grabs the bone's range
    local s, e = self:span(offset)

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

function TextureSkin:pod()
    local tskin = Skin.pod(self)

    tskin["__totype"] = "textureskin"

    tskin["tsize"] = {x = self.tsize.x, y = self.tsize.y}
    tskin["toffset"] = {x = self.toffset.x, y = self.toffset.y}

    return tski
end

function TextureSkin:unpod(tbl)
    return TextureSkin:new(
        tbl.sn,
        Vec:new(tbl.offset.x, tbl.offset.y),
        Vec:new(tbl.tsize.x, tbl.tsize.y),
        Vec:new(tbl.toffset.x, tbl.toffset.y)
    )
end

function TextureSkin:__tostring()
    local str   = "Skin (#" .. self.sn .. ", " .. self.bone.name .. ")"
    str       ..= "-> Size:\t" .. self.size.x .. "x" .. self.size.y .. " <- " .. self.tsize.x .. "x" .. self.tsize.y
    str       ..= "-> Offset:\t (" .. self.offset.x .. ", " .. self.offset.y .. ") <- (" .. self.toffset.x .. ", " .. self.toffset.y .. ")"

    return str
end



--[[
    a sprite that can rotate...shoddily.
    this is why TextureSkins are limited to 1 width: rspr does not look great.
    nevertheless, if necessary, here it can be used.

]]

RSkin = {}
RSkin.__index = RSkin
RSkin.__type = "rskin"
setmetatable(RSkin, Skin)

function RSkin:new(sprite_num, offset, joint)

    if (type(sprite_num) == "table" and sprite_num.__type == "pod") return RSkin:unpod(sprite_num)

    local rs = Skin:new(sprite_num, offset)
    rs["joint"] = joint
    rs["sprite"] = get_spr(sprite_num)

    setmetatable(rs, RSkin)
    return rs
end

function RSkin:rotation()
    return self.bone.transform.rot
end

function RSkin:draw(offset)

    -- grabs the bone's range
    local s, e = self:span(offset)
    self.rot = self:rotation()

    rspr(
        self.sn,    -- sprite number
        s,          -- position
        self.rot,   -- rotation amount
        self.joint  -- rotation centre
    )
end

function RSkin:pod()
    local rskin = Skin.pod(self)

    rskin["__totype"] = "rskin"

    rskin["joint"] = {x = self.joint.x, y = self.joint.y}

    return rskin
end

function RSkin:unpod(tbl)
    return RSkin:new(
        tbl.sn,
        Vec:new(tbl.offset.x, tbl.offset.y),
        Vec:new(tbl.joint.x, tbl.joint.y)
    )
end

function RSkin:__tostring()
    local str = Skin.__tostring(self)
    str ..= "-> joint:\t" .. self.joint.x .. ", " .. self.joint.y
    str ..= "-> rotation:\t" .. self.rot

    return str
end