--
util.AddNetworkString("hg_booom")
hg = hg or {}
function hg.FindOtherExplosive(inflictor,pos,radius)

end

function hg.MakeCombinedExplosion()

end

local ExpTypes = {
    Fire = function(Ent,Force,Mass)
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), Ent
        util.BlastDamage(Ent, Owner, SelfPos, (Force/15.5) / 0.01905, Force * 15)
		hgWreckBuildings(Ent, SelfPos, Force / 50, Force/6, false)
		hgBlastDoors(Ent, SelfPos, Force / 50, Force/6, false)

		ParticleEffect("pcf_jack_incendiary_ground_sm2",SelfPos,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Fire")
        net.Broadcast()

		timer.Simple(.01, function()
			if not IsValid(Ent) then return end
			for i = 0, 10 do
				local Tr = util.QuickTrace(SelfPos, -vector_up, {Ent})
				if Tr.Hit then
					util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end
		end)

		if not IsValid(Ent) then return end
		local multi = math.min(Mass/5,20)
		
		local Tr = util.QuickTrace(SelfPos, -vector_up*500, {Ent})
		local fire = CreateVFire(game.GetWorld(), Tr.HitPos, Tr.HitNormal, 150 / 7 * multi, Ent)
		if IsValid(fire) then
			fire:ChangeLife(150)
		end
		for i = 1,multi/2 do
			local randvec = VectorRand(-1000,1000)--VectorRand(-1,1) * math.random(1000)
			randvec[3] = math.random(100,1000)
			CreateVFireBall(20, 50, SelfPos + vector_up * 10, randvec)
		end
		local vecCone = Vector(5, 5, 0)
		local bullet = {}
		bullet.Src = SelfPos
		bullet.Spread = vecCone
		bullet.Force = 0.01
		bullet.Damage = Force
		bullet.AmmoType = "Metal Debris"
		bullet.Attacker = Owner
		bullet.Distance = 15000
		bullet.DisableLagComp = true
		bullet.Filter = {}
		
		co = coroutine.create(function()
			local LastShrapnel = SysTime()
			for i = 1, multi*3 do
				LastShrapnel = SysTime()
				if not IsValid(Ent) then return end
				bullet.Dir = Ent:GetAngles():Forward() * math.random(-1,1)
				bullet.Spread = vecCone * (i / Mass/5)
				Ent:FireLuaBullets(bullet, true)
				LastShrapnel = SysTime() - LastShrapnel
				if LastShrapnel > 0.001 then
					coroutine.yield()
				end
			end
			Ent.ShrapnelDone = true
		end)

        util.ScreenShake(SelfPos,99999,99999,1,3000)

        coroutine.resume(co)

		local index = Ent:EntIndex()

		timer.Create("GrenadeCheck_" .. index, 0, 0, function()
			if !IsValid(Ent) then
				timer.Remove("GrenadeCheck_" .. index)
			end
			coroutine.resume(co)
			if Ent.ShrapnelDone then
				if not IsValid(Ent) then return end
				Ent:StopSound("weapons/ins2rpg7/rpg_rocket_loop.wav")
				SafeRemoveEntity(Ent)
				timer.Remove("GrenadeCheck_" .. index)
			end
		end)
    end,

    Sharpnel = function(Ent,Force,Mass)
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), Ent
        util.BlastDamage(Ent, Owner, SelfPos, (Force/7.5) / 0.01905, Force * 1)
		hgWreckBuildings(Ent, SelfPos, Force / 50, Force/6, false)
		hgBlastDoors(Ent, SelfPos, Force / 50, Force/6, false)

        ParticleEffect("pcf_jack_groundsplode_medium",SelfPos,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Sharpnel")
        net.Broadcast()

		timer.Simple(.01, function()
			if not IsValid(Ent) then return end
			for i = 0, 10 do
				local Tr = util.QuickTrace(SelfPos, -vector_up*5000, {Ent})
				if Tr.Hit then
					util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end
		end)
		local vecCone = Vector(5, 5, 0)
		local bullet = {}
		bullet.Src = SelfPos
		bullet.Spread = vecCone
		bullet.Force = 0.01
		bullet.Damage = Force
		bullet.AmmoType = "Metal Debris"
		bullet.Attacker = Owner
		bullet.Distance = 15000
		bullet.DisableLagComp = true
		bullet.Filter = {}
		
		co = coroutine.create(function()
			local LastShrapnel = SysTime()
			for i = 1, multi*5 do
				LastShrapnel = SysTime()
				if not IsValid(Ent) then return end
				bullet.Dir = Ent:GetAngles():Forward() * math.random(-1,1)
				bullet.Spread = vecCone * (i / Mass/5)
				Ent:FireLuaBullets(bullet, true)
				LastShrapnel = SysTime() - LastShrapnel
				if LastShrapnel > 0.001 then
					coroutine.yield()
				end
			end
			Ent.ShrapnelDone = true
		end)

        util.ScreenShake(SelfPos,99999,99999,1,3000)

        coroutine.resume(co)

		local index = Ent:EntIndex()

		timer.Create("GrenadeCheck_" .. index, 0, 0, function()
			if !IsValid(Ent) then
				timer.Remove("GrenadeCheck_" .. index)
			end
			coroutine.resume(co)
			if Ent.ShrapnelDone then
				if not IsValid(Ent) then return end
				Ent:StopSound("weapons/ins2rpg7/rpg_rocket_loop.wav")
				SafeRemoveEntity(Ent)
				timer.Remove("GrenadeCheck_" .. index)
			end
		end)
    end,
    Normal = function(Ent,Force)
        local SelfPos, Owner = Ent:LocalToWorld(Ent:OBBCenter()), Ent
        util.BlastDamage(Ent, Owner, SelfPos, (Force/7.5) / 0.01905, Force * 1)
		hgWreckBuildings(Ent, SelfPos, Force / 50, Force/6, false)
		hgBlastDoors(Ent, SelfPos, Force / 50, Force/6, false)

        ParticleEffect("pcf_jack_groundsplode_small",SelfPos,vector_up:Angle())
		hg.ExplosionEffect(SelfPos, Force / 0.2, 80)

        net.Start("hg_booom")
            net.WriteVector(SelfPos)
            net.WriteString("Normal")
        net.Broadcast()

		timer.Simple(.01, function()
			if not IsValid(Ent) then return end
			for i = 0, 10 do
				local Tr = util.QuickTrace(SelfPos, -vector_up, {Ent})
				if Tr.Hit then
					util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end
		end)

		timer.Simple(0, function()
			if not IsValid(Ent) then return end
            util.ScreenShake(SelfPos,99999,99999,1,3000)
		end)
        timer.Simple(.011, function()
			if not IsValid(Ent) then return end
			Ent:Remove()
		end)
    end,
}

