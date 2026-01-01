local MODE = MODE

MODE.name = "scrappers_long"

net.Receive("zb_ScrappersLong_CreateShop", function()
    vgui.Create("ZB_ScrappersLongShop")
end)

net.Receive("zb_ScrappersLong_CloseShop", function()
    if IsValid(zb.ScrappersShop) then
        zb.ScrappersShop:Remove()
    end
end)

