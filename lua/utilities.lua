dir = {
	card = {
		{ x = 0, y = -1 },
		{ x = 1, y = 0 },
		{ x = 0, y = 1 },
		{ x = -1, y = 0 }
	},
	all = {
		{ x = 0, y = -1 },
		{ x = 1, y = -1 },
		{ x = 1, y = 0 },
		{ x = 1, y = 1 },
		{ x = 0, y = 1 },
		{ x = -1, y = 1 },
		{ x = -1, y = 0 },
		{ x = -1, y = -1 }
	}
}

-- one in n
function one_in(n)
	return rnd(n) < 1
end

-- Returns the distance between this Rect and other. This is the minimum
-- length that a corridor would have to be to go from one Rect to the other.
-- If the two Rects are adjacent, returns zero. If they overlap, returns -1.
function dst_to(r1, r2)
	local v, h
	if r1.y >= r2.y + r2.h then
		v = r1.y - (r2.y + r2.h)
	elseif r1.y + r1.h <= r2.y then
		v = r2.y - (r1.y + r1.h)
	else
		v = -1
	end

	if r1.x >= r2.x + r2.w then
		h = r1.x - (r2.x + r2.w)
	elseif r1.x + r1.w <= r2.x then
		h = r2.x - (r1.x + r1.w)
	else
		h = -1
	end

	if v == -1 and h == -1 then
		return -1
	elseif v == -1 then
		return h
	elseif h == -1 then
		return v
	else
		return h + v
	end
end

-- Returns the distance between two points.
function dst_btw(p1, p2)
	return flr(sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2))
end

-- overlaps
function rect_overlaps(r, r2)
	return r.x < r2.x + r2.w and r.x + r.w > r2.x and r.y < r2.y + r2.h and r.y + r.h > r2.y
end

function get_all_posn(r)
	-- return posn of all tiles in r
	local posn = {}
	for y = r.y, r.y + r.h - 1 do
		for x = r.x, r.x + r.w - 1 do
			add(posn, { x = x, y = y })
		end
	end
	return posn
end

function int_rnd(n)
	return flr(rnd(n))
end

function shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = int_rnd(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

--- Creates a 2D array with specified dimensions and initializes it with a given val.
-- @param len1 The number of rows in the 2D array.
-- @param len2 The number of columns in the 2D array.
-- @param val The val to initialize each element of the array with. Defaults to nil if not provided.
-- @return A 2D array with dimensions len1 x len2, initialized with the specified val.
function mk2darr(len1, len2, val)
	local arr = {}
	for i = 1, len1 do
		arr[i] = {}
		for j = 1, len2 do
			arr[i][j] = val or nil
		end
	end
	return arr
end

function foreach_2darr(arr, clb)
	for x = 1, #arr do
		for y = 1, #arr[x] do
			clb(x, y)
		end
	end
end

function get_rnd_item(arr)
	return arr[int_rnd(#arr) + 1]
end

function contains(tbl, val)
	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
	return false
end

function keys(tbl)
	local keys = {}
	for k, _ in pairs(tbl) do
		add(keys, k)
	end
	return keys
end

function do_map(tbl, func)
	local newtbl = {}
	for k, v in pairs(tbl) do
		newtbl[k] = func(v)
	end
	return newtbl
end

function rmv_where(tbl, func)
	for i = #tbl, 1, -1 do
		if func(tbl[i]) then
			deli(tbl, i)
		end
	end
end

function rmv_dup(tbl)
	local set, newtbl = {}, {}
	for _, v in pairs(tbl) do
		if not set[v] then
			add(newtbl, v)
			set[v] = true
		end
	end
	return newtbl
end

function slice(tbl, start, finish)
	local newtbl = {}
	for i = start, finish or #tbl do
		add(newtbl, tbl[i])
	end
	return newtbl
end
