print("[ZBattle] Test library loaded!")
if SERVER then
    util.AddNetworkString("FadeScreen")

    function zb.AddFade()
        net.Start("FadeScreen")
        net.Broadcast()
    end
else
    local faded = false
    local fade = 0
    net.Receive("FadeScreen",function()
        faded = true
        fade = 0
        timer.Simple(6,function()
           hook.Add("RenderScreenspaceEffects","FadeScreen",function()   
                surface.SetDrawColor(0,0,0,255 * fade)
                surface.DrawRect(-1,-1,ScrW() + 1,ScrH() + 1)
                fade = Lerp(FrameTime()*10, fade, 2)
           end)
           timer.Simple(2,function(arguments)
                zb.RemoveFade()
           end)
        end)
    end)

    function zb.RemoveFade()
        hook.Remove("RenderScreenspaceEffects","FadeScreen")
    end
end
