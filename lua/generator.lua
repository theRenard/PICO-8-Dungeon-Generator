--[[
    - [Rooms and Mazes: A Procedural Dungeon Generator](https://journal.stuffwithstuff.com/2014/12/21/rooms-and-mazes/)
    - [Maze Generation: Growing Tree Algorithm](https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm)
]]

--[[
    DUNGEON GENERATOR

    This function creates a procedural maze/dungeon with the following features:
    - Random room placement
    - Maze generation using depth-first search
    - Region connection to ensure all areas are accessible
    - Dead end removal to create more interesting layouts
    - Configurable parameters for size, complexity, and visual output
]]

--[[
        TILE types:
        - wl_tl: wall tile = 4
        - flr_tl: floor tile = 0
        - op_tl: open tile = 3
        - csd_tl: closed tile = 8
        - xt_tl: exit tile = 9
]]

function make_mz(cfg)
    --[[ CONFIGURATION AND CONSTANTS ]]
    -- draw: whether to visualize the generation process in real-time
    -- mth: method for choosing next position (1=random, 2=first, 3=last)
    local draw, mth = cfg.draw or false, cfg.mth or 3

    -- brd: border size (1 or 2), w/h: maze dimensions
    local brd, w, h = cfg.hasbrd == false and 1 or 2, cfg.w or 128, cfg.h or 64

    -- mz_w/h: actual maze dimensions (accounting for border)
    -- chambers: stores room information for each region
    -- tries: maximum attempts for room placement
    -- xtrsz: extra size factor for rooms
    -- xtrconn: probability factor for extra connections
    -- exits: number of dead ends to preserve
    local mz_w, mz_h, chambers = w - 1, h - 1, {}
    local tries, xtrsz, xtrconn, exits = 1000, cfg.xtrsz or 1, cfg.xtrconn or 20, cfg.exits or 2

    --[[ TILE TYPES ]]
    -- wl_tl: wall tile, flr_tl: floor tile, op_tl: open tile
    -- csd_tl: closed tile, xt_tl: exit tile
    local wl_tl, flr_tl, op_tl, csd_tl, xt_tl = cfg.wl_tl or 4, cfg.flr_tl or 0, cfg.op_tl or 3, cfg.csd_tl or 8, cfg.xt_tl or 9

    --[[ DATA STRUCTURES ]]
    -- mz: main maze array (contains tile types)
    -- rgn: region array (tracks which region each cell belongs to)
    -- con_rgn: connection regions (tracks potential connection points)
    -- dd_ends: dead ends list
    -- cr_rgn: current region counter
    local mz, rgn, con_rgn, dd_ends, cr_rgn = mk2darr(mz_w, mz_h, wl_tl), mk2darr(mz_w, mz_h), mk2darr(mz_w, mz_h), {}, 0

    --[[ UTILITY FUNCTIONS ]]

    --[[
        chs_idx(ceil)
        Chooses the next position index based on the method:
        - Method 1: Random selection
        - Method 2: Always first (depth-first)
        - Method 3: Always last (breadth-first)
    ]]
    local function chs_idx(ceil)
        return mth == 1 and flr(rnd(ceil)) + 1 or mth == 2 and 1 or ceil
    end

    --[[
        in_bounds(pos)
        Checks if a position is within the maze boundaries
        Returns true if position is valid (1 to mz_w/h)
    ]]
    local function in_bounds(pos)
        return pos.x <= mz_w and pos.y <= mz_h and pos.x > 0 and pos.y > 0
    end

    --[[
        is_wall(pos)
        Checks if a position contains a wall tile
    ]]
    local function is_wall(pos)
        return mz[pos.x][pos.y] == wl_tl
    end

    --[[
        is_path(pos)
        Checks if a position contains a floor/path tile
    ]]
    local function is_path(pos)
        return mz[pos.x][pos.y] == flr_tl
    end

    --[[
        set_tl(pos, tl_ty)
        Sets a position to a specific tile type
    ]]
    local function set_tl(pos, tl_ty)
        mz[pos.x][pos.y] = tl_ty
    end

    --[[
        crv(pos)
        Carves a path at the given position and assigns it to current region
        This is the core function for creating paths in the maze
    ]]
    local function crv(pos)
        set_tl(pos, flr_tl)
        rgn[pos.x][pos.y] = cr_rgn
    end

    --[[
        fill(pos)
        Fills a position with a wall (blocks the path)
    ]]
    local function fill(pos)
        mz[pos.x][pos.y] = wl_tl
    end

    --[[
        can_crv(pos)
        Checks if a position can be carved (is within bounds and is a wall)
    ]]
    local function can_crv(pos)
        return in_bounds(pos) and is_wall(pos)
    end

    --[[
        add_rgn()
        Increments the region counter to create a new region
    ]]
    local function add_rgn()
        cr_rgn += 1
    end

    --[[
        add_dend(pos)
        Adds a position to the dead ends list
    ]]
    local function add_dend(pos)
        add(dd_ends, pos)
    end

    --[[
        add_junc(pos)
        Creates a junction at the given position
        Randomly chooses between closed tile, open tile, or floor tile
        This adds variety to the maze connections
    ]]
    local function add_junc(pos)
        local tile_type = csd_tl
        if one_in(4) then
            tile_type = one_in(3) and op_tl or flr_tl
        end
        set_tl(pos, tile_type)
    end

    --[[ VISUALIZATION FUNCTIONS ]]

    --[[
        draw_mz()
        Draws the current maze state to the screen
        Only draws occasionally (10% chance) to avoid overwhelming the display
    ]]
    local function draw_mz()
        if rnd() > 0.9 then
            foreach_2darr(
                mz, function(x, y)
                    pset(x - 1, y - 1, mz[x][y])
                end
            )
        end
    end

    --[[
        draw_rgn()
        Visualizes the regions with different colors
        Each region gets a unique color (avoiding colors 9 and 10)
    ]]
    local function draw_rgn()
        foreach_2darr(
            mz, function(x, y)
                local _rgn, color = rgn[x][y], _rgn and (_rgn % 15) + 1 or 0
                -- color between 0 and 15
                if color == 9 or color == 10 then
                    color = 11
                end
                pset(x - 1, y - 1, color)
            end
        )
    end

    --[[
        draw_connections()
        Visualizes connection points between regions
        Shows 2-region connections in color 9, multi-region in color 10
    ]]
    local function draw_connections()
        if rnd() > 0.9 then
            foreach_2darr(
                mz, function(x, y)
                    local rgn = con_rgn[x][y]
                    if rgn then
                        if #rgn == 2 then
                            pset(x - 1, y, 9)
                        else
                            pset(x - 1, y, 10)
                        end
                    end
                end
            )
        end
    end

    --[[ MAZE GENERATION FUNCTIONS ]]

    --[[
        grow_mz(str_pos)
        Grows a maze from a starting position using depth-first search

        Algorithm:
        1. Start at the given position and carve it
        2. Add it to the position list
        3. While there are positions to explore:
           - Choose next position based on method
           - Try each direction randomly
           - If we can carve in that direction (2 steps), do so
           - Add the new position to the list
           - If no direction works, remove current position
        4. This creates a maze with no loops (tree structure)
    ]]
    local function grow_mz(str_pos)
        add_rgn()
        local posn = {}
        crv(str_pos)
        add(posn, str_pos)

        while #posn > 0 do
            local index = chs_idx(#posn)
            local curr_pos = posn[index]
            for _, dir in pairs(shuffle(dir.card)) do
                local ngbPos, nxt_ngb_tl = {
                    x = curr_pos.x + dir.x,
                    y = curr_pos.y + dir.y
                },
                {
                    x = curr_pos.x + dir.x * 2,
                    y = curr_pos.y + dir.y * 2
                }
                if can_crv(ngbPos) and can_crv(nxt_ngb_tl) then
                    crv(ngbPos)
                    crv(nxt_ngb_tl)
                    add(posn, nxt_ngb_tl)
                    if draw then draw_mz() end
                    index = nil
                    break
                end
            end
            if index then
                del(posn, curr_pos)
            end
        end
    end

    --[[
        grow_mzs()
        Grows mazes from all valid starting positions
        Only starts from positions that are walls and follow the grid pattern
        This ensures complete maze coverage
    ]]
    local function grow_mzs()
        for x = brd, mz_w, 2 do
            for y = brd, mz_h, 2 do
                local pos = { x = x, y = y }
                if is_wall(pos) then
                    grow_mz(pos)
                end
            end
        end
    end

    --[[
        add_rms()
        Adds rectangular rooms to the maze

        Algorithm:
        1. Try to place rooms up to 'tries' times
        2. Generate random room size (minimum 5x5, can be rectangular)
        3. Check if room overlaps with existing rooms
        4. If no overlap, carve the room and assign it to a new region
        5. Store room information in chambers array

        This creates open areas that contrast with the maze corridors
    ]]
    local function add_rms()
        local rms = {}
        for i = 0, tries do
            local size = (int_rnd(2 + xtrsz) + 2) * 2 + 1
            local recty = int_rnd(size / 2) * 2
            local w, h = size, size
            if one_in(2) then
                w += recty
            else
                h += recty
            end
            local x = int_rnd((mz_w - w) / 2) * 2 + brd
            local y = int_rnd((mz_h - h) / 2) * 2 + brd
            local rm = { x = x, y = y, w = w, h = h }
            local overlaps = false
            for other in all(rms) do
                if dst_to(rm, other) <= 0 then
                    overlaps = true
                    break
                end
            end
            if not overlaps then
                add(rms, rm)
                add_rgn()
                chambers[cr_rgn] = {}
                for pos in all(get_all_posn(rm)) do
                    crv(pos)
                    add(chambers[cr_rgn], pos)
                end
                if draw then draw_mz() end
            end
        end
    end

    --[[
        conn_rgn()
        Connects all regions to ensure the maze is fully accessible

        Algorithm:
        1. Find all potential connection points (walls between different regions)
        2. Visualize regions and connections if drawing is enabled
        3. While there are unmerged regions:
           - Choose a random connection point
           - Create a junction at that point
           - Merge the connected regions
           - Remove nearby redundant connections
           - Optionally add extra connections for variety
        4. This ensures the maze is fully connected with no isolated areas
    ]]
    local function conn_rgn()
        if draw then draw_rgn() end

        -- Find all potential connection points
        foreach_2darr(
            mz, function(x, y)
                if is_wall({ x = x, y = y }) then
                    local _rgn = {}
                    for _, dir in pairs(dir.card) do
                        local ngbPos = {
                            x = x + dir.x,
                            y = y + dir.y
                        }
                        if in_bounds(ngbPos) then
                            local _region = rgn[ngbPos.x][ngbPos.y]
                            if _region and not contains(_rgn, _region) then
                                add(_rgn, _region)
                            end
                        end
                    end
                    if #_rgn >= 2 then
                        con_rgn[x][y] = _rgn
                    end
                end
            end
        )

        if draw then
            draw_connections()
        end

        local cons = {}
        -- {{ x, y }}

        -- Collect all connection points
        foreach_2darr(
            mz, function(x, y)
                if con_rgn[x][y] then
                    add(cons, { x = x, y = y })
                end
            end
        )

        -- Initialize region tracking
        local mgd_rgns, un_mgd_rgns = {}, {}
        for i = 1, cr_rgn do
            mgd_rgns[i] = i
            un_mgd_rgns[i] = i
        end

        -- Connect regions until all are merged
        while #un_mgd_rgns > 1 do
            local conn = get_rnd_item(cons)

            add_junc(conn)

            local rgn = do_map(
                con_rgn[conn.x][conn.y], function(region)
                    return mgd_rgns[region]
                end
            )
            local dest, sources = rgn[1], slice(rgn, 2)

            -- Merge regions
            for i = 1, cr_rgn do
                if contains(sources, mgd_rgns[i]) then
                    mgd_rgns[i] = dest
                end
            end

            for source in all(sources) do
                del(un_mgd_rgns, source)
            end

            -- Remove redundant connections and add variety
            rmv_where(
                cons, function(pos)
                    if dst_btw(conn, pos) < 2 then
                        return true
                    end
                    local rgn = do_map(
                        con_rgn[pos.x][pos.y], function(region)
                            return mgd_rgns[region]
                        end
                    )
                    rgn = rmv_dup(rgn)
                    if #rgn > 1 then
                        return false
                    end
                    if one_in(xtrconn) then
                        add_junc(pos)
                    end
                    return true
                end
            )

            if draw then draw_mz() end
        end
    end

    --[[
        rmv_dends()
        Removes dead ends to create more interesting maze layouts

        Algorithm:
        1. Find all dead ends (positions with only one exit)
        2. While we have more dead ends than the target number:
           - For each dead end, check if it's still a dead end
           - If so, fill it with a wall and add its neighbor to dead ends list
        3. Mark remaining dead ends as exit tiles
        4. This creates more complex paths and reduces linear corridors
    ]]
    local function rmv_dends()
        local done = false

        -- Find all dead ends
        foreach_2darr(
            mz, function(x, y)
                if not is_wall({ x = x, y = y }) then
                    local exits = 0
                    for _, dir in pairs(dir.card) do
                        local ngbPos = {
                            x = x + dir.x,
                            y = y + dir.y
                        }
                        if in_bounds(ngbPos) then
                            if not is_wall(ngbPos) then
                                exits += 1
                            end
                        end
                    end
                    if exits == 1 then
                        add_dend({ x = x, y = y })
                    end
                end
            end
        )

        -- Remove dead ends until we reach the target number
        while #dd_ends > exits do
            for _, pos in pairs(dd_ends) do
                local x, y, paths = pos.x, pos.y, {}
                for _, dir in pairs(dir.card) do
                    local ngbPos = {
                        x = x + dir.x,
                        y = y + dir.y
                    }
                    if in_bounds(ngbPos) then
                        if not is_wall(ngbPos) then
                            add(paths, ngbPos)
                        end
                    end
                end
                if #paths == 1 then
                    fill({ x = x, y = y })
                    add_dend(paths[1])
                    if draw then draw_mz() end
                end
                del(dd_ends, pos)
            end
        end

        -- Mark remaining dead ends as exits
        for _, pos in pairs(dd_ends) do
            set_tl(pos, xt_tl)
        end
    end

    --[[ MAIN GENERATION SEQUENCE ]]
    -- 1. Add rooms first (creates open areas)
    add_rms()
    -- 2. Generate mazes in remaining areas
    grow_mzs()
    -- 3. Connect all regions to ensure accessibility
    conn_rgn()
    -- 4. Remove excess dead ends for better layout
    rmv_dends()

    -- Return the generated maze and room information
    return mz, chambers
end