local function is_integer(value)
    return math.floor(value) == value
end

local widgets = {}

---
-- @param size
-- Available line width.  The algorithm tries to fill the whole area, but the
-- rendered string might still be longer or shorter.
--
-- @param widgets
-- A list of widgets that shall be rendered.
--
-- @param properties
-- TODO
--
function widgets.render(size, widgets, properties)
    local total_basis = 0
    local total_grow = 0
    local widget_basises = {} -- this sounds weird
    for i, widget in ipairs(widgets) do
        local widget_basis = widget:calcBasis(properties)
        widget_basises[i] = widget_basis
        total_basis = total_basis + widget_basis
        total_grow  = total_grow  + widget.grow
    end

    if total_grow == 0 then
        total_grow = 1 -- prevent division by zero
    end

    local free = 0
    if total_basis < size then
        free = size - total_basis
    end

    local non_overlapping_free = 0
    for _, widget in ipairs(widgets) do
        local widget_free = free*(widget.grow/total_grow)
        non_overlapping_free = non_overlapping_free + math.floor(widget_free)
    end
    local overlapping_free = free - non_overlapping_free
    assert(is_integer(overlapping_free), 'overlapping_free is not an integer!')
    --local alt = free - math.floor(free/total_grow) * total_grow
    --assert(overlapping_free == alt, 'alternative compution is wrong!')

    local round
    local even = (overlapping_free % 2) == 0
    if even then
        round = math.ceil
    else
        round = math.floor
    end

    local buffer = {}
    for i, widget in ipairs(widgets) do
        local widget_size = widget_basises[i] + free*(widget.grow/total_grow)
        if not is_integer(widget_size) then
            widget_size = round(widget_size)

            -- Alternate ceil and floor:
            if round == math.ceil then
                round = math.floor
            else
                round = math.ceil
            end
        end
        table.insert(buffer, widget:render(widget_size, properties))
    end
    return table.concat(buffer)
end


local Widget = {}
Widget.__index = Widget

function Widget:calc_basis()
    return self.basis
end

local function create_widget(t)
    return setmetatable(t or {}, Widget)
end


local function render_static(widget)
    return widget.text
end
function widgets.Static(text)
    return create_widget{basis = #text,
                         grow = 0,
                         text = text,
                         render = render_static}
end
function widgets.AnsiEscape( ... )
    local code = table.concat{string.char(27), '[', table.concat({...}, ';'), 'm'}
    return {basis = 0,
            grow = 0,
            text = code,
            render = render_static}
end


local function render_property(widget, _, properties)
    return tostring(properties[widget.property_name])
end
local function calc_property_length(widget, properties)
    return #render_property(widget, 0, properties)
end
function widgets.Property(property_name)
    return create_widget{calc_basis = calc_property_length,
                         grow = 0,
                         property_name = property_name,
                         render = render_property}
end


local function render_nothing()
    return ''
end
function widgets.Nothing()
    return create_widget{basis = 0,
                         grow = 0,
                         render = render_nothing}
end


local function render_fill_pattern(widget, size)
    return string.rep(widget.fill_char, size)
end
function widgets.FillWith(c, v)
    return create_widget{basis = 0,
                         grow = v or 1,
                         fill_char = c,
                         render = render_fill_pattern}
end
function widgets.Fill( v )
    return widgets.FillWith(' ', v)
end


return widgets
