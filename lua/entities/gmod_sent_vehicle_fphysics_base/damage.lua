function ENT:ApplyDamage( damage, type )
	if type == DMG_BLAST then 
		damage = damage * 10
	end

	if type == DMG_BULLET then 
		damage = damage * 2
	end

	local MaxHealth = self:GetMaxHealth()
	local CurHealth = self:GetCurHealth()

	local NewHealth = math.max( math.Round(CurHealth - damage,0) , 0 )

	if NewHealth <= (MaxHealth * 0.6) then
		self:SetOnSmoke( true )
	end

	if MaxHealth > 30 and NewHealth <= 31 then
		if self:EngineActive() then
			self:DamagedStall()
		end
	end

	if NewHealth <= 0 then
		if (type == DMG_BLAST) or damage > MaxHealth then

			self:ExplodeVehicle()

			return
		end

		if self:EngineActive() then
			self:DamagedStall()
		end

		self:SetCurHealth( 0 )

		return
	end

	self:SetCurHealth( NewHealth )
end

function ENT:HurtPlayers( damage )
	if true then return end

	local Driver = self:GetDriver()

	if IsValid( Driver ) then
		if self.RemoteDriver ~= Driver then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( damage )
			dmginfo:SetAttacker( game.GetWorld() )
			dmginfo:SetInflictor( self )
			dmginfo:SetDamageType( DMG_DIRECT )
			Driver:ViewPunch(Angle(-damage*15,0,0))
			Driver:TakeDamageInfo( dmginfo )
		end
	end

	if not istable( self.PassengerSeats ) then return end

	for i = 1, table.Count( self.PassengerSeats ) do
		local Passenger = self.pSeat[i]:GetDriver()
		if not IsValid(Passenger) then continue end

		local dmginfo = DamageInfo()
		dmginfo:SetDamage( damage )
		dmginfo:SetAttacker( game.GetWorld() )
		dmginfo:SetInflictor( self )
		dmginfo:SetDamageType( DMG_DIRECT )
		Passenger:ViewPunch(Angle(-damage*15,0,0))
		Passenger:TakeDamageInfo( dmginfo )
	end
end

