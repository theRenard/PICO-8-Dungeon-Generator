-- utilities
global = _ENV
noop = function() end

-- palette
poke(0x5f2e, 1)
pal(0, 129, 1)

-- font
poke4(0x5600, unpack(split "0x9.0908,0x.0100,0x1100,0x4620.2100,0x4110.1674,0x7774.7711,0,0x111.7700,0x.0001,0x14.0740,0x1700.0700,0x715.1000,0x.0004,0x110.0010,0x1101.0010,0x105.0011,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x3f3f.3f3f,0x3f3f.3f3f,0x3f3f.3f00,0x3f.3f3f,0x333f.3f00,0x3f.3f33,0xc33.3300,0x33.330c,0x33.3300,0x33.3300,0x3333.3300,0x33.3333,0xfffc.f0c0,0xc0f0.fcff,0xff3f.0f03,0x30f.3fff,0x303.0f0f,0,0,0x7878.6060,0x3c7e.e7c3,0x187e.187e,0xc00,0x.000c,0,0x607.0303,0,0xf0f.0f0f,0x1b1b.1b1b,0,0x1f1b.1f0e,0x.000e,0,0,0x1e3f.3f3f,0xc0c.001e,0x1b1b.1b1b,0,0x66ff.ff66,0x66ff.ff66,0x3f13.7f7e,0x3f7f.647e,0x3873.e7c6,0x63e7.ce1c,0x3f33.3f1e,0x3e7f.e3fe,0x307.0606,0,0x60e.3c38,0x383c.0e06,0x3038.1e0e,0xe1e.3830,0xe1f.1b00,0x.1b1f,0x3f0c.0c00,0xc.0c3f,0,0x307.0606,0x3f00,0x.003f,0,0x303,0x60e.0c0c,0x303.0706,0x6b63.7f3e,0x3e7f.636b,0x181f.1f18,0x7f7f.1818,0x7e60.7f3f,0x7f7f.033f,0x7c60.7f3f,0x3f7f.603c,0x676e.7c78,0x6060.7f7f,0x3f03.7f7f,0x3f7f.607f,0x3f03.7f7e,0x3e7f.637f,0x3870.7f7f,0x307.0e1c,0x3e63.7f3e,0x3e7f.637f,0x7f63.7f3e,0x3f7f.607e,0x.0303,0x303,0x.0606,0x307.0606,0x1f7c.f0c0,0xc0f0.7c1f,0xff.ff00,0xff.ff00,0xf83e.0f03,0x30f.3ef8,0x7c60.7f3f,0xc0c.003c,0xfbdb.ff7e,0xfeff.03fb,0x7e60.7e3e,0x7e7f.637f,0x3f03.0303,0x3f7f.637f,0x637f.3e00,0x3e7f.6303,0x7e60.6060,0x7e7f.637f,0x7f63.7f3e,0x7e7f.037f,0x1f66.7e3c,0x606.061f,0x3f33.7f7e,0x1f3f.381e,0x3f03.0303,0x6363.637f,0x300.0303,0x607.0303,0x3000.3030,0x1e3f.3330,0x3b33.0303,0x333b.1f1f,0x303.0303,0x607.0303,0xffff.6600,0xc3c3.c3db,0x7f3f.0300,0x6363.6363,0x637f.3e00,0x3e7f.6363,0x637f.3f00,0x303.3f7f,0x637f.7e00,0x6060.7e7f,0x3f1f.0300,0x303.0333,0x77f.7e00,0x3f7f.703e,0x3f3f.0606,0x3c3e.0606,0x6363.6300,0x3e7f.6363,0x3f33.3300,0xc0c.1e1e,0xc3c3.c300,0x66ff.ffdb,0x3e77.6300,0x6377.3e1c,0x7f63.6300,0x3f7f.607e,0x387f.7f00,0x7f7f.0e1c,0x606.3e3e,0x3e3e.0606,0x607.0303,0xc0c.0e06,0x3030.3e3e,0x3e3e.3030,0x333f.1e0c,0,0,0xffff,0x607.0303,0,0x7f63.7f3e,0x6363.637f,0x3f63.7f3f,0x3f7f.637f,0x363.7f3e,0x3e7f.6303,0x6363.7f3f,0x3f7f.6363,0x3f03.7f7f,0x7f7f.033f,0x3f03.7f7f,0x303.033f,0x7b03.7f7e,0x3e7f.637b,0x7f63.6363,0x6363.637f,0x1818.ffff,0xffff.1818,0x3030.7e7e,0x1e3f.3330,0x1f3b.7363,0x6373.3b1f,0x303.0303,0x7f7f.0303,0xffff.6666,0xc3c3.dbdb,0xdfcf.c7c3,0xc3e3.f3fb,0x6363.7f3e,0x3e7f.6363,0x6363.7f3f,0x303.3f7f,0x6363.7f3e,0xfeff.7363,0x6363.7f3f,0x6373.3f7f,0x3f03.7f7e,0x3f7f.607e,0x1818.ffff,0x1818.1818,0x6363.6363,0x3e7f.6363,0x66e7.c3c3,0x183c.3c7e,0xdbdb.c3c3,0x6666.ffff,0x3c7e.e7c3,0xc3e7.7e3c,0x7ee7.c3c3,0x1818.183c,0x3870.7f7f,0x7f7f.0e1c,0xe0c.3c38,0x383c.0c0e,0x606.0606,0x606.0606,0x3818.1e0e,0xe1e.1838,0x73fb.dfce,0,0x1f1b.1f1f,0x.001f,0xffff.ffff,0xffff.ffff,0xcccc.3333,0xcccc.3333,0x99ff.ffc3,0x7ec3.e7ff,0xc3c3.ff7e,0x7eff.e7e7,0x3030.0303,0x3030.0303,0xfcfc.0c0c,0x3030.3f3f,0x4f4f.3e00,0x3e7f.7f7f,0x7f7f.3600,0x81c.3e7f,0xe7ff.ff7e,0x7eff.ffe7,0x7f1c.1c00,0x363e.1c7f,0xff7e.3c18,0x6666.7eff,0xc3cf.ff7e,0x7eff.cfc3,0x9999.ff7e,0x7ec3.81ff,0x1818.7838,0xe1f.1f1e,0x99c3.ff7e,0x7eff.c399,0x3f1e.0c00,0xc.1e3f,0x3300,0x.0033,0xc3f3.ff7e,0x7eff.f3c3,0x7f1c.0800,0x6377.3e7f,0x1e3f.3f00,0x3f3f.1e0c,0xe7e7.ff7e,0x7eff.c3c3,0x40e.1f1b,0x2070.f8d8,0xeec7.8301,0x10.387c,0xe799.997e,0x7e99.99e7,0x.ffff,0x.ffff,0x3333.3333,0x3333.3333,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x99ff.8100,0x7ec3.81ff,0xbdff.8100,0x7ec3.bdff,0x99ff.8100,0x7ec3.e7ff,0x9999.ff81,0x7ec3.81ff,0x99bd.ff81,0x7ec3.81ff,0x497f.4100,0x3e63.417f,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x99ff.7e00,0x7ec3.81ff,0x99ff.7e00,0x7ec3.bdff,0x99ff.7e00,0x7eff.81ff,0x99bd.ff7e,0x7ec3.81ff,0x99db.ff7e,0x7ec3.81ff,0x497f.3e00,0x3e63.417f,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x4058.1840,0x545c.5d7e,0x4018.5800,0x141c.5d7e,0x4058.5840,0x145c.5dfe,0x4058.5800,0x141c.5dfe,0x7777.3e00,0x3e77.6341,0x6377.3e00,0x3e77.7741,0x6777.3e00,0x3e77.6741,0x7377.3e00,0x3e77.7341,0x6b5d.3e00,0x3e5d.6b77,0x7f7f.3e00,0x3e7f.7f77,0x637f.3e00,0x3e7f.6349,0xffff,0xffff,0xcccc.cccc,0xcccc.cccc,0,0,0,0,0,0,0x6f3e.1c00,0x1c3e.7f7f"))

