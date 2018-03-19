local utf8_len
if utf8 then
    utf8_len = utf8.len
else
    utf8_len = function(str)
        local len = #str
        for s, e in str:gmatch('()[\xC2-\xF4][\x80-\xBF]*()') do
            len = len - ((e-s)-1)
        end
        return len
    end
end

local RichText = {}

local empty_rich_text = setmetatable({str = '', charCount = 0}, RichText)

local function is_rich_text(value)
    return getmetatable(value) == RichText
end

local function create_rich_text(str, char_count)
    if is_rich_text(str) then
        assert(not char_count)
        return str
    end

    str = tostring(str)
    char_count = char_count or utf8_len(str)
    assert(char_count >= 0)
    assert(char_count <= #str)
    return setmetatable({str = str, char_count = char_count}, RichText)
end

function RichText:__newindex()
    error('Modification not allowed.')
end

function RichText:__concat(other)
    other = create_rich_text(other)
    return create_rich_text(self.str .. other.str,
                            self.char_count + other.char_count)
end

function RichText:__len()
    return self.char_count
end

function RichText:__tostring()
    return self.str
end

local function merge(...)
    local strings = {}
    local char_count = 0
    for _, value in ipairs{...} do
        value = create_rich_text(value)
        strings[#strings+1] = value.str
        char_count = char_count + value.char_count
    end
    return create_rich_text(table.concat(strings), char_count)
end

return setmetatable({is_rich_text = is_rich_text,
                     merge = merge,
                     empty = empty_rich_text },
                    {__call = function( self, ... )
                                   return create_rich_text(...)
                               end})
