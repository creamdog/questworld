pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

chunk = {}
ents = {}
entmap = {}
entype = {player = 1, coin = 2, wlizard = 3, teleport = 4, cherry = 5, spray = 6, sign = 7}
direction = {left=1,right=2,up=3,down=4}
t = 0
btns = {}
items = {}
items_meta = {}
is_game_over = false
global_anim_flag = 0
global_anim_ticks = 0
global_anim_tick_interval = 16
player = nil
alerts = {}
global_zoom = 2.0
global_text = nil

function _init()
	reset_level()
end

function add_alert(x,y,text,ticks)
	add(alerts, {x=x,y=y,text=text,blink=0,ticks=ticks})
end

function reset_level()
	global_anim_flag = 0
	global_anim_ticks = 0
	global_anim_tick_interval = 16
	is_game_over = false
	chunk = {}
	ents = {}
	entmap = {}
	direction = {left=1,right=2,up=3,down=4}
	t = 0
	btns = {}
	items = {}
	items_meta = {}
	alerts = {}
	global_text = nil

	add_alert(0,0,"foo",20)

	add(ents, 
	{
		type=entype.player,
		x = 0,
		y = 0,
		dx = 0,
		dy = 0,
		cx = 0,
		cy = 1,
		cz = 0,
		d = direction.right,
		a = 0,
		move_delta_x = 0,
		move_delta_y = 0
	})
	player = ents[1]

	chunk = create_chunk(level1)

	add(items, {block = 1, count=2000})
	add(items, {block = 2, count=200})
	add(items, {block = 3, count=20})
	add(items, {block = 4, count=200})
	add(items, {block = 5, count=200})
	add(items, {block = 6, count=200})
	add(items, {block = 7, count=7})
	items_meta.selected = 4
end

function create_chunk(level)
	chunk = {}
	chunk.meta = {dirty=true,num_visible=0,width=1,depth=1}

	while (level[chunk.meta.width] != nil) do
		while (level[chunk.meta.width][chunk.meta.depth] != nil) do
			chunk.meta.depth+=1
		end
		chunk.meta.width+=1
	end

	for x=1,chunk.meta.width-1,1 do
		row = {}
		for z=1,chunk.meta.depth-1,1 do
			pile = {}
			for y=1,10,1 do
				n = level[x][z][y]
				if (n == nil) then
					add(pile, nil)
				elseif (n == r.coin) then
					--add(pile, nil)
					add(ents, 
					{
						type=entype.coin,
						cx = z,
						cy = y-1,
						cz = x
					})
				elseif (n == r.wlizard) then
					--add(pile, nil)
					add(ents, 
					{
						type=entype.wlizard,
						cx = z,
						cy = y-1,
						cz = x
					})
				elseif (n == r.teleport) then
					--add(pile, nil)
					add(ents, 
					{
						type=entype.teleport,
						cx = z,
						cy = y-1,
						cz = x
					})
				elseif (n == r.cherry) then
					--add(pile, nil)
					add(ents, 
					{
						type=entype.cherry,
						cx = z,
						cy = y-1,
						cz = x
					})
				elseif (type(n) != "number" and n.text != nil) then
					--add(pile, nil)
					add(ents, 
					{
						type=entype.sign,
						cx = z,
						cy = y-1,
						cz = x,
						text = n.text
					})
				else
					add(pile, createblock(n))
					if (num == 3) make_spray(z, y, x, 3, 0, -1, 0, 6, 10, 1, 0.1, 0.5)
				end
			end


			--[[
			pile = {}
			for y=1,10,1 do
				add(pile,nil)
			end
			pile[1] = createblock(1)
			if (z >= 5 and z <= 6) pile[1] = createblock(5)
			if (z == 4) pile[2] = createblock(1)
			if (z == 7) pile[2] = createblock(1)
			]]
			
			add(row, pile)
		end
		add(chunk,row)
	end

	return chunk
end

function game_over()
	sfx(2)
	is_game_over = true
	--reset_level()
end

function createblock(num)

	deco = 0
	if (rnd(100) > 80) deco = flr(rnd(3))

	return {num = num, static = false, visible = true, deco = deco}
end

