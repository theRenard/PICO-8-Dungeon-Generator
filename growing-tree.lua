cls(0)
pq('---------------------------------')

--[[
from https://journal.stuffwithstuff.com/2014/12/21/rooms-and-mazes/

The random dungeon generator.
Starting with a stage of solid walls, it works like so:

1. Place a number of randomly sized and positioned rooms. If a room
    overlaps an existing room, it is discarded. Any remaining rooms are
    carved out.
 2. Any remaining solid areas are filled in with mazes. The maze generator
    will grow and fill in even odd-shaped areas, but will not touch any
    rooms.
 3. The result of the previous two steps is a series of unconnected rooms
    and mazes. We walk the stage and find every tile that can be a
    "connector". This is a solid tile that is adjacent to two unconnected
    regions.
 4. We randomly choose connectors and open them or place a door there until
    all of the unconnected regions have been joined. There is also a slight
    chance to carve a connector between two already-joined regions, so that
    the dungeon isn't single connected.
 5. The mazes will have a lot of dead ends. Finally, we remove those by
    repeatedly filling in any open tile that's closed on three sides. When
    this is done, every corridor in a maze actually leads somewhere.
--]]

-- Constants

-- Types
--- tile = number
--- pos/vec = { x: number, y: number }
--- room = { x: number, y: number, w: number, h: number }
--- direction = { x: number, y: number }
--- region = number
--- connector = { x: number, y: number }

local drawStep = true
local method = 3 -- chose_random, chose_oldest, chose_newest
local dungeonWidth = 128
local dungeonHeight = 128
local maxRemovableDeadEnds = 2000
local numRoomTries = 1000
local roomExtraSize = 8
local bouldersRatio = 0
local extraConnectorChance = 40

-- Tiles
local wallTile = 2
local floorTile = 7
local boulderTile = 4
local openDoorTile = 7 --12
local closedDoorTile = 7 --13

-- 2D array of tiles: { x: { y: t } }
local dungeon = create2dArray(dungeonWidth, dungeonHeight, wallTile)

-- regions: 2D array of regions { x: { y: r } }
local regions = create2dArray(dungeonWidth, dungeonHeight, nil)

-- connectorRegions: 2D array of regions { x: { y: { r1, r2 }}}
local connectorRegions = create2dArray(dungeonWidth, dungeonHeight, nil)
local currentRegion = 0

function choseIndex(ceil)
    if method == 1 then
        return flr(rnd(ceil)) + 1
    elseif method == 2 then
        return 1
    elseif method == 3 then
        return ceil
    end
end

function isInBounds(pos, padding)
    local padding = padding or 1
    return pos.x <= dungeonWidth - padding and pos.y <= dungeonHeight - padding and pos.x > 0 and pos.y > 0
end

function isWall(pos)
    return dungeon[pos.x][pos.y] == wallTile or dungeon[pos.x][pos.y] == boulderTile
end

function isPath(pos)
    return dungeon[pos.x][pos.y] == floorTile
end

function setTile(pos, tileType)
    dungeon[pos.x][pos.y] = tileType
end

function carve(pos)
    setTile(pos, floorTile)
    regions[pos.x][pos.y] = currentRegion
end

function fill(pos)
    dungeon[pos.x][pos.y] = wallTile
end

function canCarve(pos)
    return isInBounds(pos) and isWall(pos)
end

function addRegion()
    currentRegion += 1
    pq('addRegion', currentRegion)
end

function addJunction(pos)
    if oneIn(4) then
        if oneIn(3) then
            setTile(pos, openDoorTile)
        else
            setTile(pos, floorTile)
        end
    else
        setTile(pos, closedDoorTile)
    end
end

