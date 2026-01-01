local PANEL = {}

DEFINE_BASECLASS("EditablePanel")

local matrixZScale = Vector(1, 1, 0.0001)

function PANEL:Init()
	self.childPanels = {}
end

function PANEL:Add(name)
	local panel = BaseClass.Add(self, name)

	if (panel.SetPaintedManually) then
		panel:SetPaintedManually(true)
		self.childPanels[#self.childPanels + 1] = panel
	end

	return panel
end

function PANEL:Paint()
	local bShouldScale = (self.currentScale or 1) != 1
	local matrix

	-- draw child panels with scaling if needed
	if (bShouldScale) then
		matrix = Matrix()

		local center = Vector(ScrW() / 2, ScrH() / 2)

		matrix:Translate(center)
		matrix:Scale(matrixZScale * self.currentScale)
		matrix:Translate(-center)

		cam.PushModelMatrix(matrix)
		self.currentMatrix = matrix
	end

	for i = 1, #self.childPanels do
		if not (IsValid(self.childPanels[i])) then
			continue
		end

		self.childPanels[i]:PaintManual()
	end

	if (bShouldScale) then
		cam.PopModelMatrix()
		self.currentMatrix = nil
	end
end

vgui.Register("zb_ScrappersLongFrame", PANEL, "EditablePanel")