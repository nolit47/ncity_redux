local PANEL = {}
local MODE = MODE

local sw, sh = ScrW(), ScrH()

local gradient_d = Material("vgui/gradient-d")
local gradient_u = Material("vgui/gradient-u")

local red = Color(239, 47, 47)
local red2 = Color(78, 16, 16)

local green = Color(81, 213, 67)

local animInProgress = false

local animations

local ActivePanel

local function SlidePanel(oldPanel, newPanel)
	if !animInProgress then

		surface.PlaySound("zbattle/scrappers/button.wav")

		animInProgress = true
		animations.CurrentScale = 1
		animations.OldScale = 2

		animations.CurrentAlpha = 1
		animations.OldAlpha = 0

		if IsValid(newPanel) then
			newPanel:Show()
		end

		ActivePanel = newPanel

		animations:CreateAnimation(1, {
			index = 1,
			target = {
				CurrentScale = 0,
				OldScale = 1
			},
			easing = "outExpo",
			bIgnoreConfig = true,
			Think = function()
				if !IsValid(oldPanel) or !IsValid(newPanel) then return end

				newPanel.currentScale = animations.OldScale
				oldPanel.currentScale = math.Remap(animations.CurrentScale, 0, 1, 0.5, 1)
			end,
			OnComplete = function()
				animations.CurrentScale = nil
				animations.OldScale = nil
			end
		})

		animations:CreateAnimation(0.5, {
			index = 2,
			target = {
				CurrentAlpha = 0,
				OldAlpha = 1
			},
			easing = "outExpo",
			bIgnoreConfig = true,
			Think = function()
				if !IsValid(oldPanel) or !IsValid(newPanel) then return end

				newPanel:SetAlpha(animations.OldAlpha * 255)
				oldPanel:SetAlpha(animations.CurrentAlpha * 255)
			end,
			OnComplete = function()
				animations.CurrentAlpha = 1
				animations.OldAlpha = 0
				animInProgress = false

				if IsValid(oldPanel) then
					oldPanel:Hide()
				end
			end
		})
	end
end

local function SlidePanelBack(oldPanel, newPanel)
	if !animInProgress then
		animInProgress = true

		surface.PlaySound("zbattle/scrappers/button.wav")

		animations.CurrentScale = 1
		animations.OldScale = 0

		animations.CurrentAlpha = 1
		animations.OldAlpha = 0

		if IsValid(newPanel) then
			newPanel:Show()
		end

		ActivePanel = newPanel

		animations:CreateAnimation(1, {
			index = 1,
			target = {
				CurrentScale = 2,
				OldScale = 1
			},
			easing = "outExpo",
			bIgnoreConfig = true,
			Think = function()
				if !IsValid(oldPanel) or !IsValid(newPanel) then return end

				newPanel.currentScale = animations.OldScale
				oldPanel.currentScale = animations.CurrentScale

				newPanel:SetAlpha(animations.OldScale * 255)
				oldPanel:SetAlpha((1 - animations.OldScale) * 255)
			end,
			OnComplete = function()
				animations.CurrentScale = nil
				animations.OldScale = nil

				if IsValid(oldPanel) then
					oldPanel:Hide()
				end
			end
		})

		animations:CreateAnimation(0.5, {
			index = 2,
			target = {
				CurrentAlpha = 0,
				OldAlpha = 1
			},
			easing = "outExpo",
			bIgnoreConfig = true,
			Think = function()
				if !IsValid(oldPanel) or !IsValid(newPanel) then return end

				newPanel:SetAlpha(animations.OldAlpha * 255)
				oldPanel:SetAlpha(animations.CurrentAlpha * 255)
			end,
			OnComplete = function()
				animInProgress = false
				animations.CurrentAlpha = 1
				animations.OldAlpha = 0

				if IsValid(oldPanel) then
					oldPanel:Hide()
				end
			end
		})
	end
end

local ShopSound = ShopSound or nil

