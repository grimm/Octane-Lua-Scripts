----------------------------------------------------------------------------------------------------
-- Sets up a scripted graph with an animated texture. The images for the texture animation are
-- loaded from the file name given.
--
-- @author  Jason Grimes
-- @version 0.1

local AnimTexture = {}
local frameTime = 0 -- Amount of time for each frame

function getFrame(currentTime)
	local halfFrame = frameTime/2 -- Force fix rounding errors
	return math.floor((currentTime + halfFrame)/frameTime)
end

function AnimTexture.onInit(self, graph)
  local inputInfos = {
     {type=octane.PT_STRING, label="File Name", defaultNodeType=octane.NT_FILE},
 		 {type=octane.PT_INT, label="Number of Digits", defaultNodeType=octane.NT_INT, defaultValue=4}
  }
			
	local outputInfos = {
    {type=octane.PT_TEXTURE, label="Animated Texture"}
  }
			
	local prs = octane.project.getProjectSettings()
	local sceneFps = prs:getAttribute(octane.A_FRAMES_PER_SECOND)
	frameTime = 1.0/sceneFps
	
	inputs = graph:setInputLinkers(inputInfos)
  outputs = graph:setOutputLinkers(outputInfos)
	self:setEvaluateTimeChanges(true)
	
  tex = octane.node.create{ type=octane.NT_TEX_IMAGE, name="Anim Texture", graphOwner=graph }
  outputs[1]:connectTo("input", tex)
end

function AnimTexture.onEvaluate(self, graph)
	local frameNum = getFrame(graph.time)
	-- local prs = octane.project.getProjectSettings()
	-- local sceneFps = prs:getAttribute(octane.A_FRAMES_PER_SECOND)
	local sceneFps = graph:getProperties().graphOwned:getAttribute(octane.A_FRAMES_PER_SECOND)
	frameTime = 1.0/sceneFps
	
  if self:timeWasChanged() then
  	fileName = self:getInputValue(inputs[1])
	  numDigits = self:getInputValue(inputs[2])
	
  	parentPath = octane.file.getParentDirectory(fileName)
  	baseFile = octane.file.getFileNameWithoutExtension(fileName)
	  fileExt = octane.file.getFileExtension(fileName)
  	cleanFile = string.sub(baseFile, 1, baseFile:len() - numDigits)
		numFormat = "%0"..numDigits.."u"
		finalFile = octane.file.join(parentPath, cleanFile..string.format(numFormat, frameNum)..fileExt)
		
		tex:setAttribute(octane.A_FILENAME, finalFile)
		tex:setAttribute(octane.A_RELOAD, true)
	end
	
  return true
end

return AnimTexture