-- print title
function print_title(str, y, clr)
	poke(0x5f58, 0x81)
	local x = 64 - #str * 8 / 2
	print(str, x, y + 2, 13)
	print(str, x, y, clr)
	poke(0x5f58, 0x01)
end

-- print centered
function printc(str, y, clr)
	local x = 64 - #str * 4 / 2
	print(str, x, y, clr)
end

-- print shadow
function prints(str, x, y, clr)
	print(str, x + 1, y + 1, 0)
	print(str, x, y, clr)
end

-- left pad
function pad(str, len, char)
	str = tostr(str)
	char = char or "0"
	if (#str == len) return str
	return char .. pad(str, len - 1)
end

-- one in n
function oneIn(n)
	return rnd(n) < 1
end

-- Returns the distance between this Rect and other. This is the minimum
-- length that a corridor would have to be to go from one Rect to the other.
-- If the two Rects are adjacent, returns zero. If they overlap, returns -1.
function distanceTo(room1, room2)
	if room1.y >= (room2.y + room2.h) then
		vertical = room1.y - (room2.y + room2.h)
	elseif (room1.y + room1.h) <= room2.y then
		vertical = room2.y - (room1.y + room1.h)
	else
		vertical = -1
	end

	local horizontal = nil
	if room1.x >= (room2.x + room2.w) then
		horizontal = room1.x - (room2.x + room2.w)
	elseif (room1.x + room1.w) <= room2.x then
		horizontal = room2.x - (room1.x + room1.w)
	else
		horizontal = -1
	end

	if vertical == -1 and horizontal == -1 then
		return -1
	elseif vertical == -1 then
		return horizontal
	elseif horizontal == -1 then
		return vertical
	else
		return horizontal + vertical
	end
end

-- Returns the distance between two points.
function distanceBetween(p1, p2)
	return flr(sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2))
