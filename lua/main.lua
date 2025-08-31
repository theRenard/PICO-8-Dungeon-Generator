-- Dungeon Generator for PICO-8
-- This program generates procedural dungeons using maze generation algorithms

-- set map size to 128x128 pixels (16x16 tiles)
-- poke(0x5f56, width), poke(0x5f57, height) in pixels
-- poke(0x5f56, 128)
-- poke(0x5f57, 128)

cls()

-- Dungeon dimensions in tiles (32x32 = 256x256 pixels)
local dungeonWidth = 64
local dungeonHeight = 64
-- 2D array to store the dungeon layout
local dungeon = {}

-- Main function to generate a new dungeon
function create_dungeon()
  -- Generate maze using the maze generator library
  -- Parameters:
  --   draw: true = visualize generation process
  --   mth: 0 = maze generation method
  --   w/h: width and height of dungeon
  --   xtrconn: 80 = extra connections for more open layout
  --   exits: 1 = number of exit points

  dungeon, chambers = make_mz({
    draw = true,
    mth = 0,
    w = dungeonWidth,
    h = dungeonHeight,
    xtrconn = 80,
    exits = 1
  })

  -- Convert the generated maze to PICO-8 map tiles
  -- foreach_2darr iterates through each position in the 2D array
  foreach_2darr(
    dungeon, function(x, y)
      -- Set map tile at (x-1, y-1) to the dungeon value
      -- PICO-8 map coordinates are 0-based, so we subtract 1
      --[[
        TILE types:
        - wl_tl: wall tile = 4
        - flr_tl: floor tile = 0
        - op_tl: open tile = 3
        - csd_tl: closed tile = 8
        - xt_tl: exit tile = 9
]]
      local tileType = dungeon[x][y]
      local tileValue = 0
      if tileType == 4 then
        tileValue = int_rnd(16) + 16 -- tile is from 16 to 31
      elseif tileType == 3 then
        tileValue = 34
      elseif tileType == 8 then
        tileValue = 33
      elseif tileType == 9 then
        tileValue = 32
      else
        tileValue = 1
      end
      mset(x - 1, y - 1, tileValue)
    end
  )

  -- Process chambers (rooms) to add variety to floor tiles
  -- iterate over the chambers with pairs
  for region, posn in pairs(chambers) do
    -- iterate over the chamber's tiles with ipairs
    for pos in all(posn) do
      -- set the tile to a random floor tile
      -- tile is from 2 to 15 (different floor tile types)
      local tile = 0
      local tileValue = one_in(7) and int_rnd(14) + 2 or 0
      mset(pos.x - 1, pos.y - 1, tileValue)
    end
  end
end

-- Toggle debug map overlay on/off
function toggle_map_draw()
  map_draw = not map_draw
end

-- PICO-8 initialization function - called once at startup
function _init()
  -- Start with debug overlay disabled
  map_draw = false
  -- Generate the initial dungeon
  create_dungeon()
end

-- Camera position variables for scrolling the view
-- the coordinates of the upper left corner of the camera
cam_x = 0
cam_y = 0

-- PICO-8 update function - called every frame
function _update()
  -- Handle camera movement with arrow keys (buttons 0-3)
  -- Left arrow (button 0): move camera left if not at left edge
  if (btn(0) and cam_x > 0) cam_x -= 8
  -- Right arrow (button 1): move camera right if not at right edge
  if (btn(1) and cam_x < (dungeonWidth * 8) - 128) cam_x += 8
  -- Up arrow (button 2): move camera up if not at top edge
  if (btn(2) and cam_y > 0) cam_y -= 8
  -- Down arrow (button 3): move camera down if not at bottom edge
  if (btn(3) and cam_y < (dungeonHeight * 8) - 128) cam_y += 8
  -- Button 4 (X): generate a new dungeon
  if btnp(4) then
    -- reset card
    create_dungeon()
  end

  -- Button 5 (C): toggle debug overlay (only on press, not hold)
  if btnp(5) then
    toggle_map_draw()
  end
end

-- PICO-8 draw function - called every frame after _update()
function _draw()
  -- Clear the screen
  cls()

  -- Set the camera to the current scroll position
  -- This will offset all drawing operations
  camera(cam_x, cam_y)

  -- Draw the entire map at (0, 0), allowing
  -- the camera and clipping region to decide
  -- what is shown on screen
  map(0, 0, 0, 0, dungeonWidth, dungeonHeight)

  -- Debug overlay: show raw dungeon data as pixels
  if map_draw then
    foreach_2darr(
      dungeon, function(x, y)
        -- draw the debug overlay from top and left,
        -- always fixed on screen regardless of camera
        -- Each pixel represents the tile value at that position
        pset(x + cam_x, y + cam_y, dungeon[x][y])
      end
    )

    -- draw a red rectangle (color 2) that covers the screen and moves with the camera
    -- the rectangle should be the size of the visible screen (128x128)
    -- and move with the camera, so its top-left is always at (cam_x, cam_y)
    local x = cam_x + 16 + (((128 - cam_x) / 8) * -1)
    local y = cam_y + 16 + (((128 - cam_y) / 8) * -1)
    local w = 16
    local h = 16
    rect(x, y, x + w, y + h, 2)
  end

  -- Reset the camera to draw UI elements in screen coordinates
  camera()

  -- Uncomment the line below to show camera coordinates for debugging
  --   print('('..cam_x..', '..cam_y..')', 0, 0, 7)
end