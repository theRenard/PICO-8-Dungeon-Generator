cls(3)

local dungeonWidth = 128
local dungeonHeight = 64
local tiles = {
  emptyTile = 0,
  wallTile = 1,
  floorTile = 7,
  openDoorTile = 12,
  closedDoorTile = 8,
  exitTile = 9,
}

function _init()
  local dungeon = createMaze(dungeonWidth, dungeonHeight, tiles, true)
  forEachArr2D(
    dungeon, function(x, y)
        mset(x - 1, y - 1, dungeon[x][y])
    end
)
end

-- the coordinates of the upper left corner of the camera
cam_x = 0
cam_y = 0

-- function _update()
--   if (btn(0) and cam_x > 0) cam_x -= 10
--   if (btn(1) and cam_x < (dungeonWidth * 8) - 128) cam_x += 10
--   if (btn(2) and cam_y > 0) cam_y -= 10
--   if (btn(3) and cam_y < (dungeonHeight * 8) - 128) cam_y += 10
-- end

-- function _draw()
--   cls()
--   -- set the camera to the current location
--   camera(cam_x, cam_y)

--   -- draw the entire map at (0, 0), allowing
--   -- the camera and clipping region to decide
--   -- what is shown
--   map(0, 0, 0, 0, dungeonWidth, dungeonHeight)

--   -- reset the camera then print the camera
--   -- coordinates on screen
--   camera()
--   --   print('('..cam_x..', '..cam_y..')', 0, 0, 7)
-- end