function hg.PropExplosion(Ent, ExpType, Force, Mass)
    ExpTypes[ExpType](Ent,Force, Mass)
end

local expItems = {
    ["models/props_c17/oildrum001_explosive.mdl"] = {ExpType = "Fire", Force = 75},
    ["models/props_junk/gascan001a.mdl"] = {ExpType = "Fire", Force = 40},
    ["models/props_junk/propane_tank001a.mdl"] = {ExpType = "Sharpnel", Force = 30},
    ["models/props_junk/metalgascan.mdl"] = {ExpType = "Fire", Force = 40},
    ["models/props_junk/PropaneCanister001a.mdl"] = {ExpType = "Sharpnel", Force = 40},
    ["models/props_c17/canister01a.mdl"] = {ExpType = "Sharpnel", Force = 55},
    ["models/props_c17/canister02a.mdl"] = {ExpType = "Sharpnel", Force = 55},
    ["models/props_c17/canister_propane01a.mdl"] = {ExpType = "Fire", Force = 80}
}

hook.Add("EntityTakeDamage","ExplosiveDamage", function( target, dmginfo )
	--print(target.Volume)
    if IsValid(target) and expItems[target:GetModel()] and dmginfo:IsDamageType(DMG_BLAST_SURFACE + DMG_BLAST + DMG_BURN) and not target.babahnut then
		target.hp = target.hp or 50
		target.hp = target.hp - (dmginfo:GetDamage() / (dmginfo:IsDamageType(DMG_BURN) and 5 or 1))
		if !target.Volume or ((target.hp <= 0) and (target.Volume > 0)) then
			local tbl = expItems[target:GetModel()]
			target.babahnut = true
			hg.PropExplosion( target, tbl.ExpType, (target.Volume or tbl.Force) * 2, target:GetPhysicsObject():GetMass() )
		end
		dmginfo:SetDamage(0)
    end
	if IsValid(target) and expItems[target:GetModel()] then
		dmginfo:SetDamage(0)
		return
	end
end)