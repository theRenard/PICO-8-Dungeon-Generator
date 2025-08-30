cls()

local dungeonWidth = 64
local dungeonHeight = 64
local dungeon = {}

function create_dungeon()
  dungeon, chambers = make_mz({
    draw = true,
    mth = 2,
    w = dungeonWidth,
    h = dungeonHeight,
    xtrconn = 80,
    exits = 1
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

function toggle_map_draw()
  map_draw = not map_draw
end

function _init()
  map_draw = false
  create_dungeon()
end

-- the coordinates of the upper left corner of the camera
cam_x = 0
cam_y = 0

function _update()
  if (btn(0) and cam_x > 0) cam_x -= 8
  if (btn(1) and cam_x < (dungeonWidth * 8) - 128) cam_x += 8
  if (btn(2) and cam_y > 0) cam_y -= 8
  if (btn(3) and cam_y < (dungeonHeight * 8) - 128) cam_y += 8
  if btn(4) then
    create_dungeon()
  end
  if btnp(5) then
    toggle_map_draw()
  end
end

function _draw()
  cls()
  -- set the camera to the current location
  camera(cam_x, cam_y)

  -- draw the entire map at (0, 0), allowing
  -- the camera and clipping region to decide
  -- what is shown
  map(0, 0, 0, 0, dungeonWidth, dungeonHeight)
  if map_draw then
  foreach_2darr(
      dungeon, function(x, y)
      -- draw the debug overlay from top and left,
      -- always fixed on screen regardless of camera
        pset(x + cam_x, y + cam_y, dungeon[x][y])
      end
    )

    -- draw a red rectangle (color 8) that covers the screen and moves with the camera
    -- the rectangle should be the size of the visible screen (128x128)
    -- and move with the camera, so its top-left is always at (cam_x, cam_y)
    local x = cam_x + 16 + (((128 - cam_x) / 8) * -1)
    local y = cam_y + 16 + (((128 - cam_y) / 8) * -1)
    local w = 16
    local h = 16
    rect(x, y, x + w, y + h, 2)
  end

  -- reset the camera then print the camera
  -- coordinates on screen
  camera()
  --   print('('..cam_x..', '..cam_y..')', 0, 0, 7)
end