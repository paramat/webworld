-- webworld 0.2.3 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- License: code WTFPL

-- cosine realm proportion
-- add jungletrees
-- tune strata
-- new structure, floatlands emerge from terrain

-- Parameters

local YMAX = 33000
local YSANDAV = 4 -- Sandline average y
local YWATER = 1
local YZERO = -64 -- Noise gradient zero point
local YMIN = -33000

local TERSCA = 256 -- Vertical terrain scale
local BASAMP = 0.7 -- Base amplitude relative to 3D noise amplitude. Ridge network structure
local MIDAMP = 0.1 -- Mid amplitude relative to 3D noise amplitude. River valley structure
local FLOATOFF = 0 -- Floatland density noise offset
local FANG = 10 -- Cosine realm blend angle factor

local SANDAMP = 3 -- Sandline amplitude
local TRIVER = -0.03 -- River depth
local TRSAND = -0.033 -- Depth of river sand
local STABLE = 5 -- minimum stone nodes in column for dirt/sand above
local TSTONE = 0.01 -- Stone density threshold. Maximum depth of dirt/sand in normal realm
local TTUN = 0.02 -- Tunnel width
local ORETHI = 0.005 -- Ore seam minimum thickness (diamond, mese, gold)

local JUNCHA = 1 / 4 ^ 2 -- Jungletree chance per surface node
local APPCHA = 1 / 5 ^ 2 -- Appletree maximum chance per surface node
local CACCHA = 1 / 48 ^ 2 -- Cactus ^
local PINCHA = 1 / 6 ^ 2 -- Pinetree ^

-- 2D noise for realm

local np_realm = {
	offset = 0,
	scale = 1,
	spread = {x=1096, y=1096, z=1096},
	seed = 98320,
	octaves = 3,
	persist = 0.4
}

-- 2D noise for mid terrain / river

local np_mid = {
	offset = 0,
	scale = 1,
	spread = {x=768, y=768, z=768},
	seed = 85546,
	octaves = 5,
	persist = 0.4
}

-- 2D noise for base terrain / humidity

local np_base = {
	offset = 0,
	scale = 1,
	spread = {x=1536, y=1536, z=1536},
	seed = -990054,
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
	persist = 0.67
}

-- 3D noise for alt terrain in golden ratio

