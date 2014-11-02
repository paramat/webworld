-- webworld 0.1.2 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- License: code WTFPL

-- terrainalt noise to 5 octaves
-- snow on stone and beach
-- vary sandline
-- seaice in very cold areas
-- stable = 4 for more stone exposure
-- pines above y = 47 in forest

-- Parameters

local YMIN = -33000
local YMAX = 33000
local YWATER = 1
local YSANDAV = 4
local SANDAMP = 3
local TERSCA = 192
local STABLE = 4 -- minimum stone nodes in column for dirt/sand above
local TSTONEMIN = 0.015 -- Stone density threshold minimum in floatlands
local TSTONEMAX = 0.04 -- Stone density threshold at water level
local TTUN = 0.02 -- Tunnel width
local ORECHA = 1 / 5 ^ 3 -- Ore chance per stone node

local APPCHA = 1 / 5 ^ 2 -- Appletree maximum chance per surface node
local CACCHA = 1 / 48 ^ 2 -- Cactus ^
local PINCHA = 1 / 6 ^ 2 -- Pinetree ^

-- 3D noise for realm

local np_realm = {
	offset = 0,
	scale = 1,
	spread = {x=8192, y=8192, z=8192},
	seed = 98320,
	octaves = 3,
	persist = 0.4
}

-- 3D noise for terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x=384, y=192, z=384},
	seed = 593,
	octaves = 5,
	persist = 0.63
}

-- 3D noise for alt terrain in golden ratio

local np_terralt = {
	offset = 0,
	scale = 1,
	spread = {x=621, y=311, z=621},
	seed = 593,
	octaves = 5,
	persist = 0.63
}

-- 3D noises for tunnels

local np_weba = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=192, z=192},
	seed = 5900033,
	octaves = 3,
	persist = 0.4
}

local np_webb = {
	offset = 0,
	scale = 1,
	spread = {x=191, y=191, z=191},
	seed = 33,
	octaves = 3,
	persist = 0.4
}

-- 3D noise for temperature

local np_biome = {
	offset = 0,
	scale = 1,
	spread = {x=1536, y=1536, z=1536},
	seed = -188900,
	octaves = 3,
	persist = 0.4
}

-- 3D noise for forest

local np_forest = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=96, z=192},
	seed = -100,
	octaves = 3,
	persist = 0.7
}

-- Stuff

