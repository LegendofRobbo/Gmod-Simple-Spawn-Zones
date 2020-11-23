SafezonesConfig = {
	["ProtectionDelay"] = 3, -- how long will they remain spawn protected after leaving a safezone box
	["RemoveProps"] = true, -- do we want to delete props that enter the zones
	["RemovePysobjects"] = false, -- do we want to mass delete anything that has a physics object? warning: may cause bugs
	["RemoveVehicles"] = true, -- do we want to delete vehicles that enter the zones, be careful with this if you run an rp server with cars
	["RemoveNPCs"] = false, -- do we want to delete npcs that enter the spawn area
	["RecurringProtection"] = true, -- if you leave the spawn zone and re-enter it, should you be protected again?
	["TransparencyEffect"] = true, -- should spawn protected players be transparent?
	["InvisibleSpawnBoxes"] = false, -- should the spawn protection boxes be invisible?
	["BlockTracesToPlayer"] = false, -- stops traces from being able to hit the player, this will make them unable to be arrested, shot, cuffed, kidnapped etc
}

-- the actual boxes, needs to be 2 vectors seperated by a comma as you can see below
-- you can type safezone_grablocation into console to grab the vector location of what your crosshair is pointing at, then copy paste it into this file

Safezones = {

	["gm_construct"] = {
		["AyyLmao"] = {Vector( 1023, -895, 0 ), Vector( 656, 783, -144 )},
	},

	["gm_flatgrass"] = {
		["Box1"] = {Vector( -886, 864, -12288 ), Vector( 857, -861, -11982 )},
	},

	["gm_cfgrass_deathminge_v1"] = {
		["Box1"] = {Vector(11975, 4788, -410), Vector(11594, 6594, -200)},
		["Box2"] = {Vector(6452, 11320, -410), Vector(7684, 12696, -250)},
	},

	["gm_freespace_13"] = {
		["Box1"] = {Vector( -2658, 505, -14584 ), Vector( -3410, -503, -14270 )},
	},

	["rp_downtown_v4c"] = {
		["Fountain"] = {Vector( -2326, -1994, -196 ), Vector( -1492, -1152, -46 )},
	},

	["rp_downtown_v4c_v3"] = {
    	["Box1"] = {Vector(-1453, -1151, -194), Vector(-2347, -1985, 36)},
	},

}

-- ========== DO NOT TOUCH ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ==========


if CLIENT then

-- use this to easily grab locations for your spawn boxes
local function GrabLoc()
print("Vector( "..math.floor(LocalPlayer():GetEyeTrace().HitPos.x)..", "..math.floor(LocalPlayer():GetEyeTrace().HitPos.y)..", "..math.floor(LocalPlayer():GetEyeTrace().HitPos.z).." )")
end
concommand.Add("safezone_grablocation", GrabLoc)

-- this is a duplicate of the serverside load function that runs on each client so they can see the boxes
local MapSZs = {}

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
timer.Simple(1, function() LoadMapSetup() end)

local function DrawSpawnBoxes()
	if SafezonesConfig["InvisibleSpawnBoxes"] then return end
	render.SetMaterial( Material("effects/com_shield003a") )
	for k, v in pairs(MapSZs) do
		render.DrawBox( v[2], Angle(0,0,0), Vector(0,0,0), v[1] - v[2], Color(255,0,0, 100), true )
	end
end
hook.Add("PostDrawOpaqueRenderables", "ssz_ICanSeeYourDoodle", DrawSpawnBoxes)

local function SZHudIndicator()
if LocalPlayer():GetNWBool("SpawnProtected") then
	draw.RoundedBox( 2, ScrW() / 2 - 170, 20, 340, 60, Color( 0, 0, 0, 200 ) )
	surface.SetDrawColor(155, 155, 155 ,155)
	surface.DrawOutlinedRect(ScrW() / 2 - 170, 20, 340, 60)
	draw.SimpleText( "You are spawn protected", "TargetID", ScrW() / 2 - 100, 40, Color( 255, 255, 255, 255 ), 0, 1 )
	draw.SimpleText( "You cannot hurt other players or be hurt by them", "TargetIDSmall", ScrW() / 2 - 160, 60, Color( 255, 255, 255, 255 ), 0, 1 )
end
end
hook.Add("HUDPaint", "szhudindicator", SZHudIndicator)

end