function update_entity(e)

	if (e.type == entype.player) then
		update_player(e)
	end

	function entmap_entity(e)
		if (entmap[e.cx] == nil) entmap[e.cx] = {}
		if (entmap[e.cx][e.cz] == nil) entmap[e.cx][e.cz] = {}
		if (entmap[e.cx][e.cz][e.cy] == nil) entmap[e.cx][e.cz][e.cy] = {}
		add(entmap[e.cx][e.cz][e.cy], e)

		if (e.type == entype.player) return

		if (chunk[e.cz] == nil) return
		if (chunk[e.cz][e.cx] == nil) return
		if (chunk[e.cz][e.cx][e.cy] == nil) return
		chunk[e.cz][e.cx][e.cy].deco = 0
	end


	if (e.type == entype.coin) then
		entmap_entity(e)
		foreach(entmap[e.cx][e.cz][e.cy], function(e2)
			if (e2.type == entype.player) then
				del(ents, e)
				del(entmap[e.cx][e.cz][e.cy], e)
				x = (e.cx-1)*8+(e.cz-1)*8 + 4
				y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6) - 2
				add_alert(x-1,y,"+1",10)
			end
		end)

		return
	end

	if (e.type == entype.cherry) then
		entmap_entity(e)
		foreach(entmap[e.cx][e.cz][e.cy], function(e2)
			if (e2.type == entype.player) then
				del(ents, e)
				del(entmap[e.cx][e.cz][e.cy], e)
				x = (e.cx-1)*8+(e.cz-1)*8 + 4
				y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6) - 2
				add_alert(x-1,y,"nom!",10)
			end
		end)

		return
	end

	if (e.type == entype.sign) then
		entmap_entity(e)

		if (e.cx == player.cx and e.cz == player.cz) then
			e.show = true
			global_text = e.text
		else
			global_text = nil
			e.show = false
		end

		return
	end

	if (e.type == entype.wlizard) then
		entmap_entity(e)
		return
	end

	if (e.type == entype.spray) then
		entmap_entity(e)
		n = 0
		foreach(e.particles, function(p)
			n += 1
			p.t += p.s
			if (p.t > p.ttl) then
				if (e.loop == false) then
					del(e.particles, p)
					return
				end
				p.t = p.t - p.ttl
			end
		end)
		if (n == 0) del(ents, e)
		return
	end

	if (e.type == entype.teleport) then
		entmap_entity(e)
		if (e.sprays == nil) then
			make_spray(e.cx, e.cy, e.cz, 5, 0, -1, 0, 4, 10, 7, 1, 0.3)
			e.sprays = true
		end	

		has_player = false
		foreach(entmap[e.cx][e.cz][e.cy], function(e2)
			if(has_player == true) return
			if (e2.type == entype.player) then
				has_player = true
				if (e.triggered == true) return
				e.triggered = true
				foreach(ents, function(e3)
					if(e3 != e and e3.type == entype.teleport) then
						if (e3.triggered == true) return
						player.cx = e3.cx
						player.cy = e3.cy
						player.cz = e3.cz
						e3.triggered = true
						player.x = (e3.cx-1) * 8
						player.y = (e3.cz-1) * 4
						x = (e3.cx-1)*8+(e3.cz-1)*8 + 4
						y = -(e3.cx-1)*4+(e3.cz-1)*4-((e3.cy-1)*6) - 1
						add_alert(x-1,y,"pop!",10)
						chunk.dirty = true
						del(entmap[e.cx][e.cz][e.cy], player)
						if (entmap[e3.cx] == nil) entmap[e3.cx] = {}
						if (entmap[e3.cx][e3.cz] == nil) entmap[e3.cx][e3.cz] = {}
						if (entmap[e3.cx][e3.cz][e3.cy] == nil) entmap[e3.cx][e3.cz][e3.cy] = {}
						add(entmap[e3.cx][e3.cz][e3.cy], player)
						--make_spray(e3.cx, e3.cy, e3.cz, 3, 0, -1, 0, 4, 5, 7, 1, 0.3, false, 50)
					end
				end)
			end
			if (has_player == false) e.triggered = false
		end)

		--if (e.triggered == true) return

		return
	end

	if (e.type != entype.player) return

	function limit(n,c)
		if (abs(n) > c) then
			if (n > 0) then
				return c
			else 
				return -c
			end
		end
		return n
	end

	function resolve_chunk_collision(e)

		cx = flr(e.x/8)+1;
		cz = flr(e.y/4)+1;


		if (chunk[cz][cx][e.cy] == nil) then
			e.cy -= 1
			e.move_delta_y -= 8
		end

		y = e.y + e.dy*4
		x = e.x + e.dx*8
		cx = flr(x/8)+1;
		cz = flr(y/4)+1;

		if (cx < 1 or cx > chunk.meta.width-1 or cz < 1 or cz > chunk.meta.depth-1) then
			e.dy = 0
			e.dx = 0
			return
		end

		for y=e.cy,1,-1 do
			b = chunk[cz][cx][y]
			if (b != nil and (b.num == 5 or b.num == 3)) then
				e.dy = 0
				e.dx = 0
				return
			elseif b != nil then
				break
			end
		end

		block = chunk[cz][cx][e.cy+1]
		f = chunk[cz][cx][e.cy]
		if (block != nil or (f != nil and f.num == 5)) then

			if (chunk[cz][cx][e.cy+2] == nil and (f == nil or f.num != 5) and block.num != 3) then
				e.cy += 1
				e.move_delta_y += 8
			else
				e.dy = 0
				e.dx = 0
			end
		end
	end

	--e.dx = limit(e.dx, 1)
	--e.dy = limit(e.dy, 0.5)
	resolve_chunk_collision(e)

	px = e.cx
	pz = e.cz

	e.y += e.dy*4
	e.x += e.dx*8
	e.cx = flr(e.x/8)+1;
	e.cz = flr(e.y/4)+1;

	if (e.cx != px) e.px = px
	if (e.cz != pz) e.pz = pz

	if (e.move_delta_x != nil and e.move_delta_x >= 1) e.move_delta_x -= 1
	if (e.move_delta_y != nil and e.move_delta_y >= 1) e.move_delta_y -= 1
	if (e.move_delta_x != nil and e.move_delta_x <= -1) e.move_delta_x += 1
	if (e.move_delta_y != nil and e.move_delta_y <= -1) e.move_delta_y += 1

	if (entmap[e.cx] == nil) entmap[e.cx] = {}
	if (entmap[e.cx][e.cz] == nil) entmap[e.cx][e.cz] = {}
	if (entmap[e.cx][e.cz][e.cy] == nil) entmap[e.cx][e.cz][e.cy] = {}
	add(entmap[e.cx][e.cz][e.cy], e)

	foreach(entmap[e.cx][e.cz][e.cy], function(e2)
		if (e2 != e and e.type == entype.player) then
			del(ents, e2)
			del(entmap[e.cx][e.cz][e.cy], e2)
		end
	end)


	--[[
	e.dx *= 0.80
	e.dy *= 0.80
	if (abs(e.dx) < 0.2) e.dx = 0
	if (abs(e.dy) < 0.1) e.dy = 0
	]]
end

function update_player(e)

	e.dy = 0
	e.dx = 0

	function a(x, y)
		chunk.meta.dirty = true
		e.move_delta_x = x
		e.move_delta_y = y
	end

	xs = 8
	ys = 4

	if (btn(0) and btns[0] == false) then
		if (e.d != direction.left) then
			e.d = direction.left
		else
			e.dy -= 1
			a(xs,ys)
		end
		
	elseif (btn(1) and btns[1] == false) then
		if (e.d != direction.right) then
			e.d = direction.right
		else
			e.dy += 1
			a(-xs,-ys)
		end
		
	elseif (btn(2) and btns[2] == false) then
		if (e.d != direction.up) then
			e.d = direction.up
		else
			e.dx += 1
			a(-xs,ys)
		end
		
	elseif (btn(3) and btns[3] == false) then
		if (e.d != direction.down) then
			e.d = direction.down
		else
			e.dx -= 1
			a(xs,-ys)
		end
		
	end

	if (global_text != nil) then

		if (btn(4) and btns[4] != true) then
			for i = 2, #global_text, 1 do
				local c = sub(global_text, i, i)
				if (c == "\n" or 1 == 1) then
					global_text = sub(global_text, i)
					break
				end
			-- do something with c
			end
		end


		return
	end

	function block()

		b = nil
		foreach(items, function(item)
			if (item.block == items_meta.selected) b = item
		end)

		function place_block(x, y, z, n)

			if (z < 1 or z > chunk.meta.depth-1 or x < 1 or x > chunk.meta.width-1) return

			if (b.count == 0) return
			b.count -= 1
			n = items_meta.selected

			b = chunk[z][x][y]
			if (b != nil) return
			chunk[z][x][y] = createblock(n)
			chunk[z][x][y].layer = y
			if (n == 3) make_spray(x, y, z, flr(rnd(3)), 0, -1, 0, 6, 10, 1, 0.3, 0.7, false)
			sfx(0)
			chunk.meta.dirty = true
		end
		if (e.d == direction.left) then
			place_block(e.cx, e.cy+1, e.cz-1, n)
		elseif (e.d == direction.right) then
			place_block(e.cx, e.cy+1, e.cz+1, n)
		elseif (e.d == direction.up) then
			place_block(e.cx+1, e.cy+1, e.cz, n)
		elseif (e.d == direction.down) then
			place_block(e.cx-1, e.cy+1, e.cz, n)
		end	
	end

	function destroy()

		function destroy_block(x, y, z)
			b = chunk[z][x][y]
			if (b == nil) return
			chunk[z][x][y] = nil
			sfx(1)
			chunk.meta.dirty = true
		end

		if (e.d == direction.left) then
			destroy_block(e.cx, e.cy+1, e.cz-1)
		elseif (e.d == direction.right) then
			destroy_block(e.cx, e.cy+1, e.cz+1)
		elseif (e.d == direction.up) then
			destroy_block(e.cx+1, e.cy+1, e.cz)
		elseif (e.d == direction.down) then
			destroy_block(e.cx-1, e.cy+1, e.cz)
		end
		
	end

	if (btn(4) and btns[4] != true) then
		block()
	end

	if (btn(5) and btns[5] != true) then
		--destroy()
		items_meta.selected += 1
		if (items_meta.selected > 7) items_meta.selected = 1
		items_meta.selected_display = true

	end