dofile(minetest.get_modpath("webworld").."/functions.lua")
dofile(minetest.get_modpath("webworld").."/nodes.lua")

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y < YMIN or maxp.y > YMAX then
		return
	end

	local t0 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	print ("[webworld] chunk minp ("..x0.." "..y0.." "..z0..")")
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	local c_stone = minetest.get_content_id("webworld:stone")
	local c_destone = minetest.get_content_id("webworld:desertstone")
	local c_dirt = minetest.get_content_id("webworld:dirt")
	local c_grass = minetest.get_content_id("webworld:grass")
	
	local c_ignore = minetest.get_content_id("ignore")
	local c_desand = minetest.get_content_id("default:desert_sand")
	local c_sand = minetest.get_content_id("default:sand")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	local c_dirtsnow = minetest.get_content_id("default:dirt_with_snow")
	local c_ice = minetest.get_content_id("default:ice")
	local c_stodiam = minetest.get_content_id("default:stone_with_diamond")
	local c_stomese = minetest.get_content_id("default:stone_with_mese")
	local c_stogold = minetest.get_content_id("default:stone_with_gold")
	local c_stocopp = minetest.get_content_id("default:stone_with_copper")
	local c_stoiron = minetest.get_content_id("default:stone_with_iron")
	local c_stocoal = minetest.get_content_id("default:stone_with_coal")
	local c_watersour = minetest.get_content_id("default:water_source")
	
	local sidelen = x1 - x0 + 1
	local chulens = {x=sidelen, y=sidelen+16, z=sidelen}
	local minposxyz = {x=x0, y=y0-15, z=z0}
	
	local nvals_realm = minetest.get_perlin_map(np_realm, chulens):get3dMap_flat(minposxyz)
	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulens):get3dMap_flat(minposxyz)
	local nvals_terralt = minetest.get_perlin_map(np_terralt, chulens):get3dMap_flat(minposxyz)
	local nvals_weba = minetest.get_perlin_map(np_weba, chulens):get3dMap_flat(minposxyz)
	local nvals_webb = minetest.get_perlin_map(np_webb, chulens):get3dMap_flat(minposxyz)
	local nvals_biome = minetest.get_perlin_map(np_biome, chulens):get3dMap_flat(minposxyz)
	local nvals_forest = minetest.get_perlin_map(np_forest, chulens):get3dMap_flat(minposxyz)

	local nixyz = 1
	local stable = {}
	local under = {}
	for z = z0, z1 do
		for x = x0, x1 do
			local si = x - x0 + 1
			stable[si] = 0
		end
		for y = y0 - 15, y1 + 1 do
			local vi = area:index(x0, y, z)
			local viu = area:index(x0, y-1, z)
			for x = x0, x1 do
				local si = x - x0 + 1
				
				local n_realm = nvals_realm[nixyz]
				local n_terrain = nvals_terrain[nixyz]
				local n_terralt = nvals_terralt[nixyz]
				local grad = (YWATER - y) / TERSCA
				local rprop =
				(math.min(math.max(math.abs(n_realm), 0.04), 0.08) - 0.04) / 0.04
				local density = (n_terrain + n_terralt) * 0.5 + grad * rprop
				-- rprop = 1 normal world. rprop = 0 webworld
				
				local n_biome = nvals_biome[nixyz]
				local biome = false
				if n_biome > 0.4 then
					biome = 3 -- desert
				elseif n_biome < -0.4 then
					biome = 1 -- taiga
				else
					biome = 2 -- forest / grassland
				end
				
				local n_weba = nvals_weba[nixyz]
				local n_webb = nvals_webb[nixyz]
				local weba = math.abs(n_weba) < TTUN
				local webb = math.abs(n_webb) < TTUN
				local novoid = not (weba and webb)
	
				local tstone
				if y >= YWATER or rprop > 0.9 then
					tstone = math.max(TSTONEMAX * (1 + grad), TSTONEMIN)
				else -- thin to nothing in underworld
					tstone = math.max(TSTONEMAX * (1 - grad), 0)
				end
				
				local n_forest = math.min(math.max(nvals_forest[nixyz], 0), 1)
	
				if y < y0 then
					under[si] = 0
					if density >= tstone then
						stable[si] = stable[si] + 1
					elseif density < 0 then
						stable[si] = 0
					end
					if y == y0 - 1 then
						local nodid = data[vi]
						if nodid == c_stone
						or nodid == c_destone
						or nodid == c_dirt
						or nodid == c_grass
						or nodid == c_dirtsnow
						or nodid == c_snowblock
						or nodid == c_desand
						or nodid == c_stodiam
						or nodid == c_stomese
						or nodid == c_stogold
						or nodid == c_stocopp
						or nodid == c_stoiron
						or nodid == c_stocoal then
							stable[si] = STABLE
						end
					end
				elseif y >= y0 and y <= y1 then
					if novoid
					and (density >= tstone or (rprop > 0.6 and rprop < 1
					and y > YWATER - TERSCA * 2 and y <= YWATER)) then
						if biome == 3 and density < TSTONEMAX * 8 then
							data[vi] = c_destone
						elseif math.random() < ORECHA then
							local osel = math.random(24)
							if osel == 24 then
								data[vi] = c_stodiam
							elseif osel == 23 then
								data[vi] = c_stomese
							elseif osel == 22 then
								data[vi] = c_stogold
							elseif osel >= 19 then
								data[vi] = c_stocopp
							elseif osel >= 10 then
								data[vi] = c_stoiron
							else
								data[vi] = c_stocoal
							end
						else
							data[vi] = c_stone
						end
						stable[si] = stable[si] + 1
						under[si] = 5
					elseif density >= 0 and density < tstone
					and stable[si] >= STABLE then
						if y <= YSANDAV + n_weba * SANDAMP
						and rprop > 0.8 then
							data[vi] = c_sand
							under[si] = 4
						elseif biome == 1 then
							data[vi] = c_dirt
							under[si] = 1
						elseif biome == 2 then
							data[vi] = c_dirt
							under[si] = 2
						elseif biome == 3 then
							data[vi] = c_desand
							under[si] = 3
						end
					elseif density < 0 and (y > YWATER or rprop < 1)
					and under[si] ~= 0 then
						if under[si] == 1 then
							if math.random() < PINCHA * n_forest then
								webworld_snowypine(x, y, z, area, data)
							else
								data[viu] = c_dirtsnow
								data[vi] = c_snowblock
							end
						elseif under[si] == 2 then
							if y <= 47 and math.random() < APPCHA * n_forest then
								webworld_appletree(x, y, z, area, data)
							elseif y <= 127 and y >= 48 and
							math.random() < PINCHA * n_forest then
								webworld_pinetree(x, y, z, area, data)
							else
								data[viu] = c_grass
							end
						elseif under[si] == 3 then
							if math.random() < CACCHA * n_forest then
								webworld_cactus(x, y, z, area, data)
							end
						elseif under[si] == 4 then
							if biome == 1 then
								data[vi] = c_snowblock
							end
						elseif under[si] == 5 and biome == 1 and grad < 1 then
							data[vi] = c_snowblock
						end
						stable[si] = 0
						under[si] = 0
					elseif rprop > 0.99 and y <= YWATER
					and density < tstone then
						if n_biome < -0.8 then
							data[vi] = c_ice
						else
							data[vi] = c_watersour
						end
						stable[si] = 0
						under[si] = 0
					else
						stable[si] = 0
						under[si] = 0
					end
				elseif y == y1 + 1 then
					if density < 0 and under[si] ~= 0 then
						if under[si] == 1 then
							if math.random() < PINCHA * n_forest then
								webworld_snowypine(x, y, z, area, data)
							else
								data[viu] = c_dirtsnow
								data[vi] = c_snowblock
							end
						elseif under[si] == 2 then
							if math.random() < APPCHA * n_forest then
								webworld_appletree(x, y, z, area, data)
							else
								data[viu] = c_grass
							end
						elseif under[si] == 3 then
							if math.random() < CACCHA * n_forest then
								webworld_cactus(x, y, z, area, data)
							end
						end
					end
				end
				nixyz = nixyz + 1
				vi = vi + 1
				viu = viu + 1
			end
		end
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	vm:update_liquids()

	local chugent = math.ceil((os.clock() - t0) * 1000)
	print ("[webworld] "..chugent.." ms")
end)
