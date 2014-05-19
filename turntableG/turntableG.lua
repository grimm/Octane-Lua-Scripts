-- Renders a turntable animation and saves it on disk. To use it, select the desired
-- render target and then run the script.
-- 
-- @description Renders a turntable animation and saves it to disk.
-- @author      Thomas Loockx, Roeland, Jason Grimes
-- @shortcut    ctrl + t
-- @version     0.10
--

--local version = "0.1"			-- Initial version by Thomas and Roeland
--local version = "0.2"			-- Added spiral function and seperated functions into
					-- required files. Added tooltips to buttons.
--local version = "0.3"			-- Added shutter time slide and script exit button.
--local version = "0.4"			-- The spiral and shutter sliders get disabled on render.
                                        -- Added drop down render target combo box.
--local version = "0.5"			-- Added the standard Octane script header and set the
                                        -- shortcut key to alt + t. Added load and save defaults
                                        -- buttons.
--local version = "0.6"			-- Fixed the defaults load button so that is checks for
                                        -- the defaults file before trying to load it. 
--local version = "0.7"			-- Added reset button to reset all settings to their 
                                        -- original values.  Also added live preview function that
                                        -- runs the animation without saving any frames.  A
                                        -- samples/px is included as well so the user can set
                                        -- a different value from the main samples slider.
--local version = "0.8"			-- Added Thomas' fix for linked nodes. Made some default
                                        -- setting more resonable per pixelrushes' suggestion.
                                        -- Fixed the load and save defaults so they save the defaults
                                        -- file in the user defined scripts directory.  Fixed the
                                        -- stop button being disabled when you switch render targets.
                                        -- The script now uses the improved node find function.
                                        -- Changed the limit on the target offset to 16000, hopefully
                                        -- that will be large enough. :)  Made general bug fixes
                                        -- and simplified the code somewhat.
--local version = "0.9"			-- Updated the script to work in Octane version 1.28
                                        -- Fixed render target problems when exiting the script.
--local version = "0.10"		-- Updated the load and save defaults functions to use binding.
                                        -- Fixed render targets so it can handle most graph situations.
                                        -- Added advanced tab to camera movement for advanced options.
local version = "1.00"			-- Updated the script so it works with Octane 1.5.  Changed
					-- the shortcut to ctrl+t so it will work better on Windows.
					-- Changed the upper bound for the frames slider to 14400.
					
-- directory for required files and defaults
filePath = "turntableG_files/"

-- create the global defaults
defaultsTable = octane.gui.createPropertyTable()
--defaultsTable = {}
scriptDir = octane.file.getSpecialDirectories()["userScriptDirectory"]
defaultsName = scriptDir.."/turntableG_files/turntableG_defaults"
OUT_PATH = nil      -- global variable that holds the output path

comboBoxTable = {}
currentTarget = nil

-- load Octane ui componets
ui = require(filePath.."uiG")

-- load the gui
require(filePath.."turntableG_gui")

-- load the helper functions
require(filePath.."turntableG_helpers")

-- load the callback functions
require(filePath.."turntableG_callbacks")

-- load the animation functions
require(filePath.."turntableG_anim")

-- window that holds all components
local turntableWindow = octane.gui.create
{ 
    type     = octane.gui.componentType.WINDOW,
    text     = "TurntableG Animation V"..version.." Octane 1.5",
    children = { layoutGrp },
    width    = layoutGrp:getProperties().width,
    height   = layoutGrp:getProperties().height,
}

-- Find the render target nodes
renderTargets, renderTargNames = getAllrendertargets()
local currSelection = octane.project.getSelection()[1]

if currSelection == nil then
  currentTarget = renderTargets[1]
elseif currSelection.type == octane.NT_RENDERTARGET then
  currentTarget = currSelection
else
  currentTarget = renderTargets[1]
end