end

function block_is_next_to(x,y,z,fn)
	b = false
	if (chunk[x+1] != nil and chunk[x+1][z] != nil) b = fn(x+1,y,z,chunk[x+1][z][y],b)
	if (chunk[x-1] != nil and chunk[x-1][z] != nil) b = fn(x-1,y,z,chunk[x-1][z][y],b)
	if (chunk[x] != nil and chunk[x][z+1] != nil) b = fn(x,y,z+1,chunk[x][z+1][y],b)
	if (chunk[x] != nil and chunk[x][z-1] != nil) b = fn(x,y,z-1,chunk[x][z-1][y],b)
	if (chunk[x] != nil and chunk[x][z] != nil) b = fn(x,y-1,z,chunk[x][z][y-1],b)
	if (chunk[x] != nil and chunk[x][z] != nil) b = fn(x,y+1,z,chunk[x][z][y+1],b)
	return b
end

function update_mini_map()

	yo = 128-64
	xo = 0
	w = 32
	h = 32

	wd = w/chunk.meta.width
	hd = h/chunk.meta.depth

	--rectfill(xo, yo, xo+64, yo+64, 7)

	for x=1,chunk.meta.width-1,1 do
		for z=1,chunk.meta.depth-1,1 do
			for y=10,1,-1 do
				block = chunk[x][z][y]
				if (block != nil) then
					col = 0
					if (player.cx == z and player.cz == x) then
						col = 8
					elseif (block.num == 1) then
						col = 3
					elseif (block.num == 2) then
						col = 5
					elseif (block.num == 3) then
						col = 9
					elseif (block.num == 4) then
						col = 4
					elseif (block.num == 5) then
						col = 12
					elseif (block.num == 6) then
						col = 11
					end
					px = xo + ((z-1)/(chunk.meta.width)) * (w/wd+1)
					py = yo + ((x-1)/(chunk.meta.depth)) * (h/hd+1)
					sset(flr(px),flr(py),col)
					break	
				end
			end
		end
	end

	chunk.meta.map_refresh = t

end

function update_chunk(chunk)
	if (chunk.meta.dirty == true) then 
		chunk.meta.num_visible = 0
	else
		return
	end

	keep_dirty = false

	for x=1,chunk.meta.width-1,1 do
		for z=1,chunk.meta.depth-1,1 do
			for y=1,10,1 do

				block = chunk[x][z][y]

				-- optimize for rendering
				if (chunk.meta.dirty == true and block != nil) then
					visible = true
					if (chunk[x+1] != nil and chunk[x+1][z] != nil and chunk[x+1][z][y] != nil and (chunk[x+1][z][y].num != 5)) then
						if (chunk[x][z-1] != nil and chunk[x][z-1][y] != nil and (chunk[x][z-1][y].num != 5)) then
							if (chunk[x][z][y+1] != nil and chunk[x][z][y+1].num != 7) then
								visible = false
							end
						end
					end
					px = player.cx - z
					py = player.cz - x
					if (abs(px) > 4 or abs(py) > 4 ) visible = false					
					if (block.visible != visible and (block.was_visible == nil or block.was_visible == 0)) block.was_visible = 4
					block.visible = visible
					if (visible == true) chunk.meta.num_visible += 1
				end

				--if (block != nil and block.visible == false) break

				-- transform lava blocks into rock blocks
				if (block != nil and block.num == 3 and block_is_next_to(x,y,z,function(x,y,z,b,default)
						if (b != nil and b.num == 5) then
							--chunk[x][z][y] = nil
							return true
						end
						return default
					end) == true) then
					chunk[x][z][y] = createblock(2)
					chunk.meta.dirty = true
					make_spray(x, y, z, 1 + flr(rnd(3)), 0, -1, 0, 6, 10, 1, 0.3, 0.7, false)
					sfx(4)
					return
				end

				if (y > 1 and block != nil and block.static == false and (chunk[x][z][y-1] == nil or (chunk[x][z][y-1].num == 5 and block.num != 5))) then
					chunk[x][z][y-1] = block
					chunk[x][z][y] = nil
					chunk.meta.dirty = true
					if (block.num == 4 and chunk[x][z][y-2] != nil) block.static = true
					return
				elseif (block != nil and block.num == 5 and (chunk.meta.dirty == true or block.checked != true)) then

					--spread = false

					function make_water_block()
						sfx(3)
						chunk.meta.dirty = true
						b = createblock(5)
						b.visible = false
						b.layer = block.layer
						keep_dirty = true
					--	spread = true
						return b
					end

					function check_water_spread(x2,z2,y2)
						if (chunk[x2] == nil) return
						if (chunk[x2][z2] == nil) return
						if (chunk[x2][z2][y2] != nil) return
						--if (chunk[x2][z2][y2-1] == nil) return
						--if (chunk[x2][z2][y2-1] == nil) return

						if (block.spread_from_land == true) then
							if (chunk[x][z][y-1] == nil or chunk[x][z][y-1].num == 5) then
								return
							end
						end

						b = make_water_block()
						b.spread_from_land = false
						if (chunk[x][z][y-1] != nil and chunk[x][z][y-1].num != 5) then
							b.spread_from_land = true
						end

						chunk[x2][z2][y2] = b 
					end

					check_water_spread(x+1,z,y)
					check_water_spread(x-1,z,y)
					check_water_spread(x,z+1,y)
					check_water_spread(x,z-1,y)

					--if (chunk[x+1] != nil and chunk[x+1][z] != nil and chunk[x+1][z][y] == nil and (chunk[x+1][z][y-1] != nil or chunk[x][z][y-1] != nil)) chunk[x+1][z][y] = make_water_block()
					--if (chunk[x-1] != nil and chunk[x-1][z] != nil and chunk[x-1][z][y] == nil and (chunk[x-1][z][y-1] != nil or chunk[x][z][y-1] != nil)) chunk[x-1][z][y] = make_water_block()
					--if (chunk[x] != nil and chunk[x][z+1] != nil and chunk[x][z+1][y] == nil and (chunk[x][z+1][y-1] != nil or chunk[x][z][y-1] != nil)) chunk[x][z+1][y] = make_water_block()
					--if (chunk[x] != nil and chunk[x][z-1] != nil and chunk[x][z-1][y] == nil and (chunk[x][z-1][y-1] != nil or chunk[x][z][y-1] != nil)) chunk[x][z-1][y] = make_water_block()
					block.checked = true
					block.static = true

					--if (spread == true) return

					--[[
					if (block_is_next_to(x,y,z,function(x2,y2,z2,b)
							if (b == nil and y == y2 and x2 > 0 and z2 > 0 and x2 < 11 and z2 < 11) return true
							return false
						end) == true) then
						chunk[x][z][y] = nil
						chunk.meta.dirty = true
						return
					end
					]]

				elseif (block != nil) then
					block.static = true
				end

				if (block != nil and block.num == 7 and block.grown != true and chunk[x][z][y+1] == nil) then
					chunk[x][z][y+1] = createblock(6)
					block.grown = true
				end

			end
		end
	end

	if (chunk.meta.dirty == true) update_mini_map()

	chunk.meta.dirty = keep_dirty
