local MapSZs = {}
/*
local function CantTouchDis(victim, attacker)
	local dmg = true
	if victim:GetNWBool("SpawnProtected") or attacker:GetNWBool("SpawnProtected") then dmg = false end
	return dmg
end
hook.Add( "PlayerShouldTakeDamage", "CantTouchDis", CantTouchDis)
*/

local function CantTouchDis2( ent, dmg )
	if !ent:IsValid() or !ent:IsPlayer() then return end
	local attacker = dmg:GetAttacker()
	if ent:GetNWBool("SpawnProtected") then return true end
	if attacker:IsValid() and attacker:IsPlayer() and attacker:GetNWBool("SpawnProtected") then return true end
end
hook.Add( "EntityTakeDamage", "CantTouchDis2", CantTouchDis2 )

local function nojailforme( cop, victim )
	if victim:GetNWBool("SpawnProtected") then return false, "You cannot arrest people in spawn!" end
end
hook.Add( "canArrest", "ssz_getoutofjailfree", nojailforme )

local loadedmap = false
local function LoadMapSetup()
	local thismap = game.GetMap()
	for k, v in pairs(Safezones) do
		if k == thismap then
			MapSZs = v
			loadedmap = true
		end
	end

	if !loadedmap then 
		MsgC(Color(255,50,0), "Simple Safezones: no config detected for this map! check addons/Simple Spawn Zones/sh_safezones.lua for more info\n")
	end

end
timer.Simple(1.5, function() LoadMapSetup() end)


local function ClearProtection( ply )
	ply.PreviouslyProtected = false
end
hook.Add("PlayerSpawn", "ClearProtection", ClearProtection)


local function BoxCheck()

for k, v in pairs(MapSZs) do
	local checkmydubs = ents.FindInBox(v[1], v[2])

	for k, v in pairs(checkmydubs) do
	if v:IsPlayer() and v:IsValid() then
		if not SafezonesConfig["RecurringProtection"] and v.PreviouslyProtected then return end
		v:SetNWBool("SpawnProtected", true )
		if SafezonesConfig["BlockTracesToPlayer"] then v:SetNotSolid( true ) end
		if SafezonesConfig["TransparencyEffect"] then
			local c = v:GetColor()
			v:SetRenderMode(RENDERMODE_TRANSALPHA)
			v:SetColor(Color(c.r, c.g, c.b, 100))
		end

		timer.Create("spawnprot_"..v:UniqueID(), SafezonesConfig["ProtectionDelay"], 1, function()
			if !v:IsValid() then return false end
			v:SendLua([[if Legs then Legs:SetUp() end]]) -- this is a really dodgy solution but i can't really think of a better way because this timer doesnt exist on the client
			v:SetNWBool("SpawnProtected", false)
			if SafezonesConfig["BlockTracesToPlayer"] then v:SetNotSolid( false ) end
			if !SafezonesConfig["RecurringProtection"] then v.PreviouslyProtected = true end
			if SafezonesConfig["TransparencyEffect"] then
				local c = v:GetColor()
				v:SetRenderMode(RENDERMODE_NORMAL)
				v:SetColor(Color(c.r, c.g, c.b, 100))
			end
		end)
	end

	if SafezonesConfig["RemoveProps"] and ((v:GetClass() == "prop_physics" and !v.jailWall) or string.find(v:GetClass(), "wire")) then
		v:Remove()
	end

	if SafezonesConfig["RemoveVehicles"] and v:IsVehicle() then
		v:Remove()
	end

	if SafezonesConfig["RemoveNPCs"] and (v:IsNPC() or v.Type == "nextbot") then
		v:Remove()
	end

	if SafezonesConfig["RemovePysobjects"] and v:GetPhysicsObject():IsValid() and !v:IsPlayer() and !v.jailWall then
		v:Remove()
	end

	end

end
end
--hook.Add("Think", "Checkdemboxes", BoxCheck) -- dont need to run this on a think hook, thats just wasteful
timer.Create("BoxCheck", 0.1, 0, BoxCheck)