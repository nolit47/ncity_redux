surface.CreateFont("HTP_MainTitle", {
    font = "Open Sans Extrabold",
    size = 42,
    weight = 900,
    extended = true,
    antialias = true
})

surface.CreateFont("HTP_Header", {
    font = "Open Sans",
    size = 22,
    weight = 800,
    extended = true,
    antialias = true
})

surface.CreateFont("HTP_Description", {
    font = "IBM Plex Mono",
    size = 18,
    weight = 400,
    extended = true,
    antialias = true
})

local PANEL = {}

function PANEL:Init()
    self:SetSize(750, 850)
    self:Center()
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.3, 0)
    self.BGColor = Color(18, 18, 22, 252)

    local topBar = vgui.Create("DPanel", self)
    topBar:Dock(TOP)
    topBar:SetTall(70)
    topBar.Paint = function(s, w, h)
        draw.SimpleText("КАК ИГРАТЬ", "HTP_MainTitle", w/2, h/2, Color(230, 40, 40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local tabContainer = vgui.Create("DPanel", self)
    tabContainer:Dock(TOP)
    tabContainer:SetTall(45)
    tabContainer:DockMargin(30, 5, 30, 10)
    tabContainer.Paint = nil

    self.Scroll = vgui.Create("DScrollPanel", self)
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(30, 10, 20, 15)

    local bar = self.Scroll:GetVBar()
    bar:SetWide(4)
    bar:SetHideButtons(true)
    function bar:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 5)) end
    function bar.btnGrip:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(230, 40, 40, 180)) end

    local function AddImage(path)
        if not path then return end
        local mat = Material(path, "smooth noclamp")
        if mat:IsError() then return end

        local img = self.Scroll:Add("DPanel")
        img:Dock(TOP)
        img:DockMargin(10, 10, 10, 15)

        img.PerformLayout = function(s, w)
            local imgW = mat:Width()
            local imgH = mat:Height()
            
            local RATIO = math.min(w / imgW, 1) 
            local newH = imgH * RATIO
            
            s:SetTall(newH)
        end

        img.Paint = function(s, w, h)
            surface.SetMaterial(mat)
            surface.SetDrawColor(255, 255, 255, 255)
            
            local imgW = mat:Width()
            local imgH = mat:Height()
            local RATIO = math.min(w / imgW, 1)
            surface.DrawTexturedRect(w/2 - (imgW * RATIO)/2, 0, imgW * RATIO, imgH * RATIO) 
        end
    end

    local function AddItem(title, desc, imgPath, descAfterImg, imgPath2, descFinal)
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

        if imgPath then AddImage(imgPath) end

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

        if imgPath2 then AddImage(imgPath2) end

        if descFinal and descFinal ~= "" then
            local text3 = self.Scroll:Add("DLabel")
            text3:SetText(descFinal)
            text3:SetFont("HTP_Description")
            text3:SetTextColor(Color(220, 220, 220))
            text3:SetWrap(true)
            text3:SetAutoStretchVertical(true)
            text3:Dock(TOP)
            text3:DockMargin(10, 0, 0, 10)
        end
    end

    local function ShowMain()
        self.Scroll:Clear()
        
        AddItem("ОСНОВЫ", 
            "\nВзаимодействие с миром или с разными штуками происходит через круговое меню - зажми G.", 
            "tutorial/radial_menu.png",
            "Если ты держишь какое-нибудь оружие, то взаимодействие будет происходить через него.\n" ..
            "• Чтобы выбросить оружие, зажми G и выбери пункт 'Выбросить оружие'\n" ..
            "\n" ..
            "ЗНАЙ! Патроны имеют вес, чем больше патронов тем медленее вы будете двигаться.\n" ..
            "\n" ..
            "Для того чтобы их выкинуть зажми G и выбери пункт 'Выбросить патроны'.\n" ..
            "Откроется меню в котором вы должны выбрать количество патронов которых вы хотите выкинуть\n",
            "tutorial/ammo_menu.png",
            "Нажмите ЛКМ на тип патронов которые вы хотите выбросить.\n" ..
            "Еще можно нажать ПКМ чтобы выкинуть все патроны данного типа."
        )

        AddItem("РЭГДОЛ", 
            "\nЧтобы зайти в рэгдол, используй команду FAKE\n(Эту команду можно забиндить на любую кнопку. К примеру напиши в консоли bind h fake чтобы падать на кнопку H)")
        
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
            "\nДраться кулаками можно взяв Hands который по умолчанию находится в первом слоте\n" ..
            "\n" ..
            "• ЛКМ - атаковать\n" ..
            "• ПКМ (зажать) - блокировать удары\n" ..
            "• Обыск: зажми E + ПКМ на игроке который находится в рэгдолле.\n" ..
            "• Проверка пульса: нажми R + ПКМ на игроке который находится в рэгдолле."
        )

        AddItem("АТАЧМЕНТЫ", 
            "" ..
            "Найти атачменты можно по карте (если играете в Zbattle) или же просто заспавнить из Q-меню\n" ..
            "\nДля того чтобы надеть атачменты на оружие зажмите G и выберите Attachments",
            "tutorial/radial_menu_attachments.png",
            "\n" ..
            "Когда вы зашли в Attachments откроется меню, если у вас есть атачменты\n" ..
            "• Нажмите ЛКМ чтобы надеть атачмент на текущее оружие.\n" ..
            "• Нажмите ПКМ чтобы снять атачмент на оружие (если он надет).\n" ..
            "• Нажмите на кнопку Drop чтобы выбросить атачмент из инвентаря.\n",
            "tutorial/menu_attachments.png",
            " "
        )
    end

    local function ShowZBattle()
        self.Scroll:Clear()
        AddItem("ZBATTLE", "Раздел находится в разработке и скоро будет заполнен.")
    end

    local function CreateTab(name, callback)
        local btn = vgui.Create("DButton", tabContainer)
        btn:SetText(name)
        btn:SetFont("HTP_Header")
        btn:Dock(LEFT)
        btn:SetWide(340)
        btn:SetTextColor(Color(255, 255, 255))
        
        btn.Paint = function(s, w, h)
            local active = s.Active
            local hover = s:IsHovered()
            if active then
                draw.RoundedBox(0, 0, 0, w, h, Color(230, 40, 40, 40))
            end
            local lineCol = active and Color(230, 40, 40) or (hover and Color(255, 255, 255, 100) or Color(255, 255, 255, 20))
            draw.RoundedBox(0, 0, h - 3, w, 3, lineCol)
        end

        btn.DoClick = function()
            for _, child in pairs(tabContainer:GetChildren()) do child.Active = false end
            btn.Active = true
            callback()
        end
        return btn
    end

    local btnMain = CreateTab("ОСНОВНОЙ", ShowMain)
    local btnZBattle = CreateTab("ZBATTLE", ShowZBattle)
    
    btnMain.Active = true
    ShowMain()

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
    end
    
    close.DoClick = function()
        self:AlphaTo(0, 0.2, 0, function() self:Remove() end)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.BGColor)
    surface.SetDrawColor(230, 40, 40, 40)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    if hg and hg.DrawBlur then hg.DrawBlur(self, 2) end
end

vgui.Register("HowToPlayPanel", PANEL, "EditablePanel")

concommand.Add("hg_howtoplay", function()
    if IsValid(HowToPlayMenu) then HowToPlayMenu:Remove() end
    HowToPlayMenu = vgui.Create("HowToPlayPanel")
end)