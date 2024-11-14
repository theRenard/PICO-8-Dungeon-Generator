cls(0)

--[[
from https://journal.stuffwithstuff.com/2014/12/21/rooms-and-mazes/
and https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm

Types
- tile = number
- pos/vec = { x: number, y: number }
- room = { x: number, y: number, w: number, h: number }
- direction = { x: number, y: number }
- region = number
- connector = { x: number, y: number }
--]]

-- Constants
local drawStep = true
local drawInterval = 0.9
local method = 2 -- chose_random = 1, chose_oldest = 2, chose_newest = 3
local dungeonWidth = 128
local dungeonHeight = 128
local numRoomTries = 1000 -- number of rooms to try, the greater the number, the more rooms
local roomExtraSize = 20
local extraConnectorChance = 40

-- Tiles
local wallTile = 1
local floorTile = 7
local openDoorTile = 12
local closedDoorTile = 8

-- 2D array of tiles: { x: { y: t } }
local dungeon = create2DArr(dungeonWidth, dungeonHeight, wallTile)

-- regions: 2D array of regions { x: { y: r } }
local regions = create2DArr(dungeonWidth, dungeonHeight, nil)

-- connectorRegions: 2D array of regions { x: { y: { r1, r2 }}}
local connectorRegions = create2DArr(dungeonWidth, dungeonHeight, nil)
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
    return dungeon[pos.x][pos.y] == wallTile
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

    while not done do
        done = true
        forEachArr2D(dungeon, function(x, y)
            if not isWall({ x = x, y = y }) then
                local exits = 0
                for _, direction in pairs(Direction.CARDINAL) do
                    local neighborPos = {
                        x = x + direction.x,
                        y = y + direction.y
                    }
                    if not isWall(neighborPos) then
                        exits = exits + 1
                    end
                end
                if exits == 1 then
                    fill({ x = x, y = y })
                    if drawStep then drawDungeon() end
                    done = false
                end
            end
        end)
    end
end

function drawDungeon()
    if rnd() > drawInterval then
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
    if rnd() > drawInterval then
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
end

_init = function()
    addRooms()
    growMazes()
    connectRegions()
    removeDeadEnds()
end

_draw = drawDungeon