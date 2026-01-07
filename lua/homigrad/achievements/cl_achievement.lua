-- "addons\\homigrad\\lua\\homigrad\\achievements\\cl_achievement.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

hg.achievements = hg.achievements or {}
hg.achievements.achievements_data = hg.achievements.achievements_data or {}
hg.achievements.achievements_data.player_achievements = hg.achievements.achievements_data.player_achievements or {}
hg.achievements.achievements_data.created_achevements = {}

hg.achievements.MenuPanel = hg.achievements.MenuPanel or nil

local CreateMenuPanel

concommand.Add("hg_achievements",function()
    CreateMenuPanel()
end)

local function createButton(frame, ach, text, func)
    local button = vgui.Create("DButton", frame)

    ach.img = isstring(ach.img) and Material(ach.img) or ach.img
    
    local localach = hg.achievements.GetLocalAchievements()
    --PrintTable(localach)
    local desc = markup.Parse("<font=HomigradFontMedium>"..ach.description.."<font>", 500 )
    
    local x,y = frame:LocalToScreen(button:GetPos())
    function button:Paint(w,h)
        local view = render.GetViewSetup(true)
        local pos,ang = view.origin,view.angles
        ang:RotateAroundAxis( ang:Up(), -90 )
	    ang:RotateAroundAxis( ang:Forward(), 90 )
        
        self.lerpcolor = Lerp(FrameTime() * 10,self.lerpcolor or 0,self:IsHovered() and 255 or 0)
       
        local val = localach[ach.key] and localach[ach.key].value or ach.start_value
        local amt = ScreenScale(1)
        surface.SetDrawColor(100- 20*(self.lerpcolor / 255),10,10,255)
        surface.DrawRect(amt,amt,w - amt * 2,h - amt * 2)
        
        surface.SetDrawColor(180- 80*(self.lerpcolor / 255),10,10,255)
        surface.DrawRect(amt,amt,(val / ach.needed_value) * w - amt * 2,h - amt * 2)

        surface.SetDrawColor(0,0,0,(val / ach.needed_value) == 1 and 255 or 0)
        surface.SetMaterial(ach.img)
        surface.DrawTexturedRect(amt * 2,amt * 2,h - amt * 4,h - amt * 4)

        --[[surface.SetDrawColor(71,36,48,(val / ach.needed_value) == 1 and 255 or 0)
        surface.SetMaterial(ach.img)
        surface.DrawTexturedRect(amt * 5,amt * 5,h - amt * 10,h - amt * 10)--]]

        surface.SetFont("HomigradFont") 
        local txt = ach.name.." "..(ach.showpercent and (val / ach.needed_value * 100).."%" or "")
        local wt,ht = surface.GetTextSize(txt)
        surface.SetTextColor(255,255,255)
        surface.SetTextPos(w / 2 - (wt / 2), (ht / 2) * (1-(self.lerpcolor / 255)*5))
        surface.DrawText(txt)

       --surface.SetFont("HomigradFontMedium")
       --local wt,ht = surface.GetTextSize(ach.description)
       --surface.SetTextColor(255,255,255,255)
       --surface.SetTextPos(w / 2 - wt / 2,h - ((h/2)+ht/2) * (self.lerpcolor / 255))
        --surface.DrawText(ach.description)
        desc:Draw(w / 2,(h + desc:GetHeight()) - ((h/2) + desc:GetHeight()) * (self.lerpcolor / 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(130,10,10,255)
        surface.DrawOutlinedRect(0,0,w,h,amt)

        surface.SetDrawColor(255,255,255,10)
        draw.NoTexture()
        surface.DrawTexturedRectRotated(w - self.lerpcolor / 255 * 100 + 50,0,10,400,-30)
        surface.DrawTexturedRectRotated(w - self.lerpcolor / 255 * 100 + 80,0,10,400,-30)
        
    end

    button:SetText("")
    button:SetSize(0,ScreenScale(22))
    button:Dock(TOP)
    button:DockMargin(0,0,0,ScreenScale(2.5))
    button.DoClick = function(self) func(self) end
    return button
end

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur

local col1 = Color(255,0,0,200)
CreateMenuPanel = function()
    hg.achievements.LoadAchievements()

    if IsValid(hg.achievements.MenuPanel) then
        hg.achievements.MenuPanel:Remove()
        hg.achievements.MenuPanel = nil
    end

    local frame = vgui.Create( "ZFrame" )
    hg.achievements.MenuPanel = frame
    frame:SetTitle("")
    frame:SetSize( ScrW() / 3, ScrH() / 2 )
    frame:SetPos( ScrW() * 0.5 - frame:GetWide() * 0.5,ScrH() + 500 )
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)
    local pad = ScreenScale(15)
    local pad2 = ScreenScale(5)
    frame:DockPadding(pad2,pad,pad2,pad)
    frame.OnClose = function() frame = nil end 
    frame:SetAlpha(0)

    frame:MoveTo(frame:GetX(), ScrH() / 2 - frame:GetTall() / 2, 0.5, 0, 0.3, function() end)
    frame:AlphaTo( 255, 1, 0, nil )

    function frame:Close()
        self:MoveTo(frame:GetX(), ScrH() + 500, 0.5, 0, 0.3, function()
            self:Remove()
        end)
        self:AlphaTo( 0, 0.1, 0, nil )
        self:SetKeyboardInputEnabled(false)
        self:SetMouseInputEnabled(false)
    end

    local scroll = vgui.Create("DScrollPanel",frame)
    scroll:Dock(FILL)
    frame.scroll = scroll

    local sbar = scroll:GetVBar()
    sbar:SetHideButtons(true)
    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end
    function sbar.btnGrip:Paint(w, h)
        self.lerpcolor = Lerp(FrameTime() * 10, self.lerpcolor or 0.2,(self:IsHovered() and 1 or 0.2))
        draw.RoundedBox(0, 0, 0, w, h, Color(100 * self.lerpcolor, 10, 10))
    end

    --function frame:Paint(w,h)
    --    (self)
    --    BlurBackground--surface.SetFont("HomigradFontMedium")
    --    --local name = "Achievements"
    --    --local wt,ht = surface.GetTextSize(name)
    --    --surface.SetTextColor(255,255,255)
    --    --surface.SetTextPos(15,0)
    --    --surface.DrawText(name)
--
    --    surface.SetDrawColor(col1)
    --    surface.DrawOutlinedRect( 0, 0, w, h, 1 )
    --end

    function frame:UpdateValues()
        local scroll = self.scroll
        scroll:Clear()
        
        for i,ach in pairs(hg.achievements.achievements_data.created_achevements) do
            scroll:AddItem(createButton(scroll, ach, ach.name, function() end))
        end
    end

    for i,ach in pairs(hg.achievements.achievements_data.created_achevements) do
        scroll:AddItem(createButton(scroll, ach, ach.name, function() end))
    end
end

local time_wait = 0
function hg.achievements.LoadAchievements()
    if time_wait > CurTime() then return end
    time_wait = CurTime() + 2

    net.Start("req_ach")
    net.SendToServer()
end

function hg.achievements.GetLocalAchievements()
    return hg.achievements.achievements_data.player_achievements[tostring(LocalPlayer():SteamID())]
end

net.Receive("req_ach",function()
    hg.achievements.achievements_data.created_achevements = net.ReadTable()
    hg.achievements.achievements_data.player_achievements[tostring(LocalPlayer():SteamID())] = net.ReadTable()
    
    if IsValid(hg.achievements.MenuPanel) then
        hg.achievements.MenuPanel:UpdateValues()
    end
end)
hg.achievements.NewAchievements = hg.achievements.NewAchievements or {}
local AchTable = hg.achievements.NewAchievements 
net.Receive("hg_NewAchievement",function()
    local Ach = {time = CurTime() + 7.5,name = net.ReadString(),img = net.ReadString()}
    table.insert(AchTable,1,Ach)
    sound.PlayURL("","noblock",function(station) -- https://www.myinstants.com/media/sounds/achievement_earned.mp3
        if IsValid(station) then
            station:Play()
        end 
    end)
end)

--AchTable[1] = {time = CurTime() + 1.5,name = "Hello Everyone",img = "homigrad/vgui/models/star.png"}
--AchTable[2] = {time = CurTime() + 2.5,name = "Hello Everyone",img = "homigrad/vgui/models/star.png"}
--AchTable[3] = {time = CurTime() + 3.5,name = "Hello Everyone",img = "homigrad/vgui/models/star.png"}
--AchTable[4] = {time = CurTime() + 4.5,name = "Hello Everyone",img = "homigrad/vgui/models/star.png"}
--AchTable[5] = {time = CurTime() + 5.5,name = "Hello Everyone",img = "homigrad/vgui/models/star.png"}
--AchTable[6] = {time = CurTime() + 6.5,name = "Hello Everyone",img = "homigrad/vgui/models/star.png"}

hook.Add("HUDPaint","hg_NewAchievement", function()
    local frametime = FrameTime()*10
    for i = 1, #AchTable do
        local ach = AchTable[i]
        if not ach then continue end
        local txt = "Achievement! "..ach.name
        ach.img = isstring(ach.img) and Material(ach.img) or ach.img
        local wt,ht = surface.GetTextSize(txt)

        ach.Lerp = Lerp( frametime, ach.Lerp or 0, math.min( ach.time - CurTime(), 1 ) * i )
        WSize, HSize = ScrW() * 0.2, ScrH() * 0.05
        local HPos = ScrH() - ( HSize * ach.Lerp )
        draw.RoundedBox( 0, 0, HPos, WSize, HSize, Color(200,25,25) )
        draw.RoundedBox( 0, 2, HPos + 2, WSize - 4, HSize - 4, Color(100,25,25) )

        surface.SetFont("HomigradFontMedium") 
        surface.SetTextColor(255,255,255)
        surface.SetTextPos(HSize*1.25,(HPos + ( HSize/2 ) - ( HSize/4 )) )
        surface.DrawText(txt)
        surface.SetDrawColor(0,0,0)
        surface.SetMaterial(ach.img)
        surface.DrawTexturedRect(2,HPos+2,HSize-4,HSize-4)
        if ach.time < CurTime() then 
            table.remove(AchTable,i)
            --PrintTable(AchTable)
        end
    end
end)