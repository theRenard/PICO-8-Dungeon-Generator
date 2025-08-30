cls()

local dungeonWidth = 32
local dungeonHeight = 32
local dungeon = {}

function _init()
  dungeon, chambers = make_mz({
    draw = true,
    mth = 2,
    w = dungeonWidth,
    h = dungeonHeight,
    xtrconn = 80,
    exits = 2
  })
  foreach_2darr(
    dungeon, function(x, y)
      mset(x - 1, y - 1, dungeon[x][y])
    end
  )
  -- iterate over the chambers with pairs
  for region, posn in pairs(chambers) do
    -- iterate over the chamber's tiles with ipairs
    for pos in all(posn) do
      -- set the tile to a random floor tile
      -- tile is from 2 to 7
      local tile = region % 6 + 2
      mset(pos.x - 1, pos.y - 1, tile)
    end
  end

end

-- the coordinates of the upper left corner of the camera
cam_x = 0
cam_y = 0

function _update()
  if (btn(0) and cam_x > 0) cam_x -= 8
  if (btn(1) and cam_x < (dungeonWidth * 8) - 128) cam_x += 8
  if (btn(2) and cam_y > 0) cam_y -= 8
  if (btn(3) and cam_y < (dungeonHeight * 8) - 128) cam_y += 8
end

function _draw()
  cls()
  -- set the camera to the current location
  camera(cam_x, cam_y)

  -- draw the entire map at (0, 0), allowing
  -- the camera and clipping region to decide
  -- what is shown
  map(0, 0, 0, 0, dungeonWidth, dungeonHeight)
  foreach_2darr(
    dungeon, function(x, y)
      pset(x - 1, y - 1, dungeon[x][y])
    end
  )

  -- reset the camera then print the camera
  -- coordinates on screen
  camera()
  --   print('('..cam_x..', '..cam_y..')', 0, 0, 7)
end