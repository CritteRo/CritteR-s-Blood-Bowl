---------------------------------------------------------------------------------------
--			Arena Interior Resource by Titch2000
---------------------------------------------------------------------------------------

local map = 2
local scene = "dystopian"

local maps = {
	["dystopian"] = {
		"Set_Dystopian_01",
		"Set_Dystopian_02",
		"Set_Dystopian_03",
		"Set_Dystopian_04",
		"Set_Dystopian_05",
		"Set_Dystopian_06",
		"Set_Dystopian_07",
		"Set_Dystopian_08",
		"Set_Dystopian_09",
		"Set_Dystopian_10",
		"Set_Dystopian_11",
		"Set_Dystopian_12",
		"Set_Dystopian_13",
		"Set_Dystopian_14",
		"Set_Dystopian_15",
		"Set_Dystopian_16",
		"Set_Dystopian_17"
	},

	["scifi"] = {
		"Set_Scifi_01",
		"Set_Scifi_02",
		"Set_Scifi_03",
		"Set_Scifi_04",
		"Set_Scifi_05",
		"Set_Scifi_06",
		"Set_Scifi_07",
		"Set_Scifi_08",
		"Set_Scifi_09",
		"Set_Scifi_10"
	},

	["wasteland"] = {
		"Set_Wasteland_01",
		"Set_Wasteland_02",
		"Set_Wasteland_03",
		"Set_Wasteland_04",
		"Set_Wasteland_05",
		"Set_Wasteland_06",
		"Set_Wasteland_07",
		"Set_Wasteland_08",
		"Set_Wasteland_09",
		"Set_Wasteland_10"
	}
}

Citizen.CreateThread(function()
	-- New Arena : 2800.00, -3800.00, 100.00
	RequestIpl("xs_arena_interior")

	-- The below are additional interiors / maps relating to this DLC play around with them at your own risk and want.
	--RequestIpl("xs_arena_interior_mod")
	--RequestIpl("xs_arena_interior_mod_2")
	RequestIpl("xs_arena_interior_vip") -- This is the interior bar for VIP's
	--RequestIpl("xs_int_placement_xs")
    --RequestIpl("xs_arena_banners_ipl")
	--RequestIpl("xs_mpchristmasbanners")
    --RequestIpl("xs_mpchristmasbanners_strm_0")

	-- Lets get and save our interior ID for use later
	local interiorID = GetInteriorAtCoords(2800.000, -3800.000, 100.000)

	-- now lets check the interior is ready if not lets just wait a moment
	if (not IsInteriorReady(interiorID)) then
		Wait(1)
	end
	-- We need to add the crowds as who does stuff on their own for nobody?
	EnableInteriorProp(interiorID, "Set_Crowd_A")
	EnableInteriorProp(interiorID, "Set_Crowd_B")
	EnableInteriorProp(interiorID, "Set_Crowd_C")
	EnableInteriorProp(interiorID, "Set_Crowd_D")

	-- now lets set our map type and scene.
	if (scene == "dystopian") then
		EnableInteriorProp(interiorID, "Set_Dystopian_Scene")
		EnableInteriorProp(interiorID, maps[scene][map])
	end
	if (scene == "scifi") then
		EnableInteriorProp(interiorID, "Set_Scifi_Scene")
		EnableInteriorProp(interiorID, maps[scene][map])
	end
	if (scene == "wasteland") then
		EnableInteriorProp(interiorID, "Set_Wasteland_Scene")
		EnableInteriorProp(interiorID, maps[scene][map])
	end
end)
