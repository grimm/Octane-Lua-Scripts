-- 
-- UI functions module
--
local ui = {}

-- creates a text label and returns it
function ui.createLabel(text, width, height)
    return octane.gui.create
    { 
        type   = octane.gui.componentType.LABEL,    -- type of the component
        text   = text,                              -- text that appears on the label
        width  = width,                             -- width of the label in pixels
        height = height,                            -- height of the label in pixels
    }
end

-- creates a slider and returns it
function ui.createSlider(name, value, min, max, step, width, height, logarithmic)
    return octane.gui.create
    { 
        type        = octane.gui.componentType.SLIDER, -- type of the component
        name	    = name,			       -- name of the component
        width       = width,                           -- width of the slider in pixels
        height      = height,                          -- height of the slider in pixels
        value       = value,                           -- value of the slider
        minValue    = min,                             -- minimum value of the slider
        maxValue    = max,                             -- maximum value of the slider
        step        = step,                            -- interval between 2 discrete slider values
        logarithmic = logarithmic,		       -- Make slider logarithmic
    }
end

-- creates a button and returns it
function ui.createButton(name, text, width, height, tooltip)
    return octane.gui.create
    {
        type    = octane.gui.componentType.BUTTON,  -- type of the component
	name	= name,				    -- name of the component
        text    = text,                             -- button text
        width   = width,                            -- width in pixels
        height  = height,                           -- height in pixels
        tooltip  = tooltip,                         -- tooltip text
    }
end

-- creates a numeric input and returns it
function ui.createNumeric(value, min, max, step)
    return octane.gui.create
    {
        type     = octane.gui.componentType.NUMERIC_BOX, -- type of the component
        width    = 80,                                   -- width of the slider in pixels
        height   = 20,                                   -- height of the slider in pixels
        value    = value,                                -- value of the slider
        minValue = min,                                  -- minimum value of the slider
        maxValue = max,                                  -- maximum value of the slider
        step     = step,                                 -- interval between 2 discrete slider values
    }
end

-- creates a combo_box drop_down and returns it
function ui.createDrop_down(name, items, width, height, selected)
    return octane.gui.create
    {
        type         = octane.gui.componentType.COMBO_BOX,  -- type of the component
        name         = name,				    -- name of component
        items        = items,				    -- array of item to show in combo-box
        width        = width,				    -- width in pixels
        height       = height,				    -- height in pixels
        editable     = false, 				    -- default to non-editable
        selectedItem = selected, 			    -- default item selection
    }
end

-- creates a group and retuns it
function ui.createGroup(name, children, border, rows, cols, width, height, text, padding, inset, center)
    return octane.gui.create
    {
	type		= octane.gui.componentType.GROUP,   -- type of the component
	name		= name,				    -- name of component
	children	= children,			    -- list of children components
	border		= border,			    -- boolean flag to show border
	rows		= rows,				    -- number of rows in group grid
	cols		= cols,				    -- number of cols in group grid
	width		= width,			    -- width in pixels
	height		= height,			    -- height in pixels
	text		= text,				    -- text to display at top of group
	padding		= padding,			    -- internal padding in each cell
	inset		= inset,			    -- inset of the group component
    centre		= center,			    -- center the group
    }
end

-- creates a set of tabs and returns it
function ui.createTabs(headers, children)
    return octane.gui.create
    {
    type       = octane.gui.componentType.TABS,
    children   = children,
    header     = headers,
    }
end

-- creates a bitmap widget and returns it
function ui.createBitmap(name, image, width, height)
  return octane.gui.create
  {
    type        = octane.gui.componentType.BITMAP,  -- type of component
    name        = name,                             -- name of component
    image       = image,                            -- image to display
    width       = width,                            -- image width in pixels
    height      = height,                           -- image height in pixels
  }
end

return ui
