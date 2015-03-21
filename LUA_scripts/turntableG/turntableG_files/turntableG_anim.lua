--
-- Turntable animation functions
--

-- Returns copies of the original scene graph, the camera node and the rendertarget.
-- This prevents us from modifying the original scene.
function getSceneCopy()
    local copyScene = octane.nodegraph.createRootGraph("Project Copy")
    local copyRt    = copyScene:copyFromGraph(octane.project.getSceneGraph(), { currentTarget })[1]

    -- check if the copied node is a render target
    if not copyRt or copyRt.type ~= octane.NT_RENDERTARGET then
        showError("TurntableG Error!","no render target selected", true)
    end

    -- check if a thin lens camera is connected to the render target
    local copyCam = copyRt:getInputNode(octane.P_CAMERA)
    if not copyCam or copyCam.type ~= octane.NT_CAM_THINLENS then
        showError("TurntableG Error!","no thinlens camera connected to the render target", true)
    end

    return copyScene, copyRt, copyCam
end

-- Return a list of all render targets
function getAllrendertargets()
    local renderTargets = octane.project.getSceneGraph():findNodes(octane.NT_RENDERTARGET, true)
    local renTargList = {}
    local renTargNames = {}

    for i, item in ipairs(renderTargets) do
        renTargList[#renTargList + 1] = item
        renTargNames[#renTargNames + 1] = item.name
    end

    return reverseTable(renTargList), reverseTable(renTargNames)
end

-- reverse table
function reverseTable(table)
    local size = #table
    local newTable = {}

    for i,v in ipairs ( table ) do
        newTable[size + 1 - i] = v
    end

    return newTable
end

-- Set camera animator
function setCamAnimator(camNode, rotAngle, offsetAngle, targetDistance, nbFrames)
    -- get the original camera settings
    local origCamTarget   = camNode:getPinValue(octane.P_TARGET)
    local origCamPosition = camNode:getPinValue(octane.P_POSITION)
    local origCamUp       = camNode:getPinValue(octane.P_UP)
    local origViewDir     = octane.vec.normalized(octane.vec.sub(origCamTarget, origCamPosition))
    local spiralAmount    = spiralSlider.value
    local cameraPathAngle = math.rad(cameraPathAngleSlider.value)

    -- define new camera path angle if set
    if cameraPathAngle ~= 0 then
      origCamUp = octane.vec.rotate(origCamUp, origViewDir, cameraPathAngle)
    end

    -- calculate the new camera position for each frame
    local positions = {}
    for i=0,nbFrames-1 do
        -- calculate the angle of rotation for this frame
        local angle = math.rad( (i / nbFrames) * rotAngle + offsetAngle )
        -- rotate the viewing direction around the up vector
        local newViewDir = octane.vec.rotate(origViewDir, origCamUp, angle)
        -- Adjust the target distance if spiralAmount is set
        if spiralAmount ~= 0 then
            targetDistance = targetDistance + spiralAmount
            if targetDistance < 0 then targetDistance = 0 end
        end
        -- scale the new view dir with the target distance
        newViewDir = octane.vec.scale(newViewDir, targetDistance)
        -- calculate the new camera position
        local newCamPosition = octane.vec.sub(origCamTarget, newViewDir)
        -- store the new camera position
        table.insert(positions, newCamPosition)
    end

    -- animate the camera position
    camNode:getConnectedNode(octane.P_POSITION):setAnimator(octane.A_VALUE, { 0 }, positions, 1 / nbFrames)
end

-- creates a save path for the current frame
function createSavePath(path, frame)
    local file = octane.file.getFileName(path)

    -- strip png extension
    file = file:gsub("%.png$", "")

    -- split file into prefix, sequence number and suffix
    -- make sure the sequence number is in the final file name part
    local prefix, sequenceMatch, suffix = file:match("(.-)(%d+)([^\\/]*)$")
        
    -- if the file name doesn't contain a sequence number, the match fails
    -- so just assume it is all prefix.
    if sequenceMatch == nil then
        prefix = file
        sequenceMatch = "0000"
        suffix = ""
    end

    -- pattern for string.format.
    seqPattern = "%0"..sequenceMatch:len().."d"
        
    -- add png extension
    suffix = suffix..".png"

    -- return the path to the output file
    return octane.file.getParentDirectory(path).."/"..prefix..seqPattern:format(frame)..suffix
end

-- flag indicating cancellation
IS_CANCELLED  = false
function renderCallback()
    -- check if rendering was cancelled
    if (IS_CANCELLED) then 
        octane.render.stop()
        return
    end
end

function startRender(sceneGraph, rtNode, camNode, path, saveFrames)
    -- clear the cancel flag
    IS_CANCELLED = false

    -- motion blur setting
    octane.render.setShutterTime(shutterSlider:getProperties().value)

    -- disable part of the ui except for the stop button
    degSlider       	   :updateProperties{ enable = false }
    offsetSlider    	   :updateProperties{ enable = false }
    targetSlider    	   :updateProperties{ enable = false }
    samplesSlider   	   :updateProperties{ enable = false }
    durationSlider  	   :updateProperties{ enable = false }
    frameRateSlider 	   :updateProperties{ enable = false }
    frameSlider     	   :updateProperties{ enable = false }
    fileChooseButton	   :updateProperties{ enable = false }
    spiralSlider    	   :updateProperties{ enable = false }
    shutterSlider   	   :updateProperties{ enable = false }
    renderTargetDropDown   :updateProperties{ enable = false }
    defaultLoadButton	   :updateProperties{ enable = false }
    defaultSaveButton	   :updateProperties{ enable = false }
    defaultResetButton	   :updateProperties{ enable = false }
    livePreviewButton	   :updateProperties{ enable = false }
    previewSamplesSlider   :updateProperties{ enable = false }
    stopButton      	   :updateProperties{ enable = true  }

    -- get the presets from the GUI
    local rotAngle       = degSlider:getProperties().value
    local offsetAngle    = offsetSlider:getProperties().value
    local targetDistance = targetSlider:getProperties().value
    local nbFrames       = frameSlider:getProperties().value
    local nbSamples      = samplesSlider:getProperties().value
    local outPath        = fileEditor:getProperties().text

    if saveFrames == false then
      nbSamples = previewSamplesSlider:getProperties().value
    end

    -- set up the animator for the camera
    setCamAnimator(camNode, rotAngle, offsetAngle, targetDistance, nbFrames)

    -- start rendering out each frame
    local currentTime = 0
    for frame=1,nbFrames do
        -- set the time in the scene 
        sceneGraph:updateTime(currentTime)
        
        -- update the progress bar
        progressBar:updateProperties{ text = string.format("rendering frame %d", frame) }

        -- fire up the render engine, yihaah!
        octane.render.start
        {
            renderTargetNode = rtNode,
            maxSamples       = nbSamples,
            callback         = renderCallback,
        }
        
        -- break out if we're cancelled and set it in the progress bar
        if IS_CANCELLED then 
            progressBar:updateProperties{ progress = 0, text = "cancelled" } 
            break 
        end

        -- save the current frame
        if saveFrames then
          local out = createSavePath(path, frame)
          octane.render.saveImage(out, octane.render.imageType.PNG8)
        end

        -- update the time for the next frame
        currentTime = frame * (1 / nbFrames)

        -- update the progress bar
        progressBar:updateProperties{ progress = frame / nbFrames }
    end

    -- enable part of the ui except for the stop button
    degSlider              :updateProperties{ enable = true  }
    offsetSlider           :updateProperties{ enable = true  }
    targetSlider           :updateProperties{ enable = true  }
    samplesSlider          :updateProperties{ enable = true  }
    durationSlider         :updateProperties{ enable = true  }
    frameRateSlider        :updateProperties{ enable = true  }
    frameSlider            :updateProperties{ enable = true  }
    fileChooseButton       :updateProperties{ enable = true  }
    spiralSlider           :updateProperties{ enable = true  }
    shutterSlider          :updateProperties{ enable = true  }
    renderTargetDropDown   :updateProperties{ enable = true  }
    defaultLoadButton	   :updateProperties{ enable = true  }
    defaultSaveButton	   :updateProperties{ enable = true  }
    defaultResetButton	   :updateProperties{ enable = true  }
    livePreviewButton	   :updateProperties{ enable = true  }
    previewSamplesSlider   :updateProperties{ enable = true  }
    stopButton             :updateProperties{ enable = false }

    -- update the progress bar
    progressBar:updateProperties{ progress = 0, text = "finished" }
end

function cancelRender()
    IS_CANCELLED = true
    octane.render.callbackStop()
    octane.render.clear()
end

function initGui(camNode)
    -- set the initial target distance in the distance slider
    local target   = camNode:getPinValue(octane.P_TARGET)
    local position = camNode:getPinValue(octane.P_POSITION)
    local viewDir  = octane.vec.sub(target, position)
    local tgtLen   = octane.vec.length(viewDir)
    targetSlider:updateProperties{ value = tgtLen }
end

