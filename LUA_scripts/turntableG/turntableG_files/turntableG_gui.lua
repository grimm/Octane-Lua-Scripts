-- 
-- Turntable gui script
--

-- lets create a bunch of labels and sliders
degLbl              = ui.createLabel("Degrees")
offsetLbl           = ui.createLabel("Start Angle")
targetLbl           = ui.createLabel("Target Offset")
durationLbl         = ui.createLabel("Duration")
frameRateLbl        = ui.createLabel("Framerate")
frameLbl            = ui.createLabel("Frames")
samplesLbl          = ui.createLabel("Samples/px")
spiralLbl           = ui.createLabel("Spiral In/Out")
shutterLbl          = ui.createLabel("Shutter Time")
previewSamplesLbl   = ui.createLabel("Samples/px")
cameraPathAngleLbl  = ui.createLabel("Camera Path Angle")

degSlider              = ui.createSlider("degree", 360, -360 , 360, 1, 400, 20)
degSlider:bind("value", defaultsTable, "degSlider")

offsetSlider           = ui.createSlider("offset", 0  , -180 , 180, 1, 400, 20)
offsetSlider:bind("value", defaultsTable, "offsetSlider")

targetSlider           = ui.createSlider("target", 10 , 0.001, 16000, 0.001, 400, 20)

durationSlider         = ui.createSlider("duration", 10 , 1 , 120  , 1, 400, 20)
durationSlider:bind("value", defaultsTable, "durationSlider")

frameRateSlider        = ui.createSlider("rate", 25 , 10, 120   , 1, 400, 20)
frameRateSlider:bind("value", defaultsTable, "frameRateSlider")

frameSlider            = ui.createSlider("frames", 250, 10, 14400, 1, 400, 20)
frameSlider:bind("value", defaultsTable, "frameSlider")

samplesSlider          = ui.createSlider("samples", 400, 1 , 16000, 1, 400, 20)
samplesSlider:bind("value", defaultsTable, "samplesSlider")

spiralSlider           = ui.createSlider("spiral", 0, -20 , 20, 0.01, 400, 20)
spiralSlider:bind("value", defaultsTable, "spiralSlider")

shutterSlider          = ui.createSlider("shutter", 0, 0, 1, 0.001, 400, 20)
shutterSlider:bind("value", defaultsTable, "shutterSlider")

previewSamplesSlider   = ui.createSlider("presamples", 20, 1, 400, 1, 308, 20)
previewSamplesSlider:bind("value", defaultsTable, "previewSamplesSlider")

cameraPathAngleSlider  = ui.createSlider("camerapathangle", 0, -90, 90, 1, 400, 20)
cameraPathAngleSlider:bind("value", defaultsTable, "cameraPathAngle")

-- create button for the live preview
livePreviewButton = ui.createButton("livepreview", "Run Preview", 80, 20, "Render turntable animation with out saving frames.")

-- create group for live preview
previewGrp = ui.createGroup("previewgrp", { livePreviewButton, previewSamplesLbl, previewSamplesSlider }, true, 1, 3, nil, nil, "Live Preview", { 5 }, nil, false)

-- create buttons for the defaults load and save
defaultLoadButton = ui.createButton("defaultload", "Load", 100, 20, "Load the default settings file")
defaultSaveButton = ui.createButton("defaultsave", "Save", 100, 20, "Save the current settings to the defaults file")
defaultResetButton = ui.createButton("defaultreset", "Reset", 100, 20, "Reset the settings to original values")

-- create group for defaults
defaultsGrp = ui.createGroup("defaultsgrp", { defaultLoadButton, defaultSaveButton, defaultResetButton }, true, 1, 3, nil, nil, "Defaults", { 5 }, nil, false)

-- create a button to show a file chooser
fileChooseButton = ui.createButton("output", "Output...", 80, 20, "Choose a file name for the animation")

-- create an editor that will show the chosen file path
fileEditor = octane.gui.create
{
    type    = octane.gui.componentType.TEXT_EDITOR,
    text    = "",
    x       = 20,
    width   = 400,
    height  = 20,
    enable  = false,    
}

-- manual layouting is tedious so let's add all our stuff into groups.
-- camera movement group children
camera_children = 
    {
        degLbl           , degSlider       ,
        offsetLbl        , offsetSlider    ,
        targetLbl        , targetSlider    ,
        spiralLbl        , spiralSlider    ,
        shutterLbl       , shutterSlider   ,
    }

-- render group children
render_children = 
    {
        durationLbl      , durationSlider  ,
        frameRateLbl     , frameRateSlider ,
        frameLbl         , frameSlider     ,
        samplesLbl       , samplesSlider   ,
    }

output_children =
    {
        fileChooseButton, fileEditor,
    }

camera_advanced_children = 
    {
    cameraPathAngleLbl   , cameraPathAngleSlider,
    }

cameraGrp = ui.createGroup("camera_group", camera_children,true, 5, 2, nil, nil, "Movement", { 2 }, { 5 })
cameraAdvancedGrp = ui.createGroup("camera_advanced", camera_advanced_children,true, 1, 2, nil, nil, "Movement", { 2 }, { 5 })
renderGrp = ui.createGroup("render_group", render_children,true, 4, 2, nil, nil, "Render Settings", { 2 }, { 5 })

camera_tab_children = 
    {
    cameraGrp, 
    cameraAdvancedGrp, 
    }

cameraTab = ui.createTabs( {"Camera", "Advanced"}, camera_tab_children )

-- for layouting the button and the editor we use a group
fileGrp = ui.createGroup("output_group", output_children, true, 1, 2, nil, nil, "Output", { 2 }, { 5 })

-- Target drop down
renderTargetDropDown = ui.createDrop_down("rendertarget", nil, 400, 20, nil)
renderTargetGrp = ui.createGroup("rendertargetgrp", { renderTargetDropDown }, true, 1, 1, nil, nil, "Render Target", { 5 }, nil, true)

-- progress bar 

-- eye candy, a progress bar
progressBar = octane.gui.create
{
    type   = octane.gui.componentType.PROGRESS_BAR,
    text   = "render progress",
    width  = fileGrp:getProperties().width * 0.8, -- as wide as the group above
    height = 20,
}

-- for layouting the progress bar
progressGrp = ui.createGroup("progress", { progressBar }, false, 1, 1, nil, nil, "", { 10 }, nil, true)

-- render & stop buttons

renderButton = ui.createButton("render", "Render", 80, 20, "Start the animation render")
stopButton = ui.createButton("stop", "Stop Render", 80, 20, "Stop the render")
exitButton = ui.createButton("exit", "Exit Script", 80, 20, "Stop the script")

buttonGrp = ui.createGroup("button", { renderButton, stopButton, exitButton }, false, 1, 3, nil, nil, "", { 5}, nil)

-- group that layouts the other groups
layout_children = 
    { 
        defaultsGrp,
        cameraTab,
        renderGrp,
        renderTargetGrp,
        fileGrp, 
        previewGrp,
        progressGrp,
        buttonGrp,
    }

layoutGrp = ui.createGroup("layout", layout_children, false, 8, 1, nil, nil, "", { 2 }, nil, true)