end


global_zoom_r = 0

function _update()
	t += 1


	global_zoom = 1 + (cos(global_zoom_r) * (0.5 * (global_zoom/2 + 1)))
	--if (global_zoom > 10) global_zoom = 0.1

	
	global_zoom_r += 0.01

	--if (global_zoom_r > )

	global_zoom = 1

	--global_zoom = 0.2 --player.cy-1

	if (t - global_anim_ticks > global_anim_tick_interval) then
		if (global_anim_flag == 0) then
			global_anim_flag = 1
		else
			global_anim_flag = 0
		end
		global_anim_ticks = t
	end

	if (is_game_over == true) then
		for i=0,10,1 do
			if (btn(i) and btns[i] == false) then
				reset_level()
				return
			end
		end
	else
		entmap = {}
		foreach(ents, update_entity)
		update_chunk(chunk)
	end

	for i=0,10,1 do
		btns[i] = btn(i)
	end

end



function _draw()

	if (1 == 2) then
		cls()
		map(0, 0, 0, 0, 16, 16)

		if (global_anim_flag == 0) print("press any key", 38, 75, 7)

		print("(c) 2016 christian westman", 13, 128-8, 7)
		return
	end 

	cls()
	camera()

	if (sky_scroll == nil) sky_scroll = 0
	sky_scroll -= 0.01
	if (sky_scroll < -128) sky_scroll = 128 + sky_scroll

	map(16, 0, sky_scroll, 0, 16, 16)
	map(16, 0, 128+sky_scroll, 0, 16, 16)

	--map(16, 8, sky_scroll, 16, 16, 8)
	--map(16, 8, 128+sky_scroll, 16, 16, 8)
	--print(ents[1].cx .. "x" .. ents[1].cz.. ":" .. ents[1].cy .. "(dir:" .. ents[1].d .. ")", 5, 5, 14)
	-- print("visible:" .. chunk.meta.num_visible, 5,5+6,10)

	if (player.move_delta == nil) player.move_delta = 0

	--d = "false"
	--if (chunk.meta.dirty == true) d = "true"
	--print("dirty: " .. d, 5, 5, 10)
	--if (chunk.meta.map_refresh == nil) chunk.meta.map_refresh = 0
	--print("map_refresh: " .. chunk.meta.map_refresh, 5, 11, 10)
	--if (player.move_delta != nil) print("d:" .. player.move_delta, 5, 17, 10)

	x = ents[1].x + ents[1].y*2 + player.move_delta_x + 8
	y = ents[1].y - ents[1].x/2 + player.move_delta_y + 16

	x *= global_zoom
	y = y*global_zoom - (10 * global_zoom) - (((player.cy-1)*8) * global_zoom)

	--print(x..":"..y,5,5,10)

	camera(x - 64, y - 64)
	draw_chunks()

	foreach(alerts, function(a)
		
		if (a.blink != 10) then
			print(a.text, a.x*global_zoom+1, a.y*global_zoom+1,1)
			print(a.text, a.x*global_zoom, a.y*global_zoom,7)
		end

		a.y -= 1
		a.ticks -= 1
		if (a.blink == 0) then 
			a.blink = 1 
		else 
			a.blink = 0			
		end
		if (a.ticks == 0) del(alerts, a)
	end)


	if (global_text != nil) then
		draw_text()
	else
		draw_menu()
	end


	camera()
	sspr(0,128-64,32,32,128-32,1,32,32)

	

end

function draw_text()
	camera()
	rectfill(0,128-22,128,128,6)
	rectfill(0+1,128-22+1,128-2,128-2,0)
	print(global_text, 2, 128 - 20, 7)
end

function draw_menu()
	camera()
	camera(0,0-128+22)
	nitems = 0
	if (items_meta.selected_tick == nil) items_meta.selected_tick = t
	if (items_meta.selected_display == nil) items_meta.selected_display = true
	foreach(items, function(item)
		nitems += 1
	end)
	i=0
	foreach(items, function(item)

		selected = false
		if (items_meta.selected == item.block) selected = true

		b = 8 + (item.block-1) * 16
		sspr(b,0,16,16,0,0,16,16)

		tx = 7
		c = item.count
		while (c > 0) do
			c = flr(c/10)
			if (c > 0) tx -= 2
		end


		print(item.count,tx+1,17,1)
		print(item.count,tx,16,7)

		if (selected == true and items_meta.selected_display == true) then
			sspr(8 + (7-1) * 16,16,16,16,0,0,16,16)
		end

		if (selected == true and t - items_meta.selected_tick > 10) then
			items_meta.selected_tick = t
			if (items_meta.selected_display == true) then
				items_meta.selected_display = false
			else
				items_meta.selected_display = true
			end
		end
		i += 1
		camera(-i*17,0-128+22)
	end)
	
end



