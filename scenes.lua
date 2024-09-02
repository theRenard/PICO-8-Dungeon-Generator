-- scenes

scene=class:extend({
	current=nil,

	update=noop,
	draw=noop,

	destroy=function(_ENV)
		entity:each("destroy")
	end,

	load=function(_ENV,scn)
		if current != scn then
			if (current) current:destroy()
			current=scn()
		end
	end
})

title_scene=scene:extend({
	init=function(_ENV)
		local lvl=stage({ w=64, h=64 })
		local gen = generator()
		gen:generate(lvl)
		map();
	end,

	update=function(_ENV)
		entity:each("update")

		if btnp(❎) then
			-- scene:load(game_scene)
		end

		-- spawn spark each 4/10 sec
		-- if (t()*10)\1%4==0 then
		-- 	title_heart:create_spark()
		-- end
	end,

	draw=function()
		-- draw entities
		entity:each("draw")

		-- title
		-- print_title("heartseeker",32,7)

		-- -- instructions
		-- printc("collect all the hearts",60,6)
		-- printc("before time runs out!",68,6)

		-- -- prompt
		-- printc("❎ start game",96,7)
	end,
})

-- game_scene=scene:extend({
-- 	init=function(_ENV)
-- 		global.score=0
-- 		global.timer=time_limit*30

-- 		-- spawn player
-- 		player=person()

-- 		-- spawn hearts
-- 		while #heart.pool<heart_count do
-- 			local obj=heart({
-- 				x=8+rnd(107),
-- 				y=16+rnd(99)
-- 			})

-- 			-- destroy if colliding
-- 			obj:detect(player,function()
-- 				obj:destroy()
-- 			end)
-- 		end
-- 	end,

-- 	update=function(_ENV)
-- 		entity:each("update")

-- 		-- detect heart pickup
-- 		heart:each("detect",player,function(obj)
-- 			sfx(0)
-- 			obj:destroy()
-- 			global.score+=1

-- 			for i=1,3 do
-- 				obj:create_spark()
-- 			end
-- 		end)

-- 		-- check win state
-- 		if #heart.pool==0 then
-- 			scene:load(win_scene)
-- 		end

-- 		-- check game over state
-- 		if timer==0 then
-- 			scene:load(lose_scene)
-- 		end

-- 		global.timer=max(0,timer-1)
-- 	end,

-- 	draw=function(_ENV)
-- 		add(entity.pool,del(entity.pool,player))
-- 		entity:each("draw")
-- 	end,
-- })

-- win_scene=scene:extend({
-- 	init=function(_ENV)
-- 		sfx(1)
-- 	end,

-- 	update=function(_ENV)
-- 		if btnp(❎) then
-- 			scene:load(game_scene)
-- 		end
-- 	end,

-- 	draw=function(_ENV)
-- 		print_title("you win!",32,7)
-- 		printc("❎ play again",96,7)
-- 	end
-- })

-- lose_scene=scene:extend({
-- 	init=function(_ENV)
-- 		sfx(2)
-- 	end,

-- 	update=function(_ENV)
-- 		if btnp(❎) then
-- 			scene:load(game_scene)
-- 		end
-- 	end,

-- 	draw=function(_ENV)
-- 		print_title("times up!",32,7)
-- 		printc("❎ play again",96,7)
-- 	end
-- })