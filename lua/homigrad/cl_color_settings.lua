hg = hg or {}
if hg.ColorSettings then return end

local ColorSettings = {}
ColorSettings.StoragePath = "homigrad/color_settings.json"

local schema = {
    {id = "hud_text", group = "HUD", default = Color(255, 255, 255, 255)},
    {id = "hud_background", group = "HUD", default = Color(0, 0, 0, 152)},
    {id = "hud_accent", group = "HUD", default = Color(176, 40, 40, 100)},
    {id = "hud_hint_background", group = "HUD", default = Color(0, 0, 0, 200)},
    {id = "hud_role_innocent", group = "HUD", default = Color(128, 0, 0)},
    {id = "hud_role_traitor", group = "HUD", default = Color(155, 0, 0)},
    {id = "ui_accent", group = "UI", default = Color(150, 0, 0)},
    {id = "ui_border", group = "UI", default = Color(155, 0, 0, 240)},
    {id = "ui_background", group = "UI", default = Color(25, 25, 35, 220)},
    {id = "menu_background", group = "Menu uwu", default = Color(10, 10, 19, 235)},
    {id = "menu_highlight", group = "Menu uwu", default = Color(245, 45, 45)},
    {id = "menu_progress", group = "Menu uwu", default = Color(255, 25, 25, 45)},
    {id = "appearance_secondary", group = "Appearance menu", default = Color(139, 0, 0, 162)},
    {id = "appearance_text", group = "Appearance menu", default = Color(255, 255, 255, 255)},
    {id = "appearance_text_secondary", group = "Appearance menu", default = Color(110, 110, 110, 125)},
    {id = "appearance_selection", group = "Appearance menu", default = Color(2, 128, 29, 161)},
    {id = "appearance_highlight", group = "Appearance menu", default = Color(255, 0, 0)},
    {id = "appearance_bg", group = "Appearance menu", default = Color(0,0,0,241)},
    {id = "appearance_line", group = "Appearance menu", default = Color(204, 10, 10, 150)}
}

ColorSettings.Schema = schema
ColorSettings.SchemaById = {}
for _, entry in ipairs(schema) do
    ColorSettings.SchemaById[entry.id] = entry
end

ColorSettings.Values = {}

local function encodeColor(col)
    return {col.r, col.g, col.b, col.a}
end

local function decodeColor(data, fallback)
    if not istable(data) then return fallback end
    local r = tonumber(data.r or data[1] or fallback.r) or fallback.r
    local g = tonumber(data.g or data[2] or fallback.g) or fallback.g
    local b = tonumber(data.b or data[3] or fallback.b) or fallback.b
    local a = tonumber(data.a or data[4] or fallback.a) or fallback.a
    return Color(r, g, b, a)
end

function ColorSettings:GetSchema()
    return self.Schema
end

function ColorSettings:GetGroups()
    local groups = {}
    for _, entry in ipairs(self.Schema) do
        groups[entry.group] = true
    end
    return groups
end

function ColorSettings:GetColor(id)
    local entry = self.SchemaById[id]
    if not entry then return color_white end
    local current = self.Values[id]
    if current then return current end
    local default = Color(entry.default.r, entry.default.g, entry.default.b, entry.default.a)
    self.Values[id] = default
    return default
end

function ColorSettings:SetColor(id, color, silent)
    local entry = self.SchemaById[id]
    if not entry then return end
    self.Values[id] = Color(color.r, color.g, color.b, color.a)
    self:Save()
    if not silent then
        hook.Run("HGColorsUpdated", id, self.Values[id])
    end
end

function ColorSettings:Reset(id)
    local entry = self.SchemaById[id]
    if not entry then return end
    self:SetColor(id, entry.default)
end

function ColorSettings:ResetGroup(group)
    for _, entry in ipairs(self.Schema) do
        if entry.group == group then
            self:Reset(entry.id)
        end
    end
end

function ColorSettings:Load()
    self.Values = {}
    local raw = file.Read(self.StoragePath, "DATA")
    if not raw or raw == "" then return end
    local data = util.JSONToTable(raw)
    if not istable(data) then return end
    for id, payload in pairs(data) do
        local entry = self.SchemaById[id]
        if entry then
            self.Values[id] = decodeColor(payload, entry.default)
        end
    end
end

function ColorSettings:Save()
    local data = {}
    for id, col in pairs(self.Values) do
        data[id] = encodeColor(col)
    end
    local dir = string.GetPathFromFilename(self.StoragePath)
    if dir and dir ~= "" then
        file.CreateDir(dir)
    end
    file.Write(self.StoragePath, util.TableToJSON(data, false))
end

ColorSettings:Load()
hg.ColorSettings = ColorSettings