function ENT:ExplodeVehicle()
	if not IsValid( self ) then return end
	if self.destroyed then return end

	self.destroyed = true

	local Attacker = self.LastAttacker

	if IsValid( Attacker ) and Attacker:IsPlayer() and LVS then
		net.Start( "lvs_killmarker" )
		net.Send( Attacker )
	end

	local ply = self.EntityOwner
	local skin = self:GetSkin()
	local Col = self:GetColor()
	Col.r = Col.r * 0.8
	Col.g = Col.g * 0.8
	Col.b = Col.b * 0.8
	
	local Driver = self:GetDriver()
	if IsValid( Driver ) then
		if self.RemoteDriver ~= Driver then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( Driver:Health() + Driver:Armor() )
			dmginfo:SetAttacker( self.LastAttacker or game.GetWorld() )
			dmginfo:SetInflictor( self.LastInflictor or game.GetWorld() )
			dmginfo:SetDamageType( DMG_DIRECT )

			Driver:TakeDamageInfo( dmginfo )
		end
	end
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.PassengerSeats ) do
			local Passenger = self.pSeat[i]:GetDriver()
			if IsValid( Passenger ) then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage( Passenger:Health() + Passenger:Armor() )
				dmginfo:SetAttacker( self.LastAttacker or game.GetWorld() )
				dmginfo:SetInflictor( self.LastInflictor or game.GetWorld() )
				dmginfo:SetDamageType( DMG_DIRECT )

				Passenger:TakeDamageInfo( dmginfo )
			end
		end
	end

	if self.GibModels then
		local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
		bprop:SetModel( self.GibModels[1] )
		bprop:SetPos( self:GetPos() )
		bprop:SetAngles( self:GetAngles() )
		bprop.MakeSound = true
		bprop:Spawn()
		bprop:Activate()

		local bpropPhysObj = bprop:GetPhysicsObject()

		if IsValid( bpropPhysObj ) then
			bpropPhysObj:SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
			bpropPhysObj:SetMass( self.Mass * 0.75 )
		end

		bprop.DoNotDuplicate = true
		bprop:SetColor( Col )
		bprop:SetSkin( skin )
		
		self.Gib = bprop
		
		simfphys.SetOwner( ply , bprop )
		
		if IsValid( ply ) then
			undo.Create( "Gib" )
			undo.SetPlayer( ply )
			undo.AddEntity( bprop )
			undo.SetCustomUndoText( "Undone Gib" )
			undo.Finish( "Gib" )
			ply:AddCleanup( "Gibs", bprop )
		end
		
		bprop.Gibs = {}
		for i = 2, table.Count( self.GibModels ) do
			local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
			prop:SetModel( self.GibModels[i] )			
			prop:SetPos( self:GetPos() )
			prop:SetAngles( self:GetAngles() )
			prop:SetOwner( bprop )
			prop:Spawn()
			prop:Activate()
			prop.DoNotDuplicate = true
			bprop:DeleteOnRemove( prop )
			bprop.Gibs[i-1] = prop
			
			local PhysObj = prop:GetPhysicsObject()
			if IsValid( PhysObj ) then
				PhysObj:SetVelocityInstantaneous( VectorRand() * 500 + self:GetVelocity() + Vector(0,0,math.random(150,250)) )
				PhysObj:AddAngleVelocity( VectorRand() )
			end
			
			
			simfphys.SetOwner( ply , prop )
		end
	else
		
		local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
		bprop:SetModel( self:GetModel() )			
		bprop:SetPos( self:GetPos() )
		bprop:SetAngles( self:GetAngles() )
		bprop.MakeSound = true
		bprop:Spawn()
		bprop:Activate()
		bprop:GetPhysicsObject():SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
		bprop:GetPhysicsObject():SetMass( self.Mass * 0.75 )
		bprop.DoNotDuplicate = true
		bprop:SetColor( Col )
		bprop:SetSkin( skin )
		for i = 0, self:GetNumBodyGroups() do
			bprop:SetBodygroup(i, self:GetBodygroup(i))
		end
		
		self.Gib = bprop
		
		simfphys.SetOwner( ply , bprop )
		
		if IsValid( ply ) then
			undo.Create( "Gib" )
			undo.SetPlayer( ply )
			undo.AddEntity( bprop )
			undo.SetCustomUndoText( "Undone Gib" )
			undo.Finish( "Gib" )
			ply:AddCleanup( "Gibs", bprop )
		end
		
		if self.CustomWheels == true and not self.NoWheelGibs then
			bprop.Wheels = {}
			for i = 1, table.Count( self.GhostWheels ) do
				local Wheel = self.GhostWheels[i]
				if IsValid(Wheel) then
					local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
					prop:SetModel( Wheel:GetModel() )			
					prop:SetPos( Wheel:LocalToWorld( Vector(0,0,0) ) )
					prop:SetAngles( Wheel:LocalToWorldAngles( Angle(0,0,0) ) )
					prop:SetOwner( bprop )
					prop:Spawn()
					prop:Activate()
					prop:GetPhysicsObject():SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(0,25)) )
					prop:GetPhysicsObject():SetMass( 20 )
					prop.DoNotDuplicate = true
					bprop:DeleteOnRemove( prop )
					bprop.Wheels[i] = prop
					
					simfphys.SetOwner( ply , prop )
				end
			end
		end
	end

	self:Extinguish() 
	
	self:OnDestroyed()
	
	hook.Run( "simfphysOnDestroyed", self, self.Gib )
	
	self:Remove()
end

local dis = 40

