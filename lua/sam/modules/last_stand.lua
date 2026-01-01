sam.command.set_category("Last Stand")
sam.command.new("Round Restart")
    :SetPermission("superadmin")
    :SetCategory("Last Stand")
    :Help("Restarts active round.")
    :GetRestArgs(false)
 
    :MenuHide(false)
    :DisableNotify(false)

    :AddArg("text", {
        optional = false,
        default = "Shit happens",
        hint = "Restart Round.",
    })
    
    :OnExecute(function(ply, command, args)
        if #player.GetAll() < MinPlayers() then
            sam.player.send_message(self, "Required more players to restart round.", {
                A = calling_ply
            })
        else RoundRestart()
            sam.player.send_message(nil, "{A} has restarted round.", {
                A = calling_ply
            })
        end
    end)
:End()

sam.command.set_category("Last Stand")
sam.command.new("God Fix")
    :SetPermission("hp", "admin")
    :SetCategory("Last Stand")
    :Help("Fixes God mode, if configs was changed.")
    :GetRestArgs(false)
 
    :MenuHide(false)
    :DisableNotify(false)

    :AddArg("text", {
        optional = false,
        default = "Shit happens",
        hint = "Restart Round.",
    })
    
    :OnExecute(function(ply, command, args)
        if canattack == false and GetState() == STATE_LIVE then
		    canattack = true
            sam.player.send_message(nil, "{A} Fixed player damage.", {
                A = ply
            })
		    net.Start("LST_ActionStart")
		    net.Broadcast()
	        else 
                sam.player.send_message(self, "Player damage are already enabled.", {})
	    end
    end)
:End()

sam.command.set_category("Last Stand")
sam.command.new("Launch Nuke")
    :SetPermission("hp", "admin")
    :SetCategory("Last Stand")
    :Help("Starts Nuke Event.")
    :GetRestArgs(false)
 
    :MenuHide(false)
    :DisableNotify(false)
    
    :AddArg("text", {
        optional = false,
        default = "Shit happens",
        hint = "Restart Round.",
    })

    :OnExecute(function(ply, command, args)
        if GetState() == STATE_LIVE then
            RunEvents(1)
            PrintMessage(HUD_PRINTCENTER, "Nuclear airstrike inbound!")
            sam.player.send_message(nil, "{A} has called airstrike inbound.", {
                A = ply
            })
        else 
            sam.player.send_message(self, "Round are not active to start Event.", {})
        end
    end)
:End()

sam.command.set_category("Last Stand")
sam.command.new("Launch AirDrops")
    :SetPermission("hp", "admin")
    :SetCategory("Last Stand")
    :Help("Starts AirDrop Event.")
    :GetRestArgs(false)

    :AddArg("text", {
        optional = false,
        default = "Shit happens",
        hint = "Restart Round.",
    })
 
    :MenuHide(false)
    :DisableNotify(false)
    
    :OnExecute(function(ply, command, args)
        if GetState() == STATE_LIVE then
            RunEvents(2)
            PrintMessage(HUD_PRINTCENTER, tostring(#allspawns) .. " supply airdrops incoming!")
            sam.player.send_message(nil, tostring(#allspawns) .. "{A} has called airdrops.", {
                A = ply
            })
        else 
            sam.player.send_message(self, "Round are not active to start Event.", {})
        end
    end)
:End()