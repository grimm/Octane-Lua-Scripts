-- Grimms helper functions
--

--[[
   Save Table to File
   Load Table from File
   v 1.0
   
   Lua 5.2 compatible
   
   Only Saves Tables, Numbers and Strings
   Insides Table References are saved
   Does not save Userdata, Metatables, Functions and indices of these
   ----------------------------------------------------
   table.save( table , filename )
   
   on failure: returns an error msg
   
   ----------------------------------------------------
   table.load( filename or stringtable )
   
   Loads a table that has been saved via the table.save function
   
   on success: returns a previously saved table
   on failure: returns as second argument an error msg
   ----------------------------------------------------
   
   Licensed under the same terms as Lua itself.
]]--

--// exportstring( string )
--// returns a "Lua" portable version of the string
function exportstring( s )
   return string.format("%q", s)
end

--Save a table
function saveTable(table, filename)
    local charS,charE = "   ","\n"
    local file,err = io.open( filename, "wb" )
    if err then return err end

    -- initiate variables for save procedure
    local tables,lookup = { table },{ [table] = 1 }
    file:write( "return {"..charE )

    for idx,t in ipairs( tables ) do
       file:write( "-- Table: {"..idx.."}"..charE )
       file:write( "{"..charE )
       local thandled = {}

       for i,v in ipairs( t ) do
          thandled[i] = true
          local stype = type( v )
          -- only handle value
          if stype == "table" then
             if not lookup[v] then
                table.insert( tables, v )
                lookup[v] = #tables
             end
             file:write( charS.."{"..lookup[v].."},"..charE )
          elseif stype == "string" then
             file:write(  charS..exportstring( v )..","..charE )
          elseif stype == "number" then
             file:write(  charS..tostring( v )..","..charE )
          end
       end

       for i,v in pairs( t ) do
          -- escape handled values
          if (not thandled[i]) then
          
             local str = ""
             local stype = type( i )
             -- handle index
             if stype == "table" then
                if not lookup[i] then
                   table.insert( tables,i )
                   lookup[i] = #tables
                end
                str = charS.."[{"..lookup[i].."}]="
             elseif stype == "string" then
                str = charS.."["..exportstring( i ).."]="
             elseif stype == "number" then
                str = charS.."["..tostring( i ).."]="
             end
          
             if str ~= "" then
                stype = type( v )
                -- handle value
                if stype == "table" then
                   if not lookup[v] then
                      table.insert( tables,v )
                      lookup[v] = #tables
                   end
                   file:write( str.."{"..lookup[v].."},"..charE )
                elseif stype == "string" then
                   file:write( str..exportstring( v )..","..charE )
                elseif stype == "number" then
                   file:write( str..tostring( v )..","..charE )
                end
             end
          end
       end
       file:write( "},"..charE )
    end
    file:write( "}" )
    file:close()
end

--Load a table
function loadTable(filename)
    local ftables,err = loadfile( filename )
    if err then return _,err end
    local tables = ftables()

    for idx = 1,#tables do
       local tolinki = {}
       for i,v in pairs( tables[idx] ) do
          if type( v ) == "table" then
             tables[idx][i] = tables[v[1]]
          end
          if type( i ) == "table" and tables[i[1]] then
             table.insert( tolinki,{ i,tables[i[1]] } )
          end
       end
       -- link indices
       for _,v in ipairs( tolinki ) do
          tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
       end
    end
    return tables[1]
end

-- helper to pop-up an error dialog and optionally halts the script
function showError(title, text, halt)
    octane.gui.showDialog
    {
        type  = octane.gui.dialogType.BUTTON_DIALOG,
        icon  = octane.gui.dialogIcon.WARNING,
        title = title,
        text  = text,
    }
    if halt then error("ERROR: "..text) end
end

-- helper to pop-up an information dialog
function showInfo(title, text)
    octane.gui.showDialog
    {
        type  = octane.gui.dialogType.BUTTON_DIALOG,
        icon  = octane.gui.dialogIcon.INFO,
        title = title,
        text  = text,
    }
end