function PANEL:Init()
	if IsValid(zb.ScrappersShop) then
		zb.ScrappersShop:Remove()
	end

	zb.ScrappersShop = self

	self:SetSize(sw, sh)
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	self:RequestFocus()

	gui.EnableScreenClicker(true)

	if !ShopSound then
	    sound.PlayFile("sound/zbattle/shop.mp3", "", function(station)
	        ShopSound = station
	        station:SetVolume(0.2)
	    end)
	end

	animations = self:Add("EditablePanel")
	animations:SetZPos(-999)

	self.grid = self:Add("ZB_ScrappersGrid")
	self.grid:SetSize(sw, sh)
	self.grid:FadeColor(15, 15, 15, 5)

	ActivePanel = self.MainFrame
	PrevPanel = self.MainFrame

	self.MainFrame = self:PopulateMainMenu()
	self.ShopFrame = self:PopulateShop()
	-- self.InventoryFrame = self:PopulateInventory()
end

function PANEL:Think()
	if LocalPlayer():KeyDown(IN_RELOAD) and ActivePanel and ActivePanel.PrevPanel then
		SlidePanelBack(ActivePanel, ActivePanel.PrevPanel)
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(15, 15, 15)
	surface.DrawRect(0, 0, w, h)
end

DEFINE_BASECLASS("EditablePanel")