function growMaze(startPos)
    pq('growMaze', startPos)
    addRegion()
    local positions = {}
    carve(startPos)
    add(positions, startPos)

    while #positions > 0 do
        local index = choseIndex(#positions)
        local currentPos = positions[index]
        for _, direction in pairs(shuffle(Direction.CARDINAL)) do
            local neighborPos = {
                x = currentPos.x + direction.x,
                y = currentPos.y + direction.y
            }
            local nextNeighborTile = {
                x = currentPos.x + direction.x * 2,
                y = currentPos.y + direction.y * 2
            }
            if canCarve(neighborPos) and canCarve(nextNeighborTile) then
                carve(neighborPos)
                carve(nextNeighborTile)
                add(positions, nextNeighborTile)
                if drawStep then drawDungeon() end
                index = nil
                break
            end
        end
        if index then
            del(positions, currentPos)
        end
    end
end

function growMazes()
    for x = 1, dungeonWidth, 2 do
        for y = 1, dungeonHeight, 2 do
            local pos = { x = x, y = y }
            if isWall(pos) then
                growMaze(pos)
            end
        end
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
            add(rooms, room)
            addRegion()
            for pos in all(getAllPositions(room)) do
                carve(pos)
            end
            if drawStep then drawDungeon() end
        end
    end
end

function connectRegions()
    -- Find all of the tiles that can connect two (or more) regions.
    if drawStep then drawRegions() end

    forEachArr2D(dungeon, function(x, y)
        if isWall({ x = x, y = y }) then
            -- regions that are connected to this wall
            local _regions = {} -- { region1, region2, ... } -- { 1, 2, 3 }
            for _, direction in pairs(Direction.CARDINAL) do
                local neighborPos = {
                    x = x + direction.x,
                    y = y + direction.y
                }
                if isInBounds(neighborPos) then
                    local _region = regions[neighborPos.x][neighborPos.y]
                    if _region and not contains(_regions, _region) then
                        add(_regions, _region)
                    end
                end
            end
            if #_regions >= 2 then
                connectorRegions[x][y] = _regions
            end
        end
    end)

    if drawStep then
        drawConnections()
    end

    local connectors = {} -- {{ x, y }}

    forEachArr2D(dungeon, function(x, y)
        if connectorRegions[x][y] then
            add(connectors, { x = x, y = y })
        end
    end)

    -- Keep track of which regions have been merged. This maps an original
    -- region index to the one it has been merged to.
    local mergedRegions = {}
    local unMergedRegions = {}
    for i = 1, currentRegion do
        mergedRegions[i] = i
        unMergedRegions[i] = i
    end

    while #unMergedRegions > 1 do
        pq('---------------------------------')
        pq('mergedRegions', #mergedRegions)
        pq('unMergedRegions', #unMergedRegions)

        local connector = getRandomItem(connectors)

        addJunction(connector)

        -- Merge the connected regions. We'll pick one region (arbitrarily) and
        -- map all of the other regions to its index.
        local regions = map(connectorRegions[connector.x][connector.y], function(region)
            return mergedRegions[region]
        end)

        local dest = regions[1] -- the first region: number

        local sources = slice(regions, 2) -- the rest of the regions: { number }

        -- Merge all of the affected regions. We have to look at *all* of the
        -- regions because other regions may have previously been merged with
        -- some of the ones we're merging now.
        for i = 1, currentRegion do
            if contains(sources, mergedRegions[i]) then
                mergedRegions[i] = dest
            end
        end

        -- The sources are no longer in use.
        for source in all(sources) do
            del(unMergedRegions, source)
        end

        -- Remove any connectors that aren't needed anymore.
        removeWhere(connectors, function(pos)
            pq(#connectors)
            -- Don't allow connectors right next to each other.
            if distanceBetween(connector, pos) < 2 then
                return true
            end

            -- If the connector no long spans different regions, we don't need it.
            local regions = map(
                connectorRegions[pos.x][pos.y], function(region)
                    return mergedRegions[region]
                end
            )
            regions = removeDup(regions)

            if #regions > 1 then
                return false
            end

            if oneIn(extraConnectorChance) then
                addJunction(pos)
            end

            return true
        end)

        if drawStep then drawDungeon() end
    end
end

function removeDeadEnds()
    local done = false
    local removedTiles = 0
    while not done do
        done = true
        forEachArr2D(dungeon, function(x, y)
            if isPath({ x = x, y = y }) then
                local wall = 0
                for _, direction in pairs(Direction.CARDINAL) do
                    local neighborPos = {
                        x = x + direction.x,
                        y = y + direction.y
                    }
                    if isWall(neighborPos) then
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

-- Draw the dungeon
function drawDungeon()
    if rnd() > 0.9 then
        forEachArr2D(dungeon, function(x, y)
            pset(x, y, dungeon[x][y])
        end)
    end
end

function drawRegions()
    forEachArr2D(dungeon, function(x, y)
        local region = regions[x][y]
        -- color between 0 and 15
        local color = region and (region % 15) + 1 or 0
        if color == 9 or color == 10 then
            color = 11
        end
        pset(x, y, color)
    end)
end

function drawConnections()
    forEachArr2D(dungeon, function(x, y)
        local regions = connectorRegions[x][y]

        if regions then
            if #regions == 2 then
                pset(x, y, 9)
            else
                pset(x, y, 10)
            end
        end
    end)
end

_init = function()
    addRooms()
    growMazes()
    connectRegions()
    removeDeadEnds()
end

-- _draw = drawDungeon