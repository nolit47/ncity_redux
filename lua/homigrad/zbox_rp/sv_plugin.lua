--\\
	hg.ZBOX_RP = hg.ZBOX_RP or {}
	local PLUGIN = hg.ZBOX_RP
--//

PLUGIN.Hooks = PLUGIN.Hooks or {}

--\\Restrictions
	local disabled_spawn_hooks = {
		"PlayerSpawnVehicle",
		"PlayerSpawnRagdoll",
		"PlayerSpawnNPC",
		"PlayerSpawnEffect",
		"PlayerSpawnSENT",
		"PlayerSpawnObject",
		"PlayerSpawnProp",
		"PlayerSpawnSWEP",
		"PlayerNoClip",
		"PlayerGiveSWEP",
	}
	
	for _, hook_name in ipairs(disabled_spawn_hooks) do
		PLUGIN.Hooks[hook_name] = function(ply, ent_name)
			if(!ply:IsAdmin())then
				return false
			end
		end
	end
--//

--\\Toggle
	--=\\Start and End
		function PLUGIN.Start()
			
			--\\Hooks
				for hook_name, hook_func in pairs(PLUGIN.Hooks) do
					print(hook_name, "ZBOX_RP", hook_func)
					hook.Add(hook_name, "ZBOX_RP", hook_func)
				end
			--//
		end

		function PLUGIN.End()
		
			--\\Hooks
				for hook_name, _ in pairs(PLUGIN.Hooks) do
					hook.Remove(hook_name, "ZBOX_RP")
				end
			--//
		end
	--=//

	function PLUGIN.Toggle(state)
		if(PLUGIN.State != state)then
			if(state)then
				PLUGIN.Start()
			else
				PLUGIN.End()
			end
		end
		
		PLUGIN.State = state
	end
--//

--\\AutoCleaner
	PLUGIN.Hooks["Think"] = function()
		
	end
--//