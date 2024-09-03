-- dungeon generator

stage = class:extend({
    -- class
    w = 0,
    h = 0,
    tiles = {},
    entities = {},
    player = nil,
    enemies = {},
    items = {},
    stairs = {},
    init = noop
})

-- stage.tiles = {
--    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, -- y = 1
--    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
--    { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },

generator = class:extend({
    --instance
    numRoomTries = 1000,
    extraConnectorChance = 20,
    roomExtraSize = 0,
    windingPercent = 0,
    rooms = {},
    regions = {},
    currentRegion = -1,
    emptyTile = 0,
    wallTile = 2,
    floorTile = 1,
    stage = nil,

    init = noop,

    generate = function(_ENV, s)
        -- if (s.width%2==0 or s.height%2==0) then
        --     print("The map size must be odd.")
        -- end

        stage = s
        createTiles(_ENV)
        createRegions(_ENV)
        cls()
        fill(_ENV, wallTile)
        --     _regions = new Array2D(stage.width, stage.height);

        addRooms(_ENV)
        createMaze(_ENV)

        -- connectRegions();
        -- removeDeadEnds();

        -- decorateRooms();

        drawToPixels(_ENV)
        -- drawToMap(_ENV)
    end,

    createTiles = function(_ENV)
        for y = 0, stage.h - 1 do
            stage.tiles[y] = {}
            for x = 0, stage.w - 1 do
                stage.tiles[y][x] = 0
            end
        end
    end,

    createRegions = function(_ENV)
        for y = 0, stage.h - 1 do
            regions[y] = {}
            for x = 0, stage.w - 1 do
                regions[y][x] = 0
            end
        end
    end,

    fill = function(_ENV, tileType)
        for y = 0, stage.h - 1 do
            for x = 0, stage.w - 1 do
                stage.tiles[y][x] = tileType
            end
        end
    end,

    drawToPixels = function(_ENV)
        for y = 0, stage.h - 1 do
            for x = 0, stage.w - 1 do
                if stage.tiles[y][x] == wallTile then
                    pset(x+10, y+10, 7)
                end
                if stage.tiles[y][x] == floorTile then
                    pset(x+10, y+10, 8)
                end
            end
        end
    end,

    drawToMap = function(_ENV)
        for y = 0, stage.h - 1 do
            for x = 0, stage.w - 1 do
                mset(x, y, stage.tiles[y][x])
            end
        end
    end,

    createMaze = function(_ENV)
        -- fill in all of the empty space with mazes
        -- for y = 0, stage.h - 1, 2 do
        --     for x = 0, stage.w - 1, 2 do
        --         local pos = { x = x, y = y }
        --         local tileType = getTile(_ENV, pos)
        --         if tileType == wallTile then
        --             growMaze(_ENV, pos)
        --         end
        --     end
        -- end
        growMaze(_ENV, { x = 32, y = 32 })
    end,

    -- Implementation of the "growing tree" algorithm from here:
    -- http://www.astrolog.org/labyrnth/algrithm.htm.
    growMaze = function(_ENV, pos)
        local cells = {}
        local lastDir = nil

        startRegion(_ENV)
        carve(_ENV, pos)

        add(cells, pos)

        while #cells > 0 and #cells < 10000 do
            local cell = cells[#cells]
            local unmadeCells = {}

            for dir in all(Direction.CARDINAL) do
                if canCarve(_ENV, cell, dir) then
                    add(unmadeCells, dir)
                end
            end

            pq(#cells)

            if #unmadeCells > 0 then
                local dir

                if vecContains(unmadeCells, lastDir) and rnd(100) > windingPercent then
                    dir = lastDir
                else
                end
                dir = unmadeCells[intRnd(#unmadeCells)]

                carve(_ENV, vecSumAndMlt(cell, dir))
                carve(_ENV, vecSumAndMlt(cell, dir))

                add(cells, vecSumAndMlt(cell, dir))
                lastDir = dir
            else
                del(cells, cell)
                lastDir = nil
            end
        end
    end,

    addRooms = function(_ENV)
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
            local x = intRnd((stage.w - 1 - w) / 2) * 2 + 1
            local y = intRnd((stage.h - 1 - h) / 2) * 2 + 1
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
                startRegion(_ENV)
                local positions = getAllTilePositions(room)
                for pos in all(positions) do
                    carve(_ENV, pos)
                end
            end
        end
    end,

    -- drawRooms=function(_ENV)
    --     for room in all(rooms) do
    --         for pos in all(rect(room[1],room[2],room[3],room[4])) do
    --             stage.tiles[pos.x][pos.y]=0
    --         end
    --     end
    -- end,

    startRegion = function(_ENV)
        currentRegion += 1
    end,

    setTile = function(_ENV, pos, tileType)
        -- pq(pos.x, pos.y)
        stage.tiles[pos.y][pos.x] = tileType
    end,

    getTile = function(_ENV, pos)
        return stage.tiles[pos.y][pos.x]
    end,

    canCarve = function(_ENV, pos, dir)
        -- local nextCell = pos + dir * 3
        -- if nextCell.x >= stage.w or nextCell.y >= stage.h then
        --     return false
        -- end
        -- if stage.tiles[nextCell.x][nextCell.y] == wallTile then
        --     return true
        -- end
        -- return false
        local nextCell = vecSumAndMlt(pos, dir, 3)
        if nextCell.x >= stage.w or nextCell.y >= stage.h then
            return false
        end
        if nextCell.x < 0 or nextCell.y < 0 then
            return false
        end
        -- pq(nextCell.x, nextCell.y)
        if stage.tiles[nextCell.y][nextCell.x] == wallTile then
            return true
        end
        return false
    end,

    carve = function(_ENV, pos, tileType)
        if tileType == nil then
            tileType = floorTile
        end
        setTile(_ENV, pos, tileType)
        -- regions[pos.y][pos.x] = currentRegion
    end
})