function draw_chunks()
	for x=1,chunk.meta.width-1,1 do
		for z=chunk.meta.depth-1,1,-1 do
			for y=1,10,1 do
				block = chunk[x][z][y]
				render = false
				if (block != nil and block.visible == true or (block != nil and block.was_visible != nil and block.was_visible > 0)) then
					render = true
					if (block.was_visible != nil and block.visible == false and block.was_visible > 0) block.was_visible -= 1
				end
				if (render == true) then
					if (render == true) then					
						px = (x-1)*8+(z-1)*8
						py = (x-1)*4-(z-1)*4-((y-1)*6)
						b = 8 + (block.num-1) * 16

						if (block.num == 5) then
							if(chunk[x][z][y-1] != nil and chunk[x][z][y-1].num == 5) then
								sspr(b,0,16,16,px,py+6,16,16)
							end
							py += 3
						end

						px *= global_zoom
						py *= global_zoom

						w = flr(16 * global_zoom)
						h = flr(16 * global_zoom)

						sspr(b,0,16,16,px,py,w,h)

						if (block.deco > 0 and chunk[x][z][y+1] == nil) then

							s = (1 + ((block.num-1)*2) + 32 + (block.deco - 1)) + (16*global_anim_flag)
							--spr(s,px+4,py-1)

							px += (5 * global_zoom)
							--py += (1 * global_zoom)
							sx = b + (8*(block.deco-1))
							sy = 16 + (8*global_anim_flag)
							w = flr(8 * global_zoom)
							h = flr(8 * global_zoom)

							sspr(sx,sy,8,8,px,py,w,h)
						end

						if (entmap[z] != nil and entmap[z][x] != nil and entmap[z][x][y] != nil) then
							--sspr(b,0,16,16,px,py-3,16,16)
							p = nil
							-- draw not players
							foreach(entmap[z][x][y], function(e)
								if (e.type == entype.player) then
									p = e
									return
								end
								if (e.type == entype.spray) return
								draw_entity(e)
							end)
							-- draw player
							if (p != nil) draw_entity(p)
							-- draw sprays
							foreach(entmap[z][x][y], function(e)
								if (e.type == entype.player) return
								if (e.type != entype.spray) return
								draw_entity(e)
							end)
						end	


					end	

				end
			end
		end
	end
end

function make_spray(x, y, z, num_particles, dx, dy, ox, oy, ttl, col, sp1, sp2, loop, s1, s2)

	if (num_particles <= 0) return
	if (loop == nil) loop = true
	if (s1 == nil) s1 = 1
	if (s2 == nil) s2 = 1

	particles = {}
	for i=0,num_particles,1 do
		add(particles, {col=col,x=ox+i*(8/num_particles),y=oy,ttl=ttl,t=0,s=sp1+rnd(sp2),dx=dx,dy=dy})
	end
	add(ents, 
	{
		type=entype.spray,
		cx = x,
		cy = y,
		cz = z,
		particles = particles,
		loop = loop,
		s1 = s1,
		s2 = s2
	})
end

function draw_entity(e)

	if (e.type == entype.spray) then
		foreach(e.particles, function(p)
			x = (e.cx-1)*8+(e.cz-1)*8 + 4
			y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6) - 2
			x += p.x + p.dx * p.t
			y += p.y + p.dy * p.t
			x *= global_zoom
			y *= global_zoom
			--pset(x, y, p.col)

			size = e.s1 * (1.0 - p.t/p.ttl)


			circfill(x,y,size,p.col)



			--rectfill(x, y, x+15,y+15, 10)
			--print("spray", 0,0,7)
		end)
		return
	end

	if (e.type == entype.teleport) then
		x = (e.cx-1)*8+(e.cz-1)*8 + 5
		y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6)
		bop = global_anim_flag * 8
		w = 8 * global_zoom
		h = 8 * global_zoom
		x *= global_zoom
		y *= global_zoom
		sspr(3*8,32+bop,8,8,x,y,w,h)
		return
	end

	if (e.type == entype.cherry) then
		x = (e.cx-1)*8+(e.cz-1)*8 + 4
		y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6) - 2
		bop = global_anim_flag * 8
		w = 8 * global_zoom
		h = 8 * global_zoom
		x *= global_zoom
		y *= global_zoom
		sspr(8,32+bop,8,8,x,y,w,h)
		--print("coin", 5, 5, 7)
		return
	end

	if (e.type == entype.sign) then
		x = (e.cx-1)*8+(e.cz-1)*8 + 4
		y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6) - 3
		bop = global_anim_flag * 8
		w = 8 * global_zoom
		h = 16 * global_zoom
		x *= global_zoom
		y *= global_zoom
		

		if (e.show == true) then

		end

		sspr(0,32+16,8,16,x,y,w,h)

		--print("coin", 5, 5, 7)
		return
	end

	if (e.type == entype.coin) then
		x = (e.cx-1)*8+(e.cz-1)*8 + 4
		y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6) - 2
		bop = global_anim_flag * 8
		w = 8 * global_zoom
		h = 8 * global_zoom
		x *= global_zoom
		y *= global_zoom
		sspr(0,32+bop,8,8,x,y,w,h)
		--print("coin", 5, 5, 7)
		return
	end

	if (e.type == entype.wlizard) then
		x = (e.cx-1)*8+(e.cz-1)*8 + 4
		y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6) - 10
		bop = global_anim_flag * 16
		w = 8 * global_zoom
		h = 16 * global_zoom
		x *= global_zoom
		y *= global_zoom
		sspr(9*8,32+bop,8,16,x,y,w,h)
		return
	end

	if (e.type == entype.player) then

		--x = e.x + e.y*2 + 3 --+ e.move_delta_x
		--y = e.y - e.x/2 - ((e.cy-1) * 6) - 7--+ e.move_delta_y

		x = (e.cx-1)*8+(e.cz-1)*8 + 5
		y = -(e.cx-1)*4+(e.cz-1)*4-((e.cy-1)*6) - 5

		x *= global_zoom
		y *= global_zoom

		bop = global_anim_flag * 16

		w = 8 * global_zoom
		h = 16 * global_zoom

		if (e.d == direction.left) then
			--spr(65,x,y,1,1,true,false)
			sspr(48,32 + bop,8,16,x,y,w,h)
		elseif (e.d == direction.right) then
			--spr(81,x,y,1,1,false,false)
			sspr(40,32 + bop,8,16,x,y,w,h)
		elseif (e.d == direction.up) then
			--spr(65,x,y,1,1,false,false)
			sspr(56,32 + bop,8,16,x,y,w,h)
		elseif (e.d == direction.down) then
			--spr(81,x,y,1,1,true,false)
			sspr(32,32 + bop,8,16,x,y,w,h)
		end	
	end
end

r = {}
r.coin = 'coin'
r.cherry = 'cherry'
r.wlizard = 'wlizard'
r.teleport = 'teleport'