-- callback handling the GUI elements
local function guiCallback(component, event)
    local index = -1
    if component == durationSlider then 
        -- if the duration of the animation changes, update the #frames
        local frames = math.ceil(durationSlider:getProperties().value * frameRateSlider:getProperties().value)
        frameSlider:updateProperties{ value = frames }
    elseif component == frameRateSlider then 
        -- if the frame rate changes, update the #frames
        local frames = math.ceil(durationSlider:getProperties().value * frameRateSlider:getProperties().value)
        frameSlider:updateProperties{ value = frames }
    elseif component == frameSlider then 
        -- if the #frames changes, update the duration of the animation
        local duration = frameSlider:getProperties().value / frameRateSlider:getProperties().value
        durationSlider:updateProperties{ value = duration }
    elseif component == fileChooseButton then 
        -- choose an output file
        local ret = octane.gui.showDialog
        {
            type      = octane.gui.dialogType.FILE_DIALOG,
            title     = "Choose the output file",
            wildcards = "*.png",
            save      = true,
        }
        -- if a file is chosen
        if ret.result ~= "" then
            renderButton:updateProperties{ enable = true } 
            fileEditor:updateProperties{ text = ret.result }
            OUT_PATH = ret.result
        else
            renderButton:updateProperties{ enable = false } 
            fileEditor:updateProperties{ text = "" }
            OUT_PATH = nil
        end
    elseif component == renderButton then 
        -- NOTE: here we create a fresh copy just before we start rendering.
        SCENE_GRAPH, RT_NODE, CAM_NODE = getSceneCopy()
        startRender(SCENE_GRAPH, RT_NODE, CAM_NODE, OUT_PATH, true)

    elseif component == livePreviewButton then 
        -- NOTE: here we create a fresh copy just before we start rendering.
        SCENE_GRAPH, RT_NODE, CAM_NODE = getSceneCopy()
        startRender(SCENE_GRAPH, RT_NODE, CAM_NODE, OUT_PATH, false)

    elseif component == renderTargetDropDown then 
        local comboTarget = renderTargetDropDown.selectedIx
        -- A render target has been choosen in the drop down, now 
        -- see if it matches the current selected target node.  If they match
        -- then do nothing.  If they do not match then set RT_NODE and CAM_NODE to
        -- new nodes.
        if renderTargets[comboTarget] ~= currentTarget then
            currentTarget = renderTargets[comboTarget]
            -- find the choosen render target node, and copy the scene
            SCENE_GRAPH, RT_NODE, CAM_NODE = getSceneCopy()
            -- re-initialize the UI
            initGui(CAM_NODE)
        end

    elseif component == stopButton then
        cancelRender()

    elseif component == exitButton then
        cancelRender()
        turntableWindow:closeWindow()

    elseif component == turntableWindow then
        -- when the window closes, cancel rendering
        if event == octane.gui.eventType.WINDOW_CLOSE then
            cancelRender()
        end
    end
end

-- Get the render target and camera in global variables
SCENE_GRAPH, RT_NODE, CAM_NODE = getSceneCopy()

-- Initialize the render targets combo box
local renderTargKey = get_key(renderTargNames, currentTarget.name)
renderTargetDropDown:updateProperties { items = renderTargNames, selectedIx = renderTargKey }

-- initialize the UI
initGui(CAM_NODE)
renderButton:updateProperties{ enable = false }
stopButton:updateProperties{ enable = false }

-- hookup the callback with all the GUI elements
durationSlider:updateProperties        { callback = guiCallback          }
frameRateSlider:updateProperties       { callback = guiCallback          }
frameSlider:updateProperties           { callback = guiCallback          }
fileChooseButton:updateProperties      { callback = guiCallback          }
renderButton:updateProperties          { callback = guiCallback          }
stopButton:updateProperties            { callback = guiCallback          }
exitButton:updateProperties            { callback = guiCallback          }
renderTargetDropDown:updateProperties  { callback = guiCallback          }
defaultLoadButton:updateProperties     { callback = defaultLoadCallback  }
defaultSaveButton:updateProperties     { callback = defaultSaveCallback  }
defaultResetButton:updateProperties    { callback = defaultResetCallback }
livePreviewButton:updateProperties     { callback = guiCallback          }
turntableWindow:updateProperties       { callback = guiCallback          }

-- the script will block here until the window closes
turntableWindow:showWindow()
