cls(0)

local method = 3 -- chose_random, chose_oldest, chose_newest
local dungeonWidth = 128
local dungeonHeight = 128
local dungeon = {}
local bouldersRatio = 0
local wallTile = 0
local emptyTile = 7
local boulderTile = 4
local maxRemovableDeadEnds = 2000
local numRoomTries = 1000
local roomExtraSize = 4
local drawStep = true

function doForAllTiles(callback)
    for x = 0, dungeonWidth do
        for y = 0, dungeonHeight do
            callback(x, y)
        end
    end
end

function initDungeon()
    for x = 0, dungeonWidth do
        dungeon[x] = {}
        for y = 0, dungeonHeight do
            dungeon[x][y] = wallTile
            dungeon[x][y] = rnd() > bouldersRatio and wallTile or boulderTile
        end
    end
    rectfill(0, 0, dungeonWidth, dungeonHeight, 13)
end

function choseIndex(ceil)
    if method == 1 then
        return flr(rnd(ceil)) + 1
    elseif method == 2 then
        return 1
    elseif method == 3 then
        return ceil
    end
end

function isInBounds(tile, padding)
    local padding = padding or 1
    return tile.x <= dungeonWidth - padding and tile.y <= dungeonHeight - padding and tile.x > 0 and tile.y > 0
end

function isWall(tile)
    return dungeon[tile.x][tile.y] == wallTile or dungeon[tile.x][tile.y] == boulderTile
end

function isPath(tile)
    return dungeon[tile.x][tile.y] == emptyTile
end

function canCarve(tile)
    return isInBounds(tile) and isWall(tile)
end

function growMaze(startTile)
    local tiles = {}

    -- Step #4 add the random tile to the list of tiles.

    carve(startTile)
    add(tiles, startTile)

    -- Step #5 while the list of tiles is not empty, do the following:
    while #tiles > 0 do
        -- Step #6 choose a random tile from the list of tiles.
        local index = choseIndex(#tiles)
        local currentTile = tiles[index]
        -- Step #7 create a list of unvisited neighbors of the current tile.
        for _, direction in pairs(shuffle(Direction.CARDINAL)) do
            local neighborTile = {
                x = currentTile.x + direction.x,
                y = currentTile.y + direction.y
            }
            local nextNeighborTile = {
                x = currentTile.x + direction.x * 2,
                y = currentTile.y + direction.y * 2
            }
            if canCarve(neighborTile) and canCarve(nextNeighborTile) then
                carve(neighborTile)
                carve(nextNeighborTile)
                add(tiles, nextNeighborTile)
                if drawStep then drawDungeon() end
                index = nil
                break
            end
        end
        if index then
            del(tiles, currentTile)
        end
    end
end

function growMazes()
    for x = 1, dungeonWidth, 2 do
        for y = 1, dungeonHeight, 2 do
            local tile = { x = x, y = y }
            if isWall(tile) then
                growMaze(tile)
            end
        end
    end
end

function removeDeadEnds()
    local done = false
    local removedTiles = 0
    while not done do
        done = true
        doForAllTiles(function(x, y)
            if isPath({ x = x, y = y }) then
                local wall = 0
                for _, direction in pairs(Direction.CARDINAL) do
                    local neighborTile = {
                        x = x + direction.x,
                        y = y + direction.y
                    }
                    if isWall(neighborTile) then
                        wall = wall + 1
                    end
                end
                if wall == 3 then
                    fill({ x = x, y = y })
                    removedTiles = removedTiles + 1
                    if removedTiles > maxRemovableDeadEnds then
                        done = true
                    else
                        done = false
                    end
                end
            end
        end)
        if drawStep then drawDungeon() end
    end
end

function addRooms()
    local rooms = {}
    for i = 0, numRoomTries do
        local size = intRnd(2 + roomExtraSize) * 2 + 5
        local rectangularity = intRnd(1 + size / 2) * 2
        local w = size
        local h = size
        if oneIn(2) then
            w += rectangularity
        else
            h += rectangularity
        end
        local x = intRnd((dungeonWidth - 1 - w) / 2) * 2 + 1
        local y = intRnd((dungeonHeight - 1 - h) / 2) * 2 + 1
        local room = { x = x, y = y, w = w, h = h }
        local overlaps = false
        for other in all(rooms) do
            if distanceTo(room, other) <= 0 then
                overlaps = true
                break
            end
        end
        if not overlaps then
            -- rect(room.x, room.y, room.x + room.w, room.y + room.h, 3)
            add(rooms, room)
            -- startRegion(_ENV)
            local positions = getAllTilePositions(room)
            for pos in all(positions) do
                carve(pos)
            end
            if drawStep then drawDungeon() end
        end
    end
end

-- Draw the dungeon
function drawDungeon()
    doForAllTiles(function(x, y)
        pset(x, y, dungeon[x][y])
    end)
    if rnd() > 0.99999 then
        -- flip()
    end
end

-- Carve function
function carve(tile)
    dungeon[tile.x][tile.y] = emptyTile
end

function fill(tile)
    dungeon[tile.x][tile.y] = wallTile
end

_init = function()
    initDungeon()
    addRooms()
    growMazes()
    -- removeDeadEnds()
end

_draw = drawDungeon