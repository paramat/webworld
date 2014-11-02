function webworld_appletree(x, y, z, area, data)
	local c_tree = minetest.get_content_id("default:tree")
	local c_apple = minetest.get_content_id("default:apple")
	local c_appleaf = minetest.get_content_id("webworld:appleleaf")
	for j = -2, 4 do
		if j == 3 or j == 4 then
			for i = -2, 2 do
			for k = -2, 2 do
				local vi = area:index(x + i, y + j, z + k)
				if math.random(64) == 2 then
					data[vi] = c_apple
				elseif math.random(5) ~= 2 then
					data[vi] = c_appleaf
				end
			end
			end
		elseif j == 2 then
			for i = -1, 1 do
			for k = -1, 1 do
				if math.abs(i) + math.abs(k) == 2 then
					local vi = area:index(x + i, y + j, z + k)
					data[vi] = c_tree
				end
			end
			end
		else
			local vi = area:index(x, y + j, z)
			data[vi] = c_tree
		end
	end
end

function webworld_cactus(x, y, z, area, data)
	local c_cactus = minetest.get_content_id("webworld:cactus")
	for j = -2, 4 do
	for i = -2, 2 do
		if i == 0 or j == 2 or (j == 3 and math.abs(i) == 2) then
			local vi = area:index(x + i, y + j, z)
			data[vi] = c_cactus
		end
	end
	end
end

function webworld_pinetree(x, y, z, area, data)
	local c_pinetree = minetest.get_content_id("webworld:pinetree")
	local c_needles = minetest.get_content_id("webworld:needles")
	for j = -4, 14 do
		if j == 3 or j == 6 or j == 9 or j == 12 then
			for k = -2, 2 do
				local vi = area:index(x - 2, y + j, z + k)
				for i = -2, 2 do
					if math.abs(i) == 1 and math.abs(k) == 1 then
						data[vi] = c_pinetree
					elseif math.abs(i) + math.abs(k) == 2
					or math.abs(i) + math.abs(k) == 3 then
						data[vi] = c_needles
					end
					vi = vi + 1
				end
			end
		elseif j == 4 or j == 7 or j == 10 or j == 13 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				for i = -1, 1 do
					if not (i == 0 and j == 0) then
						data[vi] = c_needles
					end
					vi = vi + 1
				end
			end
		elseif j == 14 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				for i = -1, 1 do
					if math.abs(i) + math.abs(k) == 1 then
						data[vi] = c_needles
					end
					vi = vi + 1
				end
			end
		end
		local vi = area:index(x, y + j, z)
		data[vi] = c_pinetree
	end
	local vi = area:index(x, y + 15, z)
	local via = area:index(x, y + 16, z)
	data[vi] = c_needles
	data[via] = c_needles
end

function webworld_snowypine(x, y, z, area, data)
	local c_pinetree = minetest.get_content_id("webworld:pinetree")
	local c_needles = minetest.get_content_id("webworld:needles")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	for j = -4, 14 do
		if j == 3 or j == 6 or j == 9 or j == 12 then
			for k = -2, 2 do
				local vi = area:index(x - 2, y + j, z + k)
				local via = area:index(x - 2, y + j + 1, z + k)
				for i = -2, 2 do
					if math.abs(i) == 1 and math.abs(k) == 1 then
						data[vi] = c_pinetree
					elseif math.abs(i) + math.abs(k) == 2
					or math.abs(i) + math.abs(k) == 3 then
						data[vi] = c_needles
						data[via] = c_snowblock
					end
					vi = vi + 1
					via = via + 1
				end
			end
		elseif j == 4 or j == 7 or j == 10 or j == 13 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				local via = area:index(x - 1, y + j + 1, z + k)
				for i = -1, 1 do
					if not (i == 0 and j == 0) then
						data[vi] = c_needles
						data[via] = c_snowblock
					end
					vi = vi + 1
					via = via + 1
				end
			end
		elseif j == 14 then
			for k = -1, 1 do
				local vi = area:index(x - 1, y + j, z + k)
				local via = area:index(x - 1, y + j + 1, z + k)
				for i = -1, 1 do
					if math.abs(i) + math.abs(k) == 1 then
						data[vi] = c_needles
						data[via] = c_snowblock
					end
					vi = vi + 1
					via = via + 1
				end
			end
		end
		local vi = area:index(x, y + j, z)
		data[vi] = c_pinetree
	end
	local vi = area:index(x, y + 15, z)
	local via = area:index(x, y + 16, z)
	local viaa = area:index(x, y + 17, z)
	data[vi] = c_needles
	data[via] = c_needles
	data[viaa] = c_snowblock
end

-- ABM

-- Appletree sapling

minetest.register_abm({
	nodenames = {"webworld:appling"},
	interval = 31,
	chance = 5,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x-2, y=y-2, z=z-2}
		local pos2 = {x=x+2, y=y+5, z=z+2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		webworld_appletree(x, y, z, area, data)

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

-- Pinetree sapling

minetest.register_abm({
	nodenames = {"webworld:pineling"},
	interval = 29,
	chance = 5,
	action = function(pos, node)
		local x = pos.x
		local y = pos.y
		local z = pos.z
		local vm = minetest.get_voxel_manip()
		local pos1 = {x=x-2, y=y-4, z=z-2}
		local pos2 = {x=x+2, y=y+17, z=z+2}
		local emin, emax = vm:read_from_map(pos1, pos2)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()

		webworld_snowypine(x, y, z, area, data)

		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end,
})

