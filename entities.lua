-- entities

entity=class:extend({
	-- class
	pool={},

	extend=function(_ENV,tbl)
		tbl=class.extend(_ENV,tbl)
		tbl.pool = {}
		return tbl
	end,

	each=function(_ENV,method,...)
		for e in all(pool) do
			if (e[method]) e[method](e,...)
		end
	end,

	-- instance
	x=0,
	y=0,

	w=8,
	h=8,

	init=function(_ENV)
		add(entity.pool,_ENV)
		if pool != entity.pool then
			add(pool,_ENV)
		end
	end,

	detect=function(_ENV,other,callback)
		if collide(_ENV,other) then
			callback(_ENV)
		end
	end,

	collide=function(_ENV,other)
		return x<other.x+other.w and
			x+w>other.x and
			y<other.y+other.h and
			h+y>other.y
	end,

	destroy=function(_ENV)
		del(entity.pool,_ENV)
		if pool != entity.pool then
			del(pool,_ENV)
		end
	end
})

-- person
person=entity:extend({
	x=60,
	y=60,
	w=7,
	h=5,

	dx=0,
	dy=0,

	update=function(_ENV)
		dx,dy=0,0

		if (btn(⬆️)) dy-=1
		if (btn(⬇️)) dy+=1
		if (btn(⬅️)) dx-=1
		if (btn(➡️)) dx+=1

		if dx!=0 or dy !=0 then
			-- normalize movement
			local a=atan2(dx,dy)
			x+=cos(a)
			y+=sin(a)

			-- spawn dust each 3/10 sec
			if (t()*10)\1%3==0 then
				dust({
					x=x+rnd(3),
					y=y+4,
					frames=18+rnd(4),
				})
			end
		end

		-- restrict movement
		x=mid(7,x,114)
		y=mid(15,y,116)
	end,

	draw=function(_ENV)
		prints("😐",x,y,7)
	end,
})

-- heart
heart=entity:extend({
	w=5,
	h=5,
	pool={},

	draw=function(_ENV)
		print("♥",x,y,8)
	end,

	create_spark=function(_ENV)
		spark({
			x=x-2+rnd(9),
			y=y-2+rnd(4),
			frames=4+rnd(4),
		})
	end
})

-- particle
particle=entity:extend({
	frame=0,
	frames=10,
	rad=1,
	clr=5,
	sx=0,
	sy=0,

	update=function(_ENV)
		x+=sx
		y+=sy
		frame+=1

		if frame>=frames then
			destroy(_ENV)
		end
	end,

	draw=function(_ENV)
		local r=(1-frame/frames)*rad
		circfill(x,y,r,clr)
	end
})

dust=particle:extend({
	rad=3,
	sy=-.25
})

spark=particle:extend({
	clr=10,
	sy=-.5,
})