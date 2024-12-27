-- Copyright (c) 2024 Daniele Tabanella under the MIT license

--2220
--17919

function make_maze(cfg)
    -- Constants
    local draw = cfg.draw or false
    local method = cfg.method or 3
    -- chose_random = 1, chose_oldest = 2, chose_newest = 3
    local brd = 1
    local hasbrd = cfg.hasbrd or true
    -- 1 no brd
    local w = cfg.w or 128
    local h = cfg.h or 64
    local mz_w = w - brd
    local mz_h = h - brd
    local chambers = {}
    if hasbrd then
        brd = 2
        mz_w = w - 1
        mz_h = h - 1
    end

    local tries = 1000
    -- number of rooms to try, the greater the number, the more rooms
    local xtrsz = cfg.xtrsz or 1
    local xtrconn = cfg.xtrconn or 20
    local exits = cfg.exits or 2

    -- Tiles
    local wl_tl = cfg.wl_tl or 1
    local flr_tl = cfg.flr_tl or 7
    local op_tl = cfg.op_tl or 12
    local csd_tl = cfg.csd_tl or 8
    local xt_tl = cfg.xt_tl or 9

    local maze = mk2darr(mz_w, mz_h, wl_tl)
    local rgn = mk2darr(mz_w, mz_h, nil)
    local con_rgn = mk2darr(mz_w, mz_h, nil)
    local dd_ends = {}

    local cr_rgn = 0

    local function chose_index(ceil)
        if method == 1 then
            return flr(rnd(ceil)) + 1
        elseif method == 2 then
            return 1
        elseif method == 3 then
            return ceil
        end
    end

    local function in_bounds(pos)
        return pos.x <= mz_w and pos.y <= mz_h and pos.x > 0 and pos.y > 0
    end

    local function is_wall(pos)
        return maze[pos.x][pos.y] == wl_tl
    end

    local function is_path(pos)
        return maze[pos.x][pos.y] == flr_tl
    end

    local function set_tl(pos, tl_ty)
        maze[pos.x][pos.y] = tl_ty
    end

    local function carve(pos)
        set_tl(pos, flr_tl)
        rgn[pos.x][pos.y] = cr_rgn
    end

    local function fill(pos)
        maze[pos.x][pos.y] = wl_tl
    end

    local function can_carve(pos)
        return in_bounds(pos) and is_wall(pos)
    end

    local function add_rgn()
        cr_rgn += 1
    end

    local function add_dend(pos)
        add(dd_ends, pos)
    end

    local function add_junc(pos)
        if one_in(4) then
            if one_in(3) then
                set_tl(pos, op_tl)
            else
                set_tl(pos, flr_tl)
            end
        else
            set_tl(pos, csd_tl)
        end
    end

    local function draw_maze()
        if rnd() > 0.9 then
            foreach_2darr(
                maze, function(x, y)
                    pset(x - 1, y - 1, maze[x][y])
                end
            )
        end
    end

    local function draw_rgn()
        foreach_2darr(
            maze, function(x, y)
                local region = rgn[x][y]
                -- color between 0 and 15
                local color = region and (region % 15) + 1 or 0
                if color == 9 or color == 10 then
                    color = 11
                end
                pset(x - 1, y - 1, color)
            end
        )
    end

    local function draw_connections()
        if rnd() > 0.9 then
            foreach_2darr(
                maze, function(x, y)
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

    local function grow_maze(str_pos)
        add_rgn()
        local posn = {}
        carve(str_pos)
        add(posn, str_pos)

        while #posn > 0 do
            local index = chose_index(#posn)
            local currentPos = posn[index]
            for _, direction in pairs(shuffle(direction.cardinal)) do
                local ngbPos = {
                    x = currentPos.x + direction.x,
                    y = currentPos.y + direction.y
                }
                local nextNeighborTile = {
                    x = currentPos.x + direction.x * 2,
                    y = currentPos.y + direction.y * 2
                }
                if can_carve(ngbPos) and can_carve(nextNeighborTile) then
                    carve(ngbPos)
                    carve(nextNeighborTile)
                    add(posn, nextNeighborTile)
                    if draw then draw_maze() end
                    index = nil
                    break
                end
            end
            if index then
                del(posn, currentPos)
            end
        end
    end

    local function grow_mazes()
        for x = brd, mz_w, 2 do
            for y = brd, mz_h, 2 do
                local pos = { x = x, y = y }
                if is_wall(pos) then
                    grow_maze(pos)
                end
            end
        end
    end

    local function add_rooms()
        local rooms = {}
        for i = 0, tries do
            local size = int_rnd(2 + xtrsz) * 2 + 5
            local recty = int_rnd(1 + size / 2) * 2
            local w = size
            local h = size
            if one_in(2) then
                w += recty
            else
                h += recty
            end
            local x = int_rnd((mz_w - brd - w) / 2) * 2 + brd
            local y = int_rnd((mz_h - brd - h) / 2) * 2 + brd
            local room = { x = x, y = y, w = w, h = h }
            local overlaps = false
            for other in all(rooms) do
                if dst_to(room, other) <= 0 then
                    overlaps = true
                    break
                end
            end
            if not overlaps then
                add(rooms, room)
                add_rgn()
                chambers[cr_rgn] = {}
                for pos in all(get_all_posn(room)) do
                    carve(pos)
                    add(chambers[cr_rgn], pos)
                end
                if draw then draw_maze() end
            end
        end
    end

    local function connect_rgn()
        if draw then draw_rgn() end

        foreach_2darr(
            maze, function(x, y)
                if is_wall({ x = x, y = y }) then
                    local _rgn = {}
                    for _, direction in pairs(direction.cardinal) do
                        local ngbPos = {
                            x = x + direction.x,
                            y = y + direction.y
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

        foreach_2darr(
            maze, function(x, y)
                if con_rgn[x][y] then
                    add(cons, { x = x, y = y })
                end
            end
        )

        local mgd_rgns = {}
        local un_mgd_rgns = {}
        for i = 1, cr_rgn do
            mgd_rgns[i] = i
            un_mgd_rgns[i] = i
        end

        while #un_mgd_rgns > 1 do
            local connector = get_rnd_item(cons)

            add_junc(connector)

            local rgn = do_map(
                con_rgn[connector.x][connector.y], function(region)
                    return mgd_rgns[region]
                end
            )

            local dest = rgn[1]

            local sources = slice(rgn, 2)

            for i = 1, cr_rgn do
                if contains(sources, mgd_rgns[i]) then
                    mgd_rgns[i] = dest
                end
            end

            for source in all(sources) do
                del(un_mgd_rgns, source)
            end

            rmv_where(
                cons, function(pos)
                    if dst_btw(connector, pos) < 2 then
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

            if draw then draw_maze() end
        end
    end

    local function rmv_dends()
        local done = false

        -- add dead ends
        foreach_2darr(
            maze, function(x, y)
                if not is_wall({ x = x, y = y }) then
                    local exits = 0
                    for _, direction in pairs(direction.cardinal) do
                        local ngbPos = {
                            x = x + direction.x,
                            y = y + direction.y
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

        while #dd_ends > exits do
            for _, pos in pairs(dd_ends) do
                local x, y = pos.x, pos.y
                local paths = {}
                for _, direction in pairs(direction.cardinal) do
                    local ngbPos = {
                        x = x + direction.x,
                        y = y + direction.y
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
                    if draw then draw_maze() end
                end
                del(dd_ends, pos)
            end
        end

        for _, pos in pairs(dd_ends) do
            set_tl(pos, xt_tl)
        end
    end

    add_rooms()
    grow_mazes()
    connect_rgn()
    rmv_dends()

    return maze, chambers
end