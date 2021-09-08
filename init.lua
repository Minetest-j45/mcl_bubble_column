mcl_bubble_column = {}

mcl_bubble_column.old_neighbors = {}
mcl_bubble_column.new_neighbors = {}

--local default_water_groups = { water=3, liquid=3, puts_out_fire=1, freezes=1, not_in_creative_inventory=1, dig_by_piston=1}
--local bubble_column_groups = { water=3, liquid=3, puts_out_fire=1, freezes=1, not_in_creative_inventory=1, dig_by_piston=1, bubbly=1}

minetest.register_abm{
    label = "neighborChangedSoulSand",
	nodenames = {"mcl_nether:soul_sand"},
	interval = 0.5,
	chance = 1,
	action = function(pos)
		local plusx = minetest.get_node(vector.add(pos, {x = 1, y = 0, z = 0}))
		local minusx = minetest.get_node(vector.add(pos, {x = -1, y = 0, z = 0}))
		local plusz = minetest.get_node(vector.add(pos, {x = 1, y = 0, z = 1}))
		local minusz = minetest.get_node(vector.add(pos, {x = 0, y = 0, z = -1}))
		local up = minetest.get_node(vector.add(pos, {x = 0, y = 1, z = 0}))
		local down = minetest.get_node(vector.add(pos, {x = 0, y = -1, z = 0}))
		mcl_bubble_column.new_neighbors[pos] = {plusx, minusx, plusz, minusz, up, down}
		
		if mcl_bubble_column.old_neighbors[pos] == {} then
			mcl_bubble_column.old_neighbors[pos] = mcl_bubble_column.new_neighbors[pos]
		else
			if mcl_bubble_column.new_neighbors[pos] ~= mcl_bubble_column.old_neighbors[pos] then
				--neighbors changed
				mcl_bubble_column.place_bubble_column(vector.add(pos, {x = 0, y = 1, z = 0}))--place bubble column one block up
				mcl_bubble_column.old_neighbors[pos] = mcl_bubble_column.new_neighbors[pos]
			end
		end
	end,
}


minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	--checks
	if oldnode == nil then return end
	if newnode == nil then return end
	if newnode.name == "mcl_nether:soul_sand" then
		--soul sand placed
		mcl_bubble_column.place_bubble_column(vector.add(pos, {x = 0, y = 1, z = 0}))
	end
end)

minetest.register_abm{
    label = "neighborChangedWater",
	nodenames = {"group:water"},
	interval = 0.5,
	chance = 1,
	action = function(pos)
		--if not bubble column block return
		local meta = minetest.get_meta(pos)
		if meta:get_int("bubbly") == 0 then return end
		
		local plusx = minetest.get_node(vector.add(pos, {x = 1, y = 0, z = 0}))
		local minusx = minetest.get_node(vector.add(pos, {x = -1, y = 0, z = 0}))
		local plusz = minetest.get_node(vector.add(pos, {x = 1, y = 0, z = 1}))
		local minusz = minetest.get_node(vector.add(pos, {x = 0, y = 0, z = -1}))
		local up = minetest.get_node(vector.add(pos, {x = 0, y = 1, z = 0}))
		local down = minetest.get_node(vector.add(pos, {x = 0, y = -1, z = 0}))
		mcl_bubble_column.new_neighbors[pos] = {plusx, minusx, plusz, minusz, up, down}
		
		if mcl_bubble_column.old_neighbors[pos] == {} then
			mcl_bubble_column.old_neighbors[pos] = mcl_bubble_column.new_neighbors[pos]
		else
			if mcl_bubble_column.new_neighbors[pos] ~= mcl_bubble_column.old_neighbors[pos] then
				--neighbors changed
				if mcl_bubble_column.is_valid_pos(pos) == false then
					local meta = minetest.get_meta(pos)
					meta:set_int("bubbly", 0)
				else
					mcl_bubble_column.place_bubble_column(vector.add(pos, {x = 0, y = 1, z = 0}))
				end
			end
		end
	end,
}

mcl_bubble_column.place_bubble_column = function(pos)
	if mcl_bubble_column.can_hold_bubble_column(pos) then
		local meta = minetest.get_meta(pos)
		meta:set_int("bubbly", 1)
	end
end

