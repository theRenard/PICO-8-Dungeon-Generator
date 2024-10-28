cls(9)

local method = 3 -- chose_random, chose_oldest, chose_newest
local dungeonWidth = 40
local dungeonHeight = 40
local dungeon = {}

function resetDungeon()
    for x = 0, dungeonWidth do
        dungeon[x] = {}
        for y = 0, dungeonHeight do
            dungeon[x][y] = 0
            -- dungeon[x][y] = rnd() > 0.05 and 0 or 4
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

resetDungeon()

-- Step #2 create a list of cells to act as the seed for the growing tree algorithm.
local cells = {}

-- Step #3 choose a random cell from the dungeon.
local randomCell = {
    x = flr(rnd(dungeonWidth / 2)) * 2 + 1,
    y = flr(rnd(dungeonHeight / 2)) * 2 + 1
}

-- Step #4 add the random cell to the list of cells.
add(cells, randomCell)

-- Draw the dungeon
function drawDungeon()
    for y = 0, dungeonHeight do
        for x = 0, dungeonWidth do
            pset(x, y, dungeon[x][y])
            -- rectangle of 8 x 20 pixels
            rectfill(0, 120, 128, 128, 3)
            print("Cells: " .. #cells, 0, 121, 7)
        end
    end
    -- flip
    if rnd() > 0.999 then
        flip()
    end
end

-- Carve function
function carve(x, y, tile)
    local tile = tile or 0
    dungeon[x][y] = tile
end

-- Step #5 while the list of cells is not empty, do the following:
while #cells > 0 do
    -- Step #6 choose a random cell from the list of cells.
    local index = choseIndex(#cells)
    local currentCell = cells[index]
    -- Step #7 create a list of unvisited neighbors of the current cell.
    for _, direction in pairs(shuffle(Direction.CARDINAL)) do
        local neighbor = {
            x = currentCell.x + direction.x,
            y = currentCell.y + direction.y
        }
        local nextNeighbor = {
            x = currentCell.x + direction.x * 2,
            y = currentCell.y + direction.y * 2
        }
        if neighbor.x <= dungeonWidth - 1 and neighbor.y <= dungeonHeight - 1
        and neighbor.x > 0 and neighbor.y > 0 then
            if dungeon[neighbor.x][neighbor.y] == 0 and dungeon[nextNeighbor.x][nextNeighbor.y] == 0 then
                carve(neighbor.x, neighbor.y, 7)
                carve(nextNeighbor.x, nextNeighbor.y, 7)
                add(cells, nextNeighbor)
                drawDungeon()
                index = nil
                break
            end
        end
    end
    if index then
        del(cells, currentCell)
    end
end

_draw = drawDungeon