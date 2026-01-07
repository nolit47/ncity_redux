surface.CreateFont("HTP_MainTitle", {
    font = "Arial",
    size = 42,
    weight = 900,
    extended = true,
    antialias = true
})

surface.CreateFont("HTP_Header", {
    font = "Arial",
    size = 22,
    weight = 800,
    extended = true,
    antialias = true
})

surface.CreateFont("HTP_Description", {
    font = "Arial",
    size = 18,
    weight = 400,
    extended = true,
    antialias = true
})

local PANEL = {}

function PANEL:Init()
    self:SetSize(750, 550)
    self:Center()
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.3, 0)
    self.BGColor = Color(18, 18, 22, 252)
    
    local topBar = vgui.Create("DPanel", self)
    topBar:Dock(TOP)
    topBar:SetTall(80)
    topBar.Paint = function(s, w, h)
        draw.SimpleText("КАК ИГРАТЬ", "HTP_MainTitle", w/2, h/2 + 5, Color(230, 40, 40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.RoundedBox(0, w * 0.25, h - 5, w * 0.5, 2, Color(230, 40, 40, 100))
    end

    self.Scroll = vgui.Create("DScrollPanel", self)
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(30, 10, 20, 15)

    local bar = self.Scroll:GetVBar()
    bar:SetWide(4)
    bar:SetHideButtons(true)
    function bar:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 5)) end
    function bar.btnGrip:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(230, 40, 40, 180)) end




    local function AddItem(title, desc, imgPath, descAfterImg)
        if title and title ~= "" then
            local category = self.Scroll:Add("DLabel")
            category:SetText(title)
            category:SetFont("HTP_Header")
            category:SetTextColor(Color(230, 40, 40))
            category:Dock(TOP)
            category:DockMargin(0, 15, 0, 2)
            category:SizeToContents()
        end

        if desc and desc ~= "" then
            local text = self.Scroll:Add("DLabel")
            text:SetText(desc)
            text:SetFont("HTP_Description")
            text:SetTextColor(Color(220, 220, 220))
            text:SetWrap(true)
            text:SetAutoStretchVertical(true)
            text:Dock(TOP)
            text:DockMargin(10, 0, 0, 10)
        end

        if imgPath then
            local mat = Material(imgPath, "smooth noclamp")
            local img = self.Scroll:Add("DPanel")
            img:SetTall(200) -- height
            img:Dock(TOP)
            img:DockMargin(10, 10, 10, 15)
            img.Paint = function(s, w, h)
                surface.SetMaterial(mat)
                surface.SetDrawColor(255, 255, 255, 255)

                local size = math.min(w, h)
                surface.DrawTexturedRect(w/2 - size/2, 0, size, size) 
            end
        end

        if descAfterImg and descAfterImg ~= "" then
            local text2 = self.Scroll:Add("DLabel")
            text2:SetText(descAfterImg)
            text2:SetFont("HTP_Description")
            text2:SetTextColor(Color(220, 220, 220))
            text2:SetWrap(true)
            text2:SetAutoStretchVertical(true)
            text2:Dock(TOP)
            text2:DockMargin(10, 0, 0, 10)
        end
    end

    AddItem("ОСНОВЫ", 
        "\nВзаимодействие с миром или с разными штуками происходит через круговое меню - зажми G.", 
        "tutorial/radial_menu.png",
        "Если ты держишь какое-нибудь оружие, то взаимодействие будет происходить через него.\n" ..
        "• Чтобы выбросить оружие, зажми G и выбери пункт 'Выбросить оружие'\n"
    )

    AddItem("РЭГДОЛ", 
        "\nЧтобы зайти в рэгдол, используй команду FAKE\n(Эту команду можно забиндить на любую кнопку. К примеру напиши в консоли bind h fake чтобы падать на кнопку H)")
    
    -- RAGDOL DVIZHENIE
    AddItem("КАК ДВИГАТЬСЯ В РЭГДОЛЕ", 
        "\n• E (зажать) - контроллировать голову мышкой\n" ..
        "• ЛКМ / ПКМ - использовать левую или правую руку.\n" ..
        "• SHIFT / ALT - ползти, поочередно перебирая руками.\n" ..
        "• Комбинация W + E + SHIFT/ALT позволит тебе ползти вперед.",
		"tutorial/hands.png"
	)

	AddItem("БОЙ", 
        "",
        "tutorial/invslot.png",
        "\nДраться кулаками можно взяв Hands который находится в первом слоте\n" ..
		"\n" ..
        "• ЛКМ - атаковать\n" ..
        "• ПКМ (зажать) - блокировать удары\n" ..
        "• Обыск: зажми E + ПКМ на игроке который находится в рэгдолле.\n" ..
        "• Проверка пульса: нажми R + ПКМ на игроке который находится в рэгдолле."
    )

    local close = vgui.Create("DButton", self)
    close:Dock(BOTTOM)
    close:SetTall(50)
    close:SetText("ЗАКРЫТЬ")
    close:SetFont("HTP_Header")
    close:SetTextColor(Color(255, 255, 255))
    close:DockMargin(180, 10, 180, 25)
    
    close.Paint = function(s, w, h)
        local hover = s:IsHovered()
        local alpha = hover and 255 or 150
        draw.RoundedBox(4, 0, 0, w, h, Color(230, 40, 40, alpha))
        if hover then
            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawRect(0, 0, w, h)
        end
    end
    
    close.DoClick = function()
        self:AlphaTo(0, 0.2, 0, function() self:Remove() end)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.BGColor)
    surface.SetDrawColor(230, 40, 40, 40)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    if hg and hg.DrawBlur then
        hg.DrawBlur(self, 2)
    end
end

vgui.Register("HowToPlayPanel", PANEL, "EditablePanel")

concommand.Add("hg_howtoplay", function()
    if IsValid(HowToPlayMenu) then HowToPlayMenu:Remove() end
    HowToPlayMenu = vgui.Create("HowToPlayPanel")
end)