local np_terralt = {
	offset = 0,
	scale = 1,
	spread = {x=311, y=155, z=311},
	seed = 593,
	octaves = 5,
	persist = 0.67
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

-- 3D noise for biome

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

-- 3D noise for strata layering

local np_strata = {
	offset = 0,
	scale = 1,
	spread = {x=3072, y=48, z=3072},
	seed = 92219,
	octaves = 4,
	persist = 1
}

-- Stuff

dofile(minetest.get_modpath("webworld").."/functions.lua")
dofile(minetest.get_modpath("webworld").."/nodes.lua")

minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode", water_level=YWATER-256})
end)

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
	local c_freshwater = minetest.get_content_id("webworld:freshwater")
	
	local c_ignore = minetest.get_content_id("ignore")
	local c_desand = minetest.get_content_id("default:desert_sand")
	local c_sand = minetest.get_content_id("default:sand")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	local c_dirtsnow = minetest.get_content_id("default:dirt_with_snow")
	local c_ice = minetest.get_content_id("default:ice")
	local c_sandstone = minetest.get_content_id("default:sandstone")
	local c_gravel = minetest.get_content_id("default:gravel")
	local c_jungrass = minetest.get_content_id("default:junglegrass")
	local c_stodiam = minetest.get_content_id("default:stone_with_diamond")
	local c_stomese = minetest.get_content_id("default:stone_with_mese")
	local c_stogold = minetest.get_content_id("default:stone_with_gold")
	local c_stocopp = minetest.get_content_id("default:stone_with_copper")
	local c_stoiron = minetest.get_content_id("default:stone_with_iron")
	local c_stocoal = minetest.get_content_id("default:stone_with_coal")
	local c_watersour = minetest.get_content_id("default:water_source")
	
	local sidelen = x1 - x0 + 1
	local chulensxyz = {x=sidelen, y=sidelen+16, z=sidelen}
	local minposxyz = {x=x0, y=y0-15, z=z0}
	local chulensxz = {x=sidelen, y=sidelen, z=sidelen} -- different because here x=x, y=z
	local minposxz = {x=x0, y=z0}
	
	local nvals_realm = minetest.get_perlin_map(np_realm, chulensxz):get2dMap_flat(minposxz)

	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_terralt = minetest.get_perlin_map(np_terralt, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_weba = minetest.get_perlin_map(np_weba, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_webb = minetest.get_perlin_map(np_webb, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_biome = minetest.get_perlin_map(np_biome, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_forest = minetest.get_perlin_map(np_forest, chulensxyz):get3dMap_flat(minposxyz)
	local nvals_strata = minetest.get_perlin_map(np_strata, chulensxyz):get3dMap_flat(minposxyz)

	local nvals_mid = minetest.get_perlin_map(np_mid, chulensxz):get2dMap_flat(minposxz)
	local nvals_base = minetest.get_perlin_map(np_base, chulensxz):get2dMap_flat(minposxz)

	local nixyz = 1
	local nixz = 1
	local stable = {}
	local under = {}
	for z = z0, z1 do
		for x = x0, x1 do
			local si = x - x0 + 1
			stable[si] = 0
			under[si] = 0
		end
		for y = y0 - 15, y1 + 1 do
			local vi = area:index(x0, y, z)
			local viu = area:index(x0, y-1, z)
			for x = x0, x1 do
				local si = x - x0 + 1
				
				local n_realm = math.abs(nvals_realm[nixz])
				local rprop = 0.5 *
					(1 - math.cos(math.min(n_realm * FANG, math.pi)))
				local n_mid = math.abs(nvals_mid[nixz]) ^ 0.8
				local n_base = math.abs(nvals_base[nixz])
				local n_invbase = 1 - n_base
				local n_liminvbase = math.max(1 - n_base, 0)
				local n_terrain = nvals_terrain[nixyz]
				local n_terralt = nvals_terralt[nixyz]
				local n_floatmix = (n_terrain + n_terralt) * 0.5 + FLOATOFF
				local n_mountmix = (n_terrain + n_terralt) * 0.5 + 2
				local grad = (YZERO - y) / TERSCA
				local densitybase = n_invbase * BASAMP + grad
				local densitymid = n_mid * MIDAMP * n_base + densitybase
				-- rprop = 1 normal world, rprop = 0 floatlands
				local normdensity = n_mountmix * n_liminvbase * n_mid + densitymid
				local floatdensity = math.max(n_floatmix, normdensity)
				local density = normdensity * rprop + floatdensity * (1 - rprop)
				
				local n_biome = nvals_biome[nixyz]
				local biome = false
				if n_biome > 0.5 then
					biome = 4 -- desert
				elseif n_biome > 0 then
					biome = 3 -- rainforest
				elseif n_biome < -0.5 then
					biome = 1 -- taiga
				else
					biome = 2 -- forest / grassland
				end
				
				local n_weba = nvals_weba[nixyz]
				local n_webb = nvals_webb[nixyz]
				local weba = math.abs(n_weba) < TTUN
				local webb = math.abs(n_webb) < TTUN
				local novoid = not (weba and webb)

				local tstone = math.max(TSTONE * (1 + grad), 0) * rprop + 
					TSTONE / 2 * (1 - rprop)
				
				local n_forest = math.min(math.max(nvals_forest[nixyz], 0), 1)
				local triver = TRIVER * n_base
				local trsand = TRSAND * n_base
				local n_strata = math.abs(nvals_strata[nixyz])
	
				if y < y0 then -- calculate mapchunk below, count stone
					if density >= tstone then
						stable[si] = stable[si] + 1
					elseif density < 0 then
						stable[si] = 0
					end
				elseif y >= y0 and y <= y1 then
					if novoid and density >= tstone then -- stones and ores
						if n_strata < 0.1 then -- sandstone strata
							data[vi] = c_sandstone
						elseif n_strata > 1.4
						and n_strata < 1.4 + ORETHI then
							data[vi] = c_stodiam
						elseif n_strata > 1.2
						and n_strata < 1.2 + ORETHI then
							data[vi] = c_stomese
						elseif n_strata > 1
						and n_strata < 1 + ORETHI then
							data[vi] = c_stogold
						elseif n_strata > 0.8
						and n_strata < 0.8 + ORETHI * 2 then
							data[vi] = c_stocopp
						elseif n_strata > 0.6
						and n_strata < 0.6 + ORETHI * 3 then
							data[vi] = c_stoiron
						elseif n_strata > 0.4
						and n_strata < 0.4 + ORETHI * 4 then
							data[vi] = c_stocoal
						elseif biome == 4 then
							data[vi] = c_destone -- desert stone
						else
							data[vi] = c_stone
						end
						stable[si] = stable[si] + 1
						under[si] = 6
					elseif density >= 0 and density < tstone -- fine materials
					and stable[si] >= STABLE then
						if y <= YSANDAV + n_weba * SANDAMP -- sand
						or densitybase >= trsand then
							data[vi] = c_sand
							under[si] = 5
						elseif biome == 1 then
							data[vi] = c_dirt
							under[si] = 1
						elseif biome == 2 then
							data[vi] = c_dirt
							under[si] = 2
						elseif biome == 3 then
							data[vi] = c_dirt
							under[si] = 3
						elseif biome == 4 then
							data[vi] = c_desand
							under[si] = 4
						end
					elseif y <= YWATER and density < tstone then -- sea water and ice
						if n_biome < -0.8 then
							data[vi] = c_ice
						else
							data[vi] = c_watersour
						end
						stable[si] = 0
						under[si] = 0
					elseif densitybase >= triver and density < tstone then-- river water
						data[vi] = c_freshwater
						stable[si] = 0
						under[si] = 0
					elseif density < 0 and y > YWATER -- surface materials
					and under[si] ~= 0 then
						if under[si] == 1 then
							if math.random() < PINCHA * n_forest then
								webworld_snowypine(x, y, z, area, data)
							else
								data[viu] = c_dirtsnow
								data[vi] = c_snowblock
							end
						elseif under[si] == 2 then
							if math.random() < APPCHA * n_forest
									and y <= 47 then
								webworld_appletree(x, y, z, area, data)
							elseif math.random() < PINCHA * n_forest
									and y <= 127 and y >= 48 then
								webworld_pinetree(x, y, z, area, data)
							else
								data[viu] = c_grass
							end
						elseif under[si] == 3 then
							if math.random() < JUNCHA and y <= 47 then
								webworld_jungletree(x, y, z, area, data, y1)
							else
								data[viu] = c_grass
							end
						elseif under[si] == 4 then
							if math.random() < CACCHA * n_forest then
								webworld_cactus(x, y, z, area, data)
							end
						elseif under[si] == 5 then
							if biome == 1 then
								data[vi] = c_snowblock
							end
						elseif under[si] == 6 and biome == 1 and grad < 1 then
							data[vi] = c_snowblock
						end
						stable[si] = 0
						under[si] = 0
					else -- air
						stable[si] = 0
						under[si] = 0
					end
				elseif y == y1 + 1 then -- overgeneration
					if density < 0 and y > YWATER -- surface materials
					and under[si] ~= 0 then
						if under[si] == 1 then
							if math.random() < PINCHA * n_forest then
								webworld_snowypine(x, y, z, area, data)
							else
								data[viu] = c_dirtsnow
								data[vi] = c_snowblock
							end
						elseif under[si] == 2 then
							if math.random() < APPCHA * n_forest
									and y <= 47 then
								webworld_appletree(x, y, z, area, data)
							elseif math.random() < PINCHA * n_forest
									and y <= 127 and y >= 48 then
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
					end
				end
				nixyz = nixyz + 1
				nixz = nixz + 1
				vi = vi + 1
				viu = viu + 1
			end
			nixz = nixz - sidelen
		end
		nixz = nixz + sidelen
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	vm:update_liquids()

	local chugent = math.ceil((os.clock() - t0) * 1000)
	print ("[webworld] "..chugent.." ms")
end)
