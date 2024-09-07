cls()
numRoomTries = 100
roomExtraSize = 2
floorTile = 1
emptyTile = 0
wallTile = 2
stage = {
    rooms = {},
    tiles = {},
}

-- initialize stage
function createStage(w, h)
    stage.w = w
    stage.h = h
    stage.map = {}
    for y = 0, stage.h do
        stage.tiles[y] = {}
        for x = 0, stage.w - 1 do
            stage.tiles[y][x] = (x + y) % 2
        end
    end
end

function drawStage()
    for y = 0, stage.w do
        for x = 0, stage.h do
            pset(x, y, stage.tiles[x][y])
            -- draw on screen every 10 pixels
            if x == 0 and y % 2 == 0 then
                flip()
            end
        end
    end
end

function createRooms()
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
        for other in all(stage.rooms) do
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
                carve(pos, 4)
            end
        end
    end
end

function createMaze()

end

function carve(pos, tileType)
    if tileType == nil then
        tileType = floorTile
    end
    -- check bounds
    if pos.x < 0 or pos.x >= stage.w or pos.y < 0 or pos.y >= stage.h then
        return
    end
    setTile(pos, tileType)
    -- regions[pos.y][pos.x] = currentRegion
end

function setTile(pos, tileType)
    pq(pos.x, pos.y)
    stage.tiles[pos.y][pos.x] = tileType
end

-- function createMap()
--     for x = 0, stage.width do
--         for y = 0, stage.height do
--             -- mset(x, y, stage.map[x][y])
--         end
--     end
-- end

createStage(127, 127)
drawStage()
createRooms()
drawStage()
-- createMap()

function _draw()

end