level564 = {
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
}

level1 = {
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{2,2,2},{2,2,2},{2,2,2},{2,2,2},{2,2,2},{2,2,2}},
	{{1},{1},{1},{1},{2,2,2},{2,2,2},{2,2,2},{2,2,1,r.cherry},{2,2,1,r.coin},{2,2,1,r.cherry}},
	{{1},{1},{1,r.teleport},{1},{2,2,2},{2,2,2,r.teleport},{2,2,2},{2,2,1,r.coin},{2,2,1,r.coin},{2,2,1,r.cherry}},
	{{1},{1},{1},{1},{2,2,2},{2,2,2},{2,2,2},{2,2,1,r.coin},{2,2,1,r.coin},{2,2,1,r.cherry}},
	{{1},{1},{1, {text="hint:\nuse the teleporter.\ngood luck!"}},{1},{2,2,2},{2,2,2},{2,2,2},{2,2,2},{2,2,2},{2,2,2}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
}

level4 = {
	{{1},{1},{1		  					},{1},{1},{1},{2			},{2			},{2				},{2}},
	{{1},{1},{1		  					},{1},{1},{1},{2			},{2			},{2,r.coin			},{2}},
	{{1},{1},{1		  					},{1},{1},{1},{2			},{2			},{2				},{2}},
	{{1},{1},{1							},{1},{1},{1},{2			},{3			},{3				},{3}},
	{{1},{1},{1,2,r.coin 				},{2},{2},{2},{2			},{3			},{2,2,2,r.wlizard	},{2,2,2}},
	{{1,r.teleport},{1,2},{1,2,2,r.teleport 		},{2},{2},{2},{2			},{3			},{3				},{3}},
	{{1},{1},{1,2,r.coin 				},{2},{2},{2},{2			},{2			},{2				},{2}},
	{{1},{1},{1,r.coin 					},{1},{1},{1},{2			},{2			},{2				},{2}},
	{{1},{1},{1,r.coin 					},{1},{1},{1},{2			},{2			},{2				},{2}},
	{{1},{1},{1,r.coin 					},{1},{1},{1},{2			},{2			},{2				},{2}},
}

level3 = {
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
}

level2 = {
	{{2,2},{2,2},{2,2},{2,2},{2,2},{2,2},{2,2},{2,2},{2,2},{2,2}},
	{{2,2},{2,2},{5  },{5  },{5  },{5  },{5  },{5  },{5  },{2,2}},
	{{2,2},{2,2},{5  },{5  },{5  },{5  },{5  },{5  },{5  },{2,2}},
	{{2,2},{2,2},{5  },{5  },{2,3},{2,3},{2,3},{5  },{5  },{2,2}},
	{{2,2},{2,2},{3,3},{2,3},{2,2},{2,2},{2,3},{5  },{5  },{2,2}},
	{{2,2},{2,2},{3,3},{2,3},{2,2},{2,2},{2,3},{5  },{5  },{2,2}},
	{{2,2},{2,2},{5  },{5  },{2,3},{2,3},{2,3},{5  },{5  },{2,2}},
	{{2,2},{2,2},{5  },{5  },{5  },{5  },{5  },{5  },{5  },{2,2}},
	{{2,2},{2,2},{5  },{5  },{5  },{5  },{5  },{5  },{5  },{2,2}},
	{{2,2},{2,2},{2,2},{2,2},{2,2},{2,2},{2,2},{2,2},{2,2},{2,2}},
}


