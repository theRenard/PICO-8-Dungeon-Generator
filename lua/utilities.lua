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

function intRnd(n)
	return flr(rnd(n))
end

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
function create2DArr(len1, len2, val)
	local arr = {}
	for i = 1, len1 do
		arr[i] = {}
		for j = 1, len2 do
			arr[i][j] = val or nil
		end
	end
	return arr
end

function forEachArr2D(arr, callback)
	for x = 1, #arr do
		for y = 1, #arr[x] do
			callback(x, y)
		end
	end
end

function getRandomItem(arr)
	return arr[intRnd(#arr) + 1]
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

function domap(table, func)
	local newTable = {}
	for k, v in pairs(table) do
		newTable[k] = func(v)
	end
	return newTable
end

function removeWhere(table, func)
	for i = #table, 1, -1 do
		if func(table[i]) then
			deli(table, i)
		end
	end
end

function removeDup(table)
	local set = {}
	local newTable = {}
	for _, v in pairs(table) do
		if not set[v] then
			add(newTable, v)
			set[v] = true
		end
	end
	return newTable
end

function slice(table, start, finish)
	local newTable = {}
	for i = start, finish or #table do
		add(newTable, table[i])
	end
	return newTable
end


