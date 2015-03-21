-- 
-- TurntableG GUI Callback Functions
--

-- Load default values from default file
function defaultLoadCallback(component, event)
  if file_exists(defaultsName) then
    local tempTable = tableLoad(defaultsName)
    for item, value in pairs(tempTable["__octane.shadow"]) do
      defaultsTable[item] = value
    end
  else
    showError("No Defaults File!", "The script is not able to find the defaults file, use the save button to create one.", false)
  end
end

-- Save default values into default file
function defaultSaveCallback(component, event)
  -- store default values in table
--  defaultsTable["frameSlider"] = frameSlider:getProperties().value
--  defaultsTable["durationSlider"] = durationSlider:getProperties().value
--  defaultsTable["frameRateSlider"] = frameRateSlider:getProperties().value
--  defaultsTable["samplesSlider"] = samplesSlider:getProperties().value
--  defaultsTable["degSlider"] = degSlider:getProperties().value
--  defaultsTable["offsetSlider"] = offsetSlider:getProperties().value
--  defaultsTable["spiralSlider"] = spiralSlider:getProperties().value
--  defaultsTable["shutterSlider"] = shutterSlider:getProperties().value
--  defaultsTable["previewSamplesSlider"] = previewSamplesSlider:getProperties().value

  -- save table to defaults file
  tableSave(defaultsTable, defaultsName)

  -- tell the user that the settings have been saved
  octane.gui.showDialog
    {
        type  = octane.gui.dialogType.BUTTON_DIALOG,
        icon = octane.gui.dialogIcon.INFO,
        title = "Save Settings",
        text  = "Completed!",
    }
end

-- reset default values
function defaultResetCallback(component, event)
    frameSlider:updateProperties{ value = 250 }
    durationSlider:updateProperties{ value = 10 }
    frameRateSlider:updateProperties{ value = 25 }
    samplesSlider:updateProperties{ value = 400 }
    degSlider:updateProperties{ value = 360 }
    offsetSlider:updateProperties{ value = 0 }
    spiralSlider:updateProperties{ value = 0 }
    shutterSlider:updateProperties{ value = 0 }
    previewSamplesSlider:updateProperties{ value = 20 }
end

-- A render target has been choosen in the drop down, now 
-- see if it matches the current selected target node.  If they match
-- then do nothing.  If they do not match then set RT_NODE and CAM_NODE to
-- new nodes.
function targetDropDownCallback(component, event)
    if renderTarget ~= "" and RT_NODE:getProperties().name ~= renderTarget then
        -- find the index of the choosen render target node
        local index = -1
        for i, item in ipairs(octane.nodegraph.getRootGraph():getOwnedItems()) do
            if item:getProperties().name == renderTarget then
                index = i
                break
            end
        end
        newCopies = SCENE_GRAPH:copyFrom(octane.nodegraph.getRootGraph():getOwnedItems())
        RT_NODE = newCopies[index]
        CAM_NODE = RT_NODE:getConnectedNode(octane.P_CAMERA)
        -- re-initialize the UI
        initGui(CAM_NODE)
    end
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