end

-- overlaps
function rectOverlaps(rect, rect2)
	return rect.x < rect2.x + rect2.w
			and rect.x + rect.w > rect2.x
			and rect.y < rect2.y + rect2.h
			and rect.y + rect.h > rect2.y
end

function getAllPositions(rect)
	-- return positions of all tiles in rect
	local positions = {}
	for y = rect.y, rect.y + rect.h - 1 do
		for x = rect.x, rect.x + rect.w - 1 do
			add(positions, { x = x, y = y })
		end
	end
	return positions
end

-- contains
function vecContains(vectors, vec)
	if vec == nil then
		return false
	end
	for i = 1, #vectors do
		if vectors[i] == nil then
			return false
		end
		if vectors[i].x == vec.x and vectors[i].y == vec.y then
			return true
		end
	end
	return false
end

function intRnd(n)
	return flr(rnd(n))
end

function isNotEmpty(arr)
	for i = 1, #arr do
		if arr[i] ~= nil then
			return true
		end
	end
	return false
end

function vecSumAndMlt(vec1, vec2, scalar)
	local scalar = scalar or 1
	if vec1 == nil then
		return { x = vec2.x * scalar, y = vec2.y * scalar }
	elseif vec2 == nil then
		return { x = vec1.x * scalar, y = vec1.y * scalar }
	else
		return { x = vec1.x + (vec2.x * scalar), y = vec1.y + (vec2.y  * scalar) }
	end
end

Direction = {
	CARDINAL = {
		{ x = 0, y = -1 },
		{ x = 1, y = 0 },
		{ x = 0, y = 1 },
		{ x = -1, y = 0 }
	},
	ALL = {
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

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = intRnd(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

--- Creates a 2D array with specified dimensions and initializes it with a given value.
-- @param len1 The number of rows in the 2D array.
-- @param len2 The number of columns in the 2D array.
-- @param val The value to initialize each element of the array with. Defaults to nil if not provided.
-- @return A 2D array with dimensions len1 x len2, initialized with the specified value.
function create2dArray(len1, len2, val)
	local arr = {}
	for i = 0, len1 do
			arr[i] = {}
			for j = 0, len2 do
					arr[i][j] = val or nil
			end
	end
	return arr
end

function getRandomItem(arr)
	return arr[intRnd(#arr) + 1]
end

function oneIn(n)
	return rnd(n) < 1
end

function contains(table, value)
	for _, v in pairs(table) do
			if v == value then
					return true
			end
	end
	return false
end

function keys(table)
	local keys = {}
	for k, _ in pairs(table) do
			add(keys, k)
	end
	return keys
end

function toList(table)
	local list = {}
	for _, v in pairs(table) do
			add(list, v)
	end
	return list
end

function map(table, func)
	local newTable = {}
	for k, v in pairs(table) do
			newTable[k] = func(v)
	end
	return newTable
end

function removeWhere(table, func)
	for i = #table, 1, -1 do
			if func(table[i]) then
					del(table, i)
			end
	end
end

function toSet(table)
	local set = {}
	for _, v in pairs(table) do
			set[v] = true
	end
	return set
end

function toVec(str)
	local x = split(str, "_")[1]
	local y = split(str, "_")[2]
	return { x = x, y = y }
end

function toStr(x, y)
	return x .. "_" .. y
end

function slice(table, start, finish)
	local newTable = {}
	for i = start, finish or #table do
			add(newTable, table[i])
	end
	return newTable
end

function forEachArr2D(arr, callback)
	for x = 0, #arr do
			for y = 0, #arr[x] do
					callback(x, y)
			end
	end
end