function ENT:OnTakeDamage( dmginfo )
	if not self:IsInitialized() then return end

	if hook.Run( "simfphysOnTakeDamage", self, dmginfo ) then return end

	local Damage = dmginfo:GetDamage() 
	local DamagePos = dmginfo:GetDamagePosition() 
	local Type = dmginfo:GetDamageType()
	local Driver = self:GetDriver()

	self.LastAttacker = dmginfo:GetAttacker() 
	self.LastInflictor = dmginfo:GetInflictor()

	if simfphys.DamageEnabled then
		net.Start( "simfphys_spritedamage" )
			net.WriteEntity( self )
			net.WriteVector( self:WorldToLocal( DamagePos ) ) 
			net.WriteBool( false ) 
		net.Broadcast()

		local dist_ToEngine = (DamagePos - self:GetEnginePos()):Length()
		local CarDamage = Damage / 10
		if dist_ToEngine < 50 then
			CarDamage = CarDamage * 5
			--print(CarDamage, "X5")
		end

		local oldHP = self:GetCurHealth()

		self:ApplyDamage( CarDamage, Type )

		local newHP = self:GetCurHealth()


		if IsValid(Driver) then
			local Distance = (DamagePos - Driver:GetPos()):Length() 
			if (Distance < dis) then
				dmginfo:ScaleDamage( 1.5*( Distance / dis ) )
				Driver:TakeDamageInfo( dmginfo )
				
				--local effectdata = EffectData()
					--effectdata:SetOrigin( DamagePos )
				--util.Effect( "BloodImpact", effectdata, true, true )
			end
		end
		
		if self.PassengerSeats then
			for i = 1, table.Count( self.PassengerSeats ) do
				local Passenger = self.pSeat[i]:GetDriver()
				
				if IsValid(Passenger) then
					local Distance = (DamagePos - Passenger:GetPos()):Length()
					if (Distance < dis) then
						dmginfo:ScaleDamage( 1.5*( Distance / (dis/4) ) )
						Passenger:TakeDamageInfo( dmginfo )
						--local effectdata = EffectData()
						--	effectdata:SetOrigin( DamagePos )
						--util.Effect( "BloodImpact", effectdata, true, true )
					end
				end
			end
		end
	end
end

local function Spark( pos , normal , snd )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos - normal )
	effectdata:SetNormal( -normal )
	util.Effect( "stunstickimpact", effectdata, true, true )
	
	if snd then
		sound.Play( Sound( snd ), pos, 75)
	end
end

function ENT:PhysicsCollide( data, physobj )

	if hook.Run( "simfphysPhysicsCollide", self, data, physobj ) then return end

	if IsValid( data.HitEntity ) then
		if data.HitEntity:IsNPC() or data.HitEntity:IsNextBot() or data.HitEntity:IsPlayer() then
			Spark( data.HitPos , data.HitNormal , "MetalVehicle.ImpactSoft" )
			return
		end
	end
	
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then
		
		local pos = data.HitPos
		
		if (data.Speed > 1000) then
			Spark( pos , data.HitNormal , "MetalVehicle.ImpactHard" )
			
			self:HurtPlayers( (data.Speed / 7) * simfphys.DamageMul )
			
			self:TakeDamage( (data.Speed / 7) * simfphys.DamageMul, Entity(0), Entity(0) )
		else
			Spark( pos , data.HitNormal , "MetalVehicle.ImpactSoft" )
			
			if data.Speed > 250 then
				local hitent = data.HitEntity:IsPlayer()
				if not hitent then
					if simfphys.DamageMul > 1 then
						self:TakeDamage( (data.Speed / 28) * simfphys.DamageMul, Entity(0), Entity(0) )
					end
				end
			end
			
			if data.Speed > 500 then
				self:HurtPlayers( (data.Speed / 14) * simfphys.DamageMul )
				
				self:TakeDamage( (data.Speed / 14) * simfphys.DamageMul, Entity(0), Entity(0) )
			end
		end
	end
end