--[[
level = {
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
	{{1},{1},{1},{1},{1},{1},{1},{1},{1},{1}},
}
]]


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001100000000000000110000000000000088000000000000002200000000000000dd0000000000000011000000000000000000000000000000
007007000000001133110000000000115511000000000088998800000000002244220000000000ddccdd00000000001133110000000000000000000000000000
0007700000001133333311000000115555551100000088999999880000002244444422000000ddccccccdd000000113333331100000000000000000000000000
00077000001133333333331100115555555555110088999999999988002244444444442200ddccccccccccdd0011333333333311000000000000000000007777
007007001133333333333333115555555555555588999999999999992244444444444444ddcccccccccccccc1133333333333333000000000000000000000007
0000000044113333333333226611555555555511aa889999999999889922444444444422ddddcccccccccc113b33333333333311000000444400000000000007
0000000044441133333322226666115555551111aaaa8899999988889999224444442222ddddddcccccc11113bbb333333331111000004999940000000000007
0000000044444411332222226666661155111111aaaaaa88998888889999992244222222ddddddddcc1111113bbbbb3333111111000004999940000000000000
0000000044444444222222226666666611111111aaaaaaaa888888889999999922222222dddddddd111111113bbbbbbb11111111000004444420000000000000
0000000044444444222222226666666611111111aaaaaaaa88888888999999992222222200dddddd111111003bbbbbbb11111111000004442220000000000000
0000000044444444222222226666666611111111aaaaaaaa8888888899999999222222220000dddd1111000033bbbbbb11111111000000442200000000099000
000000000044444422222200006666661111110000aaaaaa888888000099999922222200000000dd110000000033bbbb111111000000000000000000009a9400
00000000000044442222000000006666111100000000aaaa8888000000009999222200000000000000000000000033bb111100000000000000000000049a9440
0000000000000044220000000000006611000000000000aa880000000000009922000000000000000000000000000033110000000000000000000000004a9400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044000
0000000000000000000000000000000000000000000000a00a000000000000000000000000000000000000000000000000000000777700000000777700000007
0000000000088000000cc000007770000070000000a0a0a00a0a0a00000000000000000000000000000000000dd0000000000000700000000000000700007777
00000000088888800cccccc00777770007770000a0a0a0a00a0a0a0a0000000000000000000000000000000099d0000000000000700000000000000700000000
00000000088aa8800ccaacc00171770001177000aaaa9aaaaaa9aaaa000000000000000000001110011100000077770000076000700000000000000700000000
00000000088888800cccccc00717770000017770aa9999aaaa9999aa000000000000000000011100001110000277724002466240000000000000000000000000
0000000002288220022cc22007777000000017100aa99aa00aa99aa000000000000000000d1111d00d1111d00424242004242420000000000000000000000000
0000000000022000000220000777000000000100000aa000000aa000000000000000000000dddd0000dddd000042420000424200000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000a00000000a000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000077700000700000a00a0a0000a0a00a000000000000000000000000000000000000000000000000000000000000000000770000
0000000000088000000cc0000777770007770000a0aa0a0aa0a0aa0a000000000000000000000000000000000dd0000000000000000000000000000009970000
00000000088888800cccccc00171770001177000aaa9a9aaaa9a9aaa0000000000000000011100000000000099d7770000076000000000000000000000077770
00000000088aa8800ccaacc00717770000017770aa9999aaaa9999aa000000000000000000111000011100000277724002466240700000000000000704477740
00000000088888800cccccc007777000000017100aa99aa00aa99aa000000000000000000d1111d00d111d000424242004242420700000000000000704444440
0000000000088000000cc0000777000000000100000aa000000aa000000000000000000000dddd0000ddd0000042420000424200700000000000000700444400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777700000000777700000000
00000000000000000a90000000000000000ff000000ff000000ff000000ff0000000000009000200000000000000000000000000000000000000000066777667
00aaaa00bbb30000a4490000000000000ffffff00ffffff00ffffff00ffffff00000000097909220000000000000000000000000000000000000000077666777
0a94494000b033009409000000000000ffffffffffffffffffffffffffffffff0000000009002290000000000000000000000000000000000000000077777777
0a499a4000b0088009aa900000077000effffff4effffff4effffff4effffff40000000000022222000000000000000000000000000000004444000077777777
0a499a40088087820000a900077cc7701eeff444eeeff441eeeff444eeeff4440000000000832921000000000000000000000000000000004444000077777777
0a9aa9408782882200000a907cc77cc7ee1e4444eeee4144eeee4444eeee44440000000033338811000000000000000000000000000000004444000077777777
0044440088220220000099a9077cc7700eee44400eee44400eee44400eee444000000000bb331111000000000000000000000000000000000440000070707070
00000000022000000000090000077000002e4400002e4200002e4200002e420000000000b8b11100000000000000000000000000000000000440000070707070
00000000bbb300000a90000000000000008228000082220000822200008228000000000008b1113300000000555005000b0bb0b0000000000220022055500500
000aa00000b03300a44900000000000000882f0000f8220000f8220000882f00000000000822123000000000000055500bb00bb0000000000500000000005550
000aa00000b0088094090000000000000088220000882200008822000088220000000000808212200000000050500000000bb000000000005000050050500000
000990000880878209aa9000000cc0000008200000082000000820000008200000000000032223330000000050050020bb0bb0bb000000000555000050050020
00099000878288220000a9000cc77cc00000000000000000000000000000000000000000022223130000000000000020bb0bb0bb000000000000055000000020
000440008822022000000a90c77cc77c000000000000000000000000000000000000000033222111000000005500000000bbb000000000000050000055000000
0004400002200000000099a90cc77cc00000000000000000000000000000000000000000000231310000000000500020bb000bb0000000000050555000500020
000000000000000000000900000cc0000000000000000000000000000000000000000000000000000000000050055020bb000bb0000000000000000050055020
99440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066777667
94994400000000000040000000000000000ff000000ff000000ff000000ff0000000000009000200000000000000000000000000000000000000000078888877
999499440000000000444000000000000ffffff00ffffff00ffffff00ffffff00000000000009220000000000000000000000000000000000000000078888877
94994494000000000044440000000000ffffffffffffffffffffffffffffffff0000000000002290000000000000000000000000000000000000000078888877
99449994000000000044440000000000effffff4effffff4effffff4effffff40000000000022222000000000000000000000000000000000000000078888877
009994940000000000444400000000001eeff444eeeff441eeeff444eeeff4440000000000832921000000000000000000000000000000000000000077777777
00049994000000000044440000000000ee1e4444eeee4144eeee4444eeee44440000000033338811000000000000000000000000000000000000000007070707
00044094000000000044a400000000000eee44400eee44400eee44400eee444000000000bb331111000000000000000000000000000000000000000007070707
00094000000000000044440000000000008e4800008e4200008e4200008e480000000000b8b11100000000000000000000033300f6c667ff445454400b0bb0b0
0000000000000000004444000000000000882f0000f8220000f8220000882f000000000088811130000000000000000003300033f0c070ff444544400bb00bb0
000000000000000000044400000000000088220000882200008822000088220000000000032213330000000000000000033ccc330fffff0000444000000bb000
0000000000000000000004000000000000082000000820000008200000082000000000000022231300000000000000000cccccccffffffff44444444bb0bb0bb
0000000000000000000000000000000000000000000000000000000000000000000000000222211000000000000000000cccccccffffffff44444444bb0bb0bb
00000000000000000000000000000000000000000000000000000000000000000000000033222111000000000000000004400044f88888ffcccccccc00bbb000
00000000000000000000000000000000000000000000000000000000000000000000000000023131000000000000000004400044ff8880ffcc0000ccbb000bb0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400044ff0800ffcc0000ccbb000bb0
000000000000000000000000000000000000000000000000ddddddddddddddddddddddddd7777777d777777777777ddd7777777777777ddd7777777700000000
000000000000000000000000000000000000000000000000d77777777777777777777dddd7777777d777777777777ddd7777777777777ddd7777777700000000
000000000000000000000000000000000000000000000000d77777777777777777777dddd7777777d777777777777ddd7777777777777ddd7777777700000000
000000000000000000000000000000000000000000000000d77777777777777777777dddd7777777d777777777777ddd7777777777777ddd7777777700000000
000000000000000000000000000000000000000000000000d77777777777777777777dddd7777777d777777777777ddd7777777777777ddd7777777700000000
000000000000000000000000000000000000000000000000d77777777777777777777dddddddddddd777777777777ddddddddddddddddddd7777777700000000
000000000000000000000000000000000000000000000000d77777777777777777777dddddddddddd777777777777ddddddddddddddddddd7777777700000000
000000000000000000000000000000000000000000000000d77777777777777777777dddddddddddd777777777777ddddddddddddddddddd7777777700000000
0000000000000000000000000000000000000000099999991111111122222222222222228888888888888888999999999999999999999999aaaaaaaa22200222
0000000000000000000000000000000000000000090090090000000011111111222222222222222288888888888888889999999999999999aaaaaaaa22200222
00000000000000000000000000000000000000000900900900000000111111112222222222222222888888888888888899999999aaaaaaaaaaaaaaaa22200222
0000000000000000000000000000000000000000099999991111111122222222222222228888888888888888999999999999999999999999aaaaaaaa22222222
0000000000000000000000000000000000000000094444491111111122222222222222228888888888888888999999999999999999999999aaaaaaaa22222222
00000000000000000000000000000000000000000944494900000000111111112222222222222222888888888888888899999999aaaaaaaaaaaaaaaa22222222
0000000000000000000000000000000000000000094444491111111122222222222222228888888888888888999999999999999999999999aaaaaaaa22222222
00000000000000000000000000000000000000000999999900000000111111112222222222222222888888888888888899999999aaaaaaaaaaaaaaaa00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000200033bb0000000070000000000000006666666600000000
00000000000000000000000000000000000000000999999900000000000000000000000000000000210000330000000000000000000000006666666602220000
00000000000000000000000000000000000000000900900900000000444444440000000000000000220000000000000000000000000000006666666620002000
00000000000000000000000000000000000000000900900900000000404040400000000000000000222100000000000000000000000700006666666600000000
00000000000000000000000000000000000000000999999900000000400404040000000000000000222210000000000000000000000000006666666600000000
000000000000000000000000000000000000000009999999000000004440444400000000000000003bb322000000000000000000000000006666666600000000
00000000000000000000000000000000000000000999999900000000000440000000000000000000bbbbb2000000000000000000000000006666666600000000
00000000000000000000000000000000000000000999999900000000000440000000000000000000b1b1b200000000000000000d000000006666666600000000
00000000000000000000000000000000000000000000000000888800006ff6000000002222211112231313200000000011111111111000001111111100000000
0000000000000000000000000000000000000000000000000899998000f66f0000000000221111222211120000000000000000000000000011111111cc000000
00000000000000000000000000000000000000000000000008900980ffffffff00000002222212222211120000000000000000000000000011111111cc000000
00000000000000000000000000000000000000000000000000888800ff9999ff00001112222112222222211000000000000000000000000011111111cc000000
00000000000000000000000000000000000000000000000000bbbb009f9999f900112222222122222222211110000000000000000000000011111111cc000000
0000000000000000000000000000000000000000000000000b0bb0b09f9999f901111122222122222222222111000000000000000000000011111111cc000000
000000000000000000000000000000000000000000000000b00bb00b9f9999f900111113132123131322111110000000000000000000000011111111cc000000
000000000000000000000000000000000000000000000000000bb0009f9999f900001111111111111111111000000000000000000000000011111111cc000000
00011122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004412220000000000000000000000000000000000000000000044440000000440110000000440044444444444444000004444444444404444444444444440
00000411229000000000000000333000000000000000000000009999999900000991001000000990099999999999999000999999999999909999999999999990
00000011222900000000000003bbb3bb011100000000000000099900009990000991001000000990099011111111110009990011111111000000000990111110
0000001112999000000000003b33bbbbb33110010000000000aa00011100aa000aa1010000000aa00aa01000000000100aa01111000000100000000aa0110001
0000000119999900000000003b33b388bbb310010000000000aa00110000aa000aa1000000000aa00aa01100000100100aa01100000100100000000aa0110001
00000001112299900000003bbbb38867883b30010000000007700110000007700771000000000770077011000000110007700000000011000000000770011010
000000041112292200003bbbb38867076788b3010000000007701100000007700771000000000770077000000000000000777700000000000000000770011000
000000444111111123bbbbb388661722376767190000111107701000000007700771000000000770077777770000000000007777777700000000000770110000
00000044111111333bbbb38866162233886707191001144117701010000007700771000000110770077000000000110000110000007777000000000770110000
00000014113bbbbbbbb38867162233886707011911114aa410aa100100a0aa000aa0110011110aa00aa0110000010010010010000000aaa00000000aa0011000
0000001113b22211b3886717223388670701114a41114aa410aa0110000aaa0000aa11111100aa000aa01100000000100100000011110aa00000000aa0011000
000000113b28882138671711238867070001449a9441144110099900009990000099901100099900099011111111110000111111110099900000000990110000
00000013128882131117111238670700001144979441111100009999999909000009999099999000099999999999999009999999999999000000000990110000
00000003128221131111112367070000111499777994111100000099990000900000099999900000099999999999999009999999999900000000000990011000
00000003112111331111112307000111999aa77777aa999111100000000000000000000000000000000000000000000000000000000000000000000000000000
0000000031113bb31111112300000000111499777994100000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003bbbbbb31111112387070001411144979441100009901110001109900000009999000000099999999999000009900110000000000999999999000000
0000000003bbbbb311178888ee8807001001449a9441000009910001010019900000999999990000099000000099990009900110000000000999999999990000
000000000013bbbb3867171288ee67070001114a4111000009910001000019900009990000999000099011111100999009901100000000000990111111099000
0000000011113bbbb38867171188ee6707000119110011000aa1001000001aa000aa00000110aa000aa1000000110aa00aa01100000000000aa100001100aa00
0000000011111333bbb38867171188ee770700191001441000aa10000001aa0000aa00001001aa000aa1001000110aa00aa01100000000000aa100100110aa00
00000011111111113bbbb38867171188ee6707191001441000771001100177000770000001010770077011000110077007700110000000000770110001100770
0000111211111111113bbbb38867171187ee67010000110000770101101077000770000000010770077000000000770007700110000000000770000000110770
0000122222122221111103bbb38867176788eb010000000000070110011070000770000000110770077777777777700007701100000000000770000000110770
00023bb33222211111110003bbb38867883b8e010000000000077007700770000770000001100770077000000007700007701100000011000770110001100770
0002bbbbb2221111122110003bbbb3883bbb38e100000000000aa0aaaa0aa00000aa00001100aa000aa11111110aa0000aa00110000100100aa100100110aa00
0002b1b1b221111111122000003bbbbbbb30008eee0000000000aaa00aaa000000aa00111000aa000aa110000010aa000aa00110000000100aa100001100aa00
00023131322111111111220000003bbb330000080000000000009990099900000009990000999000099000000010990009901111111111000990111111099000
000021112221122113bb322000000033000000080000000000009990099900000000999999990000099000001001099009999999999999900999999999990000
00002111221122221bbbbb2000000000000000000000000000000400004000000000004444000000044000000111044004444444444444400444444444000000
00000211211221121b1b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000c588000000abababababababababababababababab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c4c5c6c7c8c9cacbcccdcecfababacababababababab86878788abab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d4d5d6d7d8d9dadbdcdddedfabababababababababab8a8e8e8babab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e2e3e4e5e6e7e8e9eaebecedeeefadababababababababab8a8e8e8babab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1f2f3f4f5f6f7f8f9fafbfcfdfeffababababababadababab898c8c8dacab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b8b9babb000000000000000000000000abababababababababababababababab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
87bcbd87878787000000000000000000abababababababababababababababab000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ababababadababababababababababad000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000096969696969696969696969696969696000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000bebebebebebebebebebebebebebebebe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000097979797979797979797979797979797000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000098989898989898989898989898989898000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000099999999999999999999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000009a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000009b9b9b9b9b9b9b9b9b9b9b9b9b9b9b9b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000009c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000009c9c9c9c9c9c9c9c9c9c9c9c9c9c9c9c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000010040100a0301f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001067500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001327511275102721027210272102721027210275000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001367224003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c47300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

