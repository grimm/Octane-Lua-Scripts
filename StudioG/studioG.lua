-- Creates a studio environment around a selected mesh and allows the user to
-- enable various lights surrounding it.
-- 
-- @description Creates a studio environment around a selected mesh
-- @author      Jason Grimes
-- @shortcut    alt + s
-- @version     0.1
--

local version = "0.1"	 -- Initial version
octaneVersion = "2.0"  -- Required Octane version

-- directory for required files and defaults
filePath = "studioG_files/"

-- Load the Grimm logo
local logoPath = octane.file.getSpecialDirectories()["userScriptDirectory"].."/"..filePath
logoG = octane.image.load(logoPath.."grimmavatar.png")

-- load the UI helper functions
ui = require(filePath.."ui")

-- load the GUI helper functions
require(filePath.."gui")

-- load the helper functions
require(filePath.."helpers")

-- load the calc functions
require(filePath.."calc")

-- Check for mesh object
sceneGraph = octane.project.getSceneGraph()
meshNodes = sceneGraph:findNodes(octane.NT_GEO_MESH, true)
if #meshNodes == 0 then  -- Can't find a mesh node prompt the user for one
	local dialog = octane.gui.showDialog
    {
      type      = octane.gui.dialogType.FILE_DIALOG,
      title     = "No mesh node, please choose a project to open:",
      wildcards = "*.ocs, *.orbx",
      save      = false,
    }
  -- if a file is chosen
  if dialog.result ~= "" then
  	if octane.project.load(dialog.result) then
      sceneGraph = octane.project.getSceneGraph()
      meshNodes = sceneGraph:findNodes(octane.NT_GEO_MESH, true)
  	else
  	  showError("Project Load Error", "An error occured while loading the project file "..dialog.result.."! exiting!", true)
  	end
  else
  	  showError("No Mesh", "I need a mesh to work with, exiting!", true)
  end
end

-- window that holds all components
local studioGWindow = octane.gui.create
{ 
    type     = octane.gui.componentType.WINDOW,
    text     = "StudioG Version "..version,
    children = { layoutGrp },
    width    = layoutGrp:getProperties().width,
    height   = layoutGrp:getProperties().height,
}

-- the script will block here until the window closes
studioGWindow:showWindow()
