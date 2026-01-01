MODE.name = "streetsweep"

local MODE = MODE

MODE.CaptureColors = {
    [0] = Color(48, 87, 229),
    [1] = Color(215, 42, 42)
}

surface.CreateFont("ZB_SS_MediumSmall", {
    font = "Bahnschrift",
    size = ScreenScale(6),
    extended = true,
    weight = 400,
    antialias = true
})

function MODE:RoundStart()
    self:ResetValues()
end

net.Receive("SS_ChangePhase", function()
    if IsValid(zb.SSMap) then
        zb.SSMap:SetPhase(net.ReadUInt(5))
    end
end)

net.Receive("SS_UpdateResearch", function()
    local ResearchTable = net.ReadTable()

    MODE.CurrentResearch = ResearchTable

    if IsValid(zb.SSMap) then
        zb.SSMap.CurrentResearch = ResearchTable
    end
end)

net.Receive("SS_CreateMap", function()
    vgui.Create("ZB_SSMap")
end)

net.Receive("SS_ResearchVote", function()
    local lane = net.ReadString()
    local k = net.ReadUInt(6)

    local votes = net.ReadUInt(32)

    MODE.ResearchVotes[lane][k].Votes = MODE.ResearchVotes[lane][k].Votes or {}

    MODE.ResearchVotes[lane][k]["Votes"][LocalPlayer():Team()] = votes

    if IsValid(zb.SSMap) then
        zb.SSMap.Research[lane][k].Votes = votes
    end
end)