local isReady
function PANEL:PopulateMainMenu()
	local frame = self:Add("zb_ScrappersLongFrame")
	frame:SetSize(sw, sh)

	frame.ready = frame:Add("ZB_ScrappersLongButton")
	frame.ready:SetPos(sw * (0.5 - 0.075), sh * 0.8 )
	frame.ready:SetSize(sw * 0.15, sh * 0.05)
	frame.ready:SetText("Готов")

	frame.ready.DoClick = function(self)
		isReady = !isReady
		net.Start("ZB_PlayerReady")
			net.WriteBool(isReady)
		net.SendToServer()
		self.setalpha = isReady and 255 or 0
	end

	local market = frame:Add("ZB_ScrappersLongButton")
	market:SetPos(sw * 0.25, sh * 0.4)
	market:SetSize(sw * 0.15, sh * 0.05)
	market:SetText("Маркет")

	market.DoClick = function()
		SlidePanel(frame, self.ShopFrame)
	end

	local squad = frame:Add("ZB_ScrappersLongButton")
	squad:SetPos(sw * 0.425, sh * 0.4)
	squad:SetSize(sw * 0.15, sh * 0.05)
	squad:SetText("Отряд")

	squad.DoClick = function()
		SlidePanel(frame, self.SquadFrame)
	end

	local inventory = frame:Add("ZB_ScrappersLongButton")
	inventory:SetPos(sw * 0.6, sh * 0.4)
	inventory:SetSize(sw * 0.15, sh * 0.05)
	inventory:SetText("Инвентарь")

	inventory.DoClick = function()
		self.InventoryFrame:PopulateSlots()

		SlidePanel(frame, self.InventoryFrame)
	end

	local money = frame:Add("EditablePanel")
	money:SetPos(sw * 0.4, sh * 0.3)
	money:SetSize(sw * 0.2, sh * 0.1)

	function money:Paint(w, h)
		draw.GlowingText("¤" .. LocalPlayer():GetLocalVar("zb_Scrappers_Money", MODE.StartingMoney), "ZB_ScrappersMediumLarge", w / 2, h / 2, red, red, red2, TEXT_ALIGN_CENTER)
	end

	frame.PopulateSlots = function()
		local RaidInventory = zb.ScrappersRaidInventory or {}

		if frame.primary then frame.primary:Remove() end
		if frame.secondary then frame.secondary:Remove() end
		if frame.melee then frame.melee:Remove() end
		if frame.other then frame.other:Remove() end
		if frame.medicine then frame.medicine:Remove() end
		if frame.armor then frame.armor:Remove() end

		frame.primary  = frame:Add("ZB_MainSlotLong")
		frame.primary:SetSize(sw * 0.15, sh * 0.15)
		frame.primary:SetPos(sw * 0.25, sh * 0.47 )

		frame.primary.text = "Основное"

		frame.primary:SetWeapon(RaidInventory["Primary"])

		frame.primary.DoClick = function(this)
			net.Start("zb_FromRaidToInv")
				net.WriteString("Primary")
			net.SendToServer()

			RaidInventory["Primary"] = nil
			this:Remove()

			timer.Simple(0.1 * math.max(LocalPlayer():Ping() / 10,1),function()
				frame.PopulateSlots()
			end)
		end

		frame.secondary  = frame:Add("ZB_MainSlotLong")
		frame.secondary:SetSize(sw * 0.15, sh * 0.15)
		frame.secondary:SetPos(sw * (0.5 - 0.075), sh * 0.47 )

		frame.secondary.text = "Второстепенное"

		frame.secondary:SetWeapon(RaidInventory["Secondary"])

		frame.secondary.DoClick = function(this)
			net.Start("zb_FromRaidToInv")
				net.WriteString("Secondary")
			net.SendToServer()

			RaidInventory["Secondary"] = nil
			this:Remove()

			timer.Simple(0.1 * math.max(LocalPlayer():Ping() / 10,1),function()
				frame.PopulateSlots()
			end)
		end

		frame.melee  = frame:Add("ZB_MainSlotLong")
		frame.melee:SetSize(sw * 0.15, sh * 0.15)
		frame.melee:SetPos(sw * 0.6, sh * 0.47 )

		frame.melee.text = "Холодное"

		frame.melee:SetWeapon(RaidInventory["Melee"])

		frame.melee.DoClick = function(this, k)
			net.Start("zb_FromRaidToInv")
				net.WriteString("Melee")
				net.WriteUInt(k, 8)
			net.SendToServer()

			table.remove(RaidInventory["Melee"], k)
			this:Remove()

			timer.Simple(0.1 * math.max(LocalPlayer():Ping() / 10,1),function()
				frame.PopulateSlots()
			end)
		end

		frame.medicine  = frame:Add("ZB_MainSlotLong")
		frame.medicine:SetSize(sw * 0.15, sh * 0.15)
		frame.medicine:SetPos(sw * 0.25, sh * 0.64 )

		frame.medicine.text = "Медицина"

		frame.medicine:SetWeapon(RaidInventory["Medicine"])

		frame.medicine.DoClick = function(this, k)
			net.Start("zb_FromRaidToInv")
				net.WriteString("Medicine")
				net.WriteUInt(k, 8)
			net.SendToServer()

			table.remove(RaidInventory["Medicine"], k)
			this:Remove()

			timer.Simple(0.1 * math.max(LocalPlayer():Ping() / 10,1),function()
				frame.PopulateSlots()
			end)
		end

		frame.other  = frame:Add("ZB_MainSlotLong")
		frame.other:SetSize(sw * 0.15, sh * 0.15)
		frame.other:SetPos(sw * (0.5 - 0.075), sh * 0.64 )

		frame.other.text = "Разное"

		frame.other:SetWeapon(RaidInventory["Other"])

		frame.other.DoClick = function(this, k)
			net.Start("zb_FromRaidToInv")
				net.WriteString("Other")
				net.WriteUInt(k, 8)
			net.SendToServer()

			table.remove(RaidInventory["Other"], k)
			this:Remove()

			timer.Simple(0.1 * math.max(LocalPlayer():Ping() / 10,1),function()
				frame.PopulateSlots()
			end)
		end

		frame.armor  = frame:Add("ZB_MainSlotLong")
		frame.armor:SetSize(sw * 0.15, sh * 0.15)
		frame.armor:SetPos(sw * 0.6, sh * 0.64 )

		frame.armor.text = "Броня"

		frame.armor:SetWeapon(RaidInventory["Armor"])

		frame.armor.DoClick = function(this, k)
			net.Start("zb_FromRaidToInv")
				net.WriteString("Armor")
				net.WriteUInt(k, 8)
			net.SendToServer()

			table.remove(RaidInventory["Armor"], k)
			this:Remove()

			timer.Simple(0.1 * math.max(LocalPlayer():Ping() / 10,1),function()
				frame.PopulateSlots()
			end)
		end
	end

	frame.PopulateSlots()

	return frame