mcl_bubble_column.can_hold_bubble_column = function(pos)
	local node = minetest.get_node(pos)
	local below = minetest.get_node(vector.add(pos, {x = 0, y = -1, z = 0}))
	local meta = minetest.get_meta(pos)
	local bmeta = minetest.get_meta(vector.add(pos, {x = 0, y = -1, z = 0}))
	--checks if pos is fit for bubble column
	if node.name == "mcl_core:water_source" and (meta:get_int("bubbly") == 0 and below.name == "mcl_nether:soul_sand" or bmeta:get_int("bubbly") == 1) then
		return true
	else
		return false
	end
end

mcl_bubble_column.is_valid_pos = function(pos)
	local below = minetest.get_node(vector.add(pos, {x = 0, y = -1, z = 0}))
	local meta = minetest.get_meta(vector.add(pos, {x = 0, y = -1, z = 0}))
	if meta:get_int("bubbly") == 1 or below.name == "mcl_nether:soul_sand" then
		return true
	else
		return false
	end
end

minetest.register_abm{
    label = "bubbles up",
    nodenames = {"group:bubbly"},
    interval = 0.05,
    chance = 1,
    action = function(pos)
		minetest.add_particle({
			pos = {x = pos.x+0.5, y = pos.y, z = pos.z+0.5},
			velocity = {x = 0, y = 1, z = 0},
			expirationtime = 1,
			size = math.random(0.7, 2.4),
			texture = "mcl_particles_bubble.png"
		})
		minetest.add_particle({
			pos = {x = pos.x+math.random(0, 1), y = pos.y+math.random(0, 1), z = pos.z+math.random(0, 1)},
			velocity = {x = 0, y = 1, z = 0},
			expirationtime = 1,
			size = math.random(0.7, 2.4),
			texture = "mcl_particles_bubble.png"
		})minetest.add_particle({
			pos = {x = pos.x+math.random(0, 1), y = pos.y+math.random(0, 1), z = pos.z+math.random(0, 1)},
			velocity = {x = 0, y = 1, z = 0},
			expirationtime = 1,
			size = math.random(0.7, 2.4),
			texture = "mcl_particles_bubble.png"
		})
    end,
}

mcl_bubble_column.on_entity_collided_with_bubble_column = function(pos)
	local above = minetest.get_node(vector.add(pos, {x = 0, y = 1, z = 0}))
	if above.name == "air" then
		mcl_bubble_column.on_enter_bubble_column_with_air_above()
	else
		mcl_bubble_column.on_enter_bubble_column()
	end
end

mcl_bubble_column.on_enter_bubble_column = function(self)
	local velocity = self.object:get_velocity()
	velocity.y = math.min(0.7+2.3, velocity.y+0.06+2.3)
	self.object:set_velocity(velocity)
end

mcl_bubble_column.on_enter_bubble_column_with_air_above = function(self)
	local velocity = self.object:get_velocity()
	velocity.y = math.min(1.8+2.3, velocity.y+0.1+2.3)
	self.object:set_velocity(velocity)
end

minetest.register_on_mods_loaded(function()
	for _, entity in pairs(minetest.registered_entities) do
		local on_step = entity.on_step
		function entity.on_step(...)
			local self, dtime, moveresult = ...
			--checks
			if not moveresult then return end
			if moveresult.collisions == {} then return end
			if moveresult.collides == true then
				if not moveresult.collisions[1] then return end
				if not moveresult.collisions[1].type == "node" then return end
				local pos = moveresult.collisions[1].node_pos
				if pos == nil then return end
				local uppos = vector.add(pos, {x = 0, y = 1, z = 0})
				if minetest.get_node(uppos).name ~= "mcl_core:water_source" then return end
				local meta = minetest.get_meta(uppos)
				if meta:get_int("bubbly") == 1 then
					--bubble column collision
					--use mcl_bubble_column.on_entity_collided_with_bubble_column = function(pos) later
					local upup = minetest.get_node(vector.add(uppos, {x = 0, y = 1, z = 0}))
					if upup.name == "air" then
						mcl_bubble_column.on_enter_bubble_column_with_air_above(self)
					else
						mcl_bubble_column.on_enter_bubble_column(self)
					end
				end
			end
			return on_step(...)
		end
	end
end)


