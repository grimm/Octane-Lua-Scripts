-- Calculation functions for StudioG

-- calculate the statistics of a mesh and return a table of those values
function getMeshStats(verts)
  local meshStats = {}
  local minX = 0
  local maxX = 0
  local minY = 0
  local maxY = 0
  local minZ = 0
  local maxZ = 0
  local x, y, z

  -- find the bounding box
  for k,v in pairs(verts) do
    x = v[1]
    if x > maxX then maxX = x end
    if x < minX then minX = x end
    y = v[2]
    if y > maxY then maxY = y end
    if y < minY then minY = y end
    z = v[3]
    if z > maxZ then maxZ = z end
    if z < minZ then minZ = z end
  end

  meshStats["min_x"] = minX
  meshStats["max_x"] = maxX
  meshStats["min_y"] = minY
  meshStats["max_y"] = maxY
  meshStats["min_z"] = minZ
  meshStats["max_z"] = maxZ

  -- find the mesh's length for each axis
  local lengthX = maxX - minX
  local lengthY = maxY - minY
  local lengthZ = maxZ - minZ

  meshStats["x_len"] = lengthX
  meshStats["y_len"] = lengthY
  meshStats["z_len"] = lengthZ

  -- find the mesh's position
  local posX = lengthX/2.0 + minX
  local posY = lengthY/2.0 + minY
  local posZ = lengthZ/2.0 + minZ

  meshStats["pos_x"] = posX
  meshStats["pos_y"] = posY
  meshStats["pos_z"] = posZ

  return meshStats
end