end

local matrixZScale = Vector(1, 1, 0.0001)

function PANEL:PopulateShop()
	local frame = self:Add("zb_ScrappersLongFrame")
	frame:SetSize(sw, sh)

	frame:SetAlpha(0)
	frame:Hide()

	frame.PrevPanel = self.MainFrame

	local title = frame:Add("EditablePanel")
	title:SetPos(0, 0)
	title:SetSize(sw, sh)

	function title:Paint(w, h)
		matrix = Matrix()

		local center = Vector(ScrW() / 2, ScrH() / 2)

		matrix:Translate(center)
		matrix:Scale(matrixZScale * 3)
		matrix:Translate(-center)

		cam.PushModelMatrix(matrix)
			draw.GlowingText("МАРКЕТ", "ZB_ScrappersHumongous", w / 2, h / 2, ColorAlpha(red, 2), ColorAlpha(red, 2), ColorAlpha(red2, 2), TEXT_ALIGN_CENTER)
		cam.PopModelMatrix()
	end

	local weaponry = frame:Add("ZB_ScrappersLongButton")
	weaponry:SetPos(sw * 0.425, sh * 0.33)
	weaponry:SetSize(sw * 0.15, sh * 0.05)
	weaponry:SetText("Оружие")

	weaponry.DoClick = function()
		SlidePanel(frame, self.ShopFrame)
	end

	local armor = frame:Add("ZB_ScrappersLongButton")
	armor:SetPos(sw * 0.425, sh * 0.4)
	armor:SetSize(sw * 0.15, sh * 0.05)
	armor:SetText("Броня")

	armor.DoClick = function()
		SlidePanel(frame, self.ShopFrame)
	end

	local medicine = frame:Add("ZB_ScrappersLongButton")
	medicine:SetPos(sw * 0.425, sh * 0.47)
	medicine:SetSize(sw * 0.15, sh * 0.05)
	medicine:SetText("Медицина")

	medicine.DoClick = function()
		SlidePanel(frame, self.ShopFrame)
	end

	local other = frame:Add("ZB_ScrappersLongButton")
	other:SetPos(sw * 0.425, sh * 0.54)
	other:SetSize(sw * 0.15, sh * 0.05)
	other:SetText("Разное")

	other.DoClick = function()
		SlidePanel(frame, self.ShopFrame)
	end

	local divider = frame:Add("EditablePanel")
	divider:SetPos(sw * 0.425, sh * 0.61)
	divider:SetSize(sw * 0.15, sh * 0.002)
	divider.Paint = function(this, w, h)
		surface.SetDrawColor(239, 47, 47)
		surface.DrawRect(0, 0, w, h)
	end

	local returnButton = frame:Add("ZB_ScrappersLongButton")
	returnButton:SetPos(sw * 0.425, sh * 0.63)
	returnButton:SetSize(sw * 0.15, sh * 0.05)
	returnButton:SetText("Вернуться")

	returnButton.DoClick = function()
		SlidePanelBack(frame, self.MainFrame)
	end

	local money = frame:Add("EditablePanel")
	money:SetPos(sw * 0.4, sh * 0.88)
	money:SetSize(sw * 0.2, sh * 0.1)

	function money:Paint(w, h)
		draw.GlowingText("¤" .. LocalPlayer():GetLocalVar("zb_Scrappers_Money", MODE.StartingMoney), "ZB_ScrappersMediumLarge", w / 2, h / 2, red, red, red2, TEXT_ALIGN_CENTER)
	end

	return frame
end

vgui.Register("ZB_ScrappersLongShop", PANEL, "EditablePanel")