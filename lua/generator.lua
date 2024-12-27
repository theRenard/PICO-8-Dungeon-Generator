-- Copyright (c) 2024 Daniele Tabanella under the MIT license

--2220
--17919

function make_mz(cfg)
    -- Constants
    local draw, mth = cfg.draw or false, cfg.mth or 3
    local brd, w, h = cfg.hasbrd == false and 1 or 2, cfg.w or 128, cfg.h or 64
    local mz_w, mz_h, chambers = w - 1, h - 1, {}
    local tries, xtrsz, xtrconn, exits = 1000, cfg.xtrsz or 1, cfg.xtrconn or 20, cfg.exits or 2

    -- Tiles
    local wl_tl, flr_tl, op_tl, csd_tl, xt_tl = cfg.wl_tl or 1, cfg.flr_tl or 7, cfg.op_tl or 12, cfg.csd_tl or 8, cfg.xt_tl or 9
    local mz, rgn, con_rgn, dd_ends, cr_rgn = mk2darr(mz_w, mz_h, wl_tl), mk2darr(mz_w, mz_h), mk2darr(mz_w, mz_h), {}, 0

    local function chs_idx(ceil)
        return mth == 1 and flr(rnd(ceil)) + 1 or mth == 2 and 1 or ceil
    end

    local function in_bounds(pos)
        return pos.x <= mz_w and pos.y <= mz_h and pos.x > 0 and pos.y > 0
    end

    local function is_wall(pos)
        return mz[pos.x][pos.y] == wl_tl
    end

    local function is_path(pos)
        return mz[pos.x][pos.y] == flr_tl
    end

    local function set_tl(pos, tl_ty)
        mz[pos.x][pos.y] = tl_ty
    end

    local function crv(pos)
        set_tl(pos, flr_tl)
        rgn[pos.x][pos.y] = cr_rgn
    end

    local function fill(pos)
        mz[pos.x][pos.y] = wl_tl
    end

    local function can_crv(pos)
        return in_bounds(pos) and is_wall(pos)
    end

    local function add_rgn()
        cr_rgn += 1
    end

    local function add_dend(pos)
        add(dd_ends, pos)
    end

    local function add_junc(pos)
        local tile_type = csd_tl
        if one_in(4) then
            tile_type = one_in(3) and op_tl or flr_tl
        end
        set_tl(pos, tile_type)
    end

    local function draw_mz()
        if rnd() > 0.9 then
            foreach_2darr(
                mz, function(x, y)
                    pset(x - 1, y - 1, mz[x][y])
                end
            )
        end
    end

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

    local function conn_rgn()
        if draw then draw_rgn() end

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

        foreach_2darr(
            mz, function(x, y)
                if con_rgn[x][y] then
                    add(cons, { x = x, y = y })
                end
            end
        )

        local mgd_rgns, un_mgd_rgns = {}, {}
        for i = 1, cr_rgn do
            mgd_rgns[i] = i
            un_mgd_rgns[i] = i
        end

        while #un_mgd_rgns > 1 do
            local conn = get_rnd_item(cons)

            add_junc(conn)

            local rgn = do_map(
                con_rgn[conn.x][conn.y], function(region)
                    return mgd_rgns[region]
                end
            )
            local dest, sources = rgn[1], slice(rgn, 2)

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

    local function rmv_dends()
        local done = false

        -- add dead ends
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

        for _, pos in pairs(dd_ends) do
            set_tl(pos, xt_tl)
        end
    end

    add_rms()
    grow_mzs()
    conn_rgn()
    rmv_dends()

    return mz, chambers
end