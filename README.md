lua-line-format
===============

*Nothing to see here.*


Brainstorm
----------

```lua
-- Widgets:
Static'abc' or 'abc'
AnsiEscape'red'
Attribute'unimportant'
Attribute'emphasis' -> e.g. bold text
Block(...):with(...)
Optional(...)
Fill'.'
Bar(0.5)
Icon'ellipsis'
Icon'ok'

render(Icon'sandclock',
       Block(Bar(0.5),
             ' downloading'):with(Color'red'))

set_max_line_length(80)

attributes = {unimportant = AnsiEscape'black',
              emphasis    = AnsiEscape'bold'}

icons = {ellipsis = '...',
         sandclock = '...'}
```


API
---

### Module `line-format`
#### Function `.render(...)`
#### Class `.Static`
#### Class `.Attribute`
#### Class `.Icon`
#### Class `.Fill`
#### Class `.Bar`
#### Class `.Block`
#### Class `.Optional`
#### Class `.AnsiEscape`
