minetest.register_node("webworld:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	groups = {cracky=3},
	drop = "default:cobble",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("webworld:desertstone", {
	description = "Desert Stone",
	tiles = {"default_desert_stone.png"},
	is_ground_content = false,
	groups = {cracky=3},
	drop = "default:desert_stone",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("webworld:dirt", {
	description = "Dirt",
	tiles = {"default_dirt.png"},
	is_ground_content = false,
	groups = {crumbly=3,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "webworld:dirt",
		dry = "webworld:soil",
		wet = "webworld:soil_wet"
	}
})

minetest.register_node("webworld:grass", {
	description = "Grass",
	tiles = {"default_grass.png", "default_dirt.png", "default_grass.png"},
	is_ground_content = false,
	groups = {crumbly=3,soil=1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
	soil = {
		base = "webworld:grass",
		dry = "webworld:soil",
		wet = "webworld:soil_wet"
	}
})

minetest.register_node("webworld:appleleaf", {
	description = "Appletree Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"webworld:appling"},rarity = 20},
			{items = {"webworld:appleleaf"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("webworld:appling", {
	description = "Appletree Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("webworld:cactus", {
	description = "Cactus",
	tiles = {"default_cactus_top.png", "default_cactus_top.png", "default_cactus_side.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {snappy=1, choppy=3, flammable=2},
	drop = "default:cactus",
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("webworld:pinetree", {
	description = "Pine tree",
	tiles = {"webworld_pinetreetop.png", "webworld_pinetreetop.png", "webworld_pinetree.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

minetest.register_node("webworld:needles", {
	description = "Pine needles",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"webworld_needles.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=3},
	drop = {
		max_items = 1,
		items = {
			{items = {"webworld:pineling"}, rarity = 20},
			{items = {"webworld:needles"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("webworld:pineling", {
	description = "Pine sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"webworld_pineling.png"},
	inventory_image = "webworld_pineling.png",
	wield_image = "webworld_pineling.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("webworld:pinewood", {
	description = "Pine wood planks",
	tiles = {"webworld_pinewood.png"},
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
})

-- Crafting

minetest.register_craft({
	output = "webworld:pinewood 4",
	recipe = {
		{"webworld:pinetree"},
	}
})

-- Register stairs and slabs

stairs.register_stair_and_slab(
	"pinewood",
	"webworld:pinewood",
	{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	{"webworld_pinewood.png"},
	"Pinewood stair",
	"Pinewood slab",
	default.node_sound_wood_defaults()
)

