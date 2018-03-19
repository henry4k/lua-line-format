local function round_to_nearest_integer(value)
    local floor = math.floor(value)
    if value-floor < 0.5 then
        return floor
    else
        return floor+1
    end
end

local function render_bar(width, completion, blocks)
    local function block( completion )
        return blocks[round_to_nearest_integer((#blocks-1) * completion)+1]
    end

    local filled = width*completion
    local filled_floor = math.floor(filled)
    local filled_ceil  = math.ceil(filled)
    local half_filled = filled-filled_floor

    local buffer = {}

    local filled_block = block(1)
    table.insert(buffer, string.rep(block(1), filled_floor))

    if half_filled > 0 then
        table.insert(buffer, block(half_filled))
    end

    local empty_block = block(0)
    table.insert(buffer, string.rep(block(0), width-filled_ceil))

    return table.concat(buffer)
end

local predefined_blocks =
{
    simple = {' ', '='},
    unicode = {' ', '▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'}
}

return function(width, completion, blocks)
    if type(blocks) == 'string' then
        blocks = predefined_blocks[blocks]
    end
    assert(blocks)
    return render_bar(width, completion, blocks)
end
