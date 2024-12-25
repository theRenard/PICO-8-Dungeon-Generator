-- Copyright (c) 2024 Daniele Tabanella under the MIT license

--[[
based on the articles:
https://journal.stuffwithstuff.com/2014/12/21/rooms-and-mazes/
https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
--]]


function createMaze(config)
    -- Constants
    local drawStep = config.drawStep or false
    local method = config.method or 3
    -- chose_random = 1, chose_oldest = 2, chose_newest = 3
    local border = 1
    local hasBorder = config.hasBorder or true
    -- 1 no border
    local width = config.width or 128
    local height = config.height or 64
    local mazeWidth = width - border
    local mazeHeight = height - border
    local chambers = {}
    if hasBorder then
        border = 2
        mazeWidth = width - 1
        mazeHeight = height - 1
    end

    local numRoomTries = 1000
    -- number of rooms to try, the greater the number, the more rooms
    local roomExtraSize = config.roomExtraSize or 1
    local extraConnectorChance = config.extraConnectorChance or 20
    local exits = config.exits or 2

    -- Tiles
    local wallTile = config.wallTile or 1
    local floorTile = config.floorTile or 7
    local openDoorTile = config.openDoorTile or 12
    local closedDoorTile = config.closedDoorTile or 8
    local exitTile = config.exitTile or 9

    local maze = create2DArr(mazeWidth, mazeHeight, wallTile)
    local regions = create2DArr(mazeWidth, mazeHeight, nil)
    local connectorRegions = create2DArr(mazeWidth, mazeHeight, nil)
    local deadEnds = {}

    local currentRegion = 0

    local function choseIndex(ceil)
        if method == 1 then
            return flr(rnd(ceil)) + 1
        elseif method == 2 then
            return 1
        elseif method == 3 then
            return ceil
        end
    end

    local function isInBounds(pos)
        return pos.x <= mazeWidth and pos.y <= mazeHeight and pos.x > 0 and pos.y > 0
    end

    local function isWall(pos)
        return maze[pos.x][pos.y] == wallTile
    end

    local function isPath(pos)
        return maze[pos.x][pos.y] == floorTile
    end

    local function setTile(pos, tileType)
        maze[pos.x][pos.y] = tileType
    end

    local function carve(pos)
        setTile(pos, floorTile)
        regions[pos.x][pos.y] = currentRegion
    end

    local function fill(pos)
        maze[pos.x][pos.y] = wallTile
    end

    local function canCarve(pos)
        return isInBounds(pos) and isWall(pos)
    end

    local function addRegion()
        currentRegion += 1
    end

    local function addDeadEnd(pos)
        add(deadEnds, pos)
    end

    local function addJunction(pos)
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

    local function drawmaze()
        if rnd() > 0.9 then
            forEachArr2D(
                maze, function(x, y)
                    pset(x - 1, y - 1, maze[x][y])
                end
            )
        end
    end

    local function drawRegions()
        forEachArr2D(
            maze, function(x, y)
                local region = regions[x][y]
                -- color between 0 and 15
                local color = region and (region % 15) + 1 or 0
                if color == 9 or color == 10 then
                    color = 11
                end
                pset(x - 1, y - 1, color)
            end
        )
    end

    local function drawConnections()
        if rnd() > 0.9 then
            forEachArr2D(
                maze, function(x, y)
                    local regions = connectorRegions[x][y]
                    if regions then
                        if #regions == 2 then
                            pset(x - 1, y, 9)
                        else
                            pset(x - 1, y, 10)
                        end
                    end
                end
            )
        end
    end

    local function growMaze(startPos)
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
                    if drawStep then drawmaze() end
                    index = nil
                    break
                end
            end
            if index then
                del(positions, currentPos)
            end
        end
    end

    local function growMazes()
        for x = border, mazeWidth, 2 do
            for y = border, mazeHeight, 2 do
                local pos = { x = x, y = y }
                if isWall(pos) then
                    growMaze(pos)
                end
            end
        end
    end

    local function addRooms()
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
            local x = intRnd((mazeWidth - border - w) / 2) * 2 + border
            local y = intRnd((mazeHeight - border - h) / 2) * 2 + border
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
                chambers[currentRegion] = {}
                for pos in all(getAllPositions(room)) do
                    carve(pos)
                    add(chambers[currentRegion], pos)
                end
                if drawStep then drawmaze() end
            end
        end
    end

    local function connectRegions()
        if drawStep then drawRegions() end

        forEachArr2D(
            maze, function(x, y)
                if isWall({ x = x, y = y }) then
                    local _regions = {}
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
            end
        )

        if drawStep then
            drawConnections()
        end

        local connectors = {}
        -- {{ x, y }}

        forEachArr2D(
            maze, function(x, y)
                if connectorRegions[x][y] then
                    add(connectors, { x = x, y = y })
                end
            end
        )

        local mergedRegions = {}
        local unMergedRegions = {}
        for i = 1, currentRegion do
            mergedRegions[i] = i
            unMergedRegions[i] = i
        end

        while #unMergedRegions > 1 do
            local connector = getRandomItem(connectors)

            addJunction(connector)

            local regions = domap(
                connectorRegions[connector.x][connector.y], function(region)
                    return mergedRegions[region]
                end
            )

            local dest = regions[1]

            local sources = slice(regions, 2)

            for i = 1, currentRegion do
                if contains(sources, mergedRegions[i]) then
                    mergedRegions[i] = dest
                end
            end

            for source in all(sources) do
                del(unMergedRegions, source)
            end

            removeWhere(
                connectors, function(pos)
                    if distanceBetween(connector, pos) < 2 then
                        return true
                    end
                    local regions = domap(
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
                end
            )

            if drawStep then drawmaze() end
        end
    end

    local function removeDeadEnds()
        local done = false

        -- add dead ends
        forEachArr2D(
            maze, function(x, y)
                if not isWall({ x = x, y = y }) then
                    local exits = 0
                    for _, direction in pairs(Direction.CARDINAL) do
                        local neighborPos = {
                            x = x + direction.x,
                            y = y + direction.y
                        }
                        if isInBounds(neighborPos) then
                            if not isWall(neighborPos) then
                                exits += 1
                            end
                        end
                    end
                    if exits == 1 then
                        addDeadEnd({ x = x, y = y })
                    end
                end
            end
        )

        while #deadEnds > exits do
            for _, pos in pairs(deadEnds) do
                local x, y = pos.x, pos.y
                local paths = {}
                for _, direction in pairs(Direction.CARDINAL) do
                    local neighborPos = {
                        x = x + direction.x,
                        y = y + direction.y
                    }
                    if isInBounds(neighborPos) then
                        if not isWall(neighborPos) then
                            add(paths, neighborPos)
                        end
                    end
                end
                if #paths == 1 then
                    fill({ x = x, y = y })
                    addDeadEnd(paths[1])
                    if drawStep then drawmaze() end
                end
                del(deadEnds, pos)
            end
        end

        for _, pos in pairs(deadEnds) do
            setTile(pos, exitTile)
        end
    end

    addRooms()
    growMazes()
    connectRegions()
    removeDeadEnds()

    return maze, chambers
end