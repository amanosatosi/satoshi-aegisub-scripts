script_name = "Actor Double Border Styler"
script_description = "Apply double outline styles per actor from external style file"
script_author = "deepseek and satoshi"
script_version = "1.10"

-- Corrected file name to match your file
local STYLE_FILENAME = "actor-style.txt"

-- Check if a file exists
local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Read file contents
local function read_file(path)
    local f = io.open(path, "r")
    if not f then 
        aegisub.log(1, "Failed to open file: " .. path .. "\n")
        return nil 
    end
    local content = f:read("*a")
    f:close()
    return content
end

-- Parse style data from multiline string into table
local function parse_styles(data)
    local styles = {}
    for line in data:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "") -- trim spaces
        if line ~= "" and not line:match("^#") then
            local actor, c1, c3_1, c3_2, bord1, bord2 = line:match("^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)$")
            if actor and c1 and c3_1 and c3_2 and bord1 and bord2 then
                styles[actor] = {
                    c1 = c1,
                    c3_1 = c3_1,
                    c3_2 = c3_2,
                    bord1 = tonumber(bord1),
                    bord2 = tonumber(bord2)
                }
            else
                aegisub.log(1, "Skipping invalid line: " .. line .. "\n")
            end
        end
    end
    return styles
end

-- Insert override tags or append new tag block
local function add_tags(text, tags)
    local prefix, rest = text:match("^{([^}]*)}(.*)")
    if prefix then
        prefix = prefix
            :gsub("\\c&H[0-9A-Fa-f]+&", "")
            :gsub("\\3c&H[0-9A-Fa-f]+&", "")
            :gsub("\\bord[%d%.]+", "")
            :gsub("\\shad[%d%.]+", "")
        prefix = prefix .. tags
        return "{" .. prefix .. "}" .. rest
    else
        return "{" .. tags .. "}" .. text
    end
end

-- Get video folder path
local function get_video_folder()
    local video_file = aegisub.project_properties().video_file
    if not video_file or video_file == "" then 
        aegisub.log(1, "No video file loaded\n")
        return nil 
    end
    
    aegisub.log(1, "Video file from properties: " .. video_file .. "\n")
    
    local decoded_path = aegisub.decode_path(video_file)
    aegisub.log(1, "Decoded video path: " .. decoded_path .. "\n")
    
    local folder = decoded_path:match("^(.*)[\\/]")
    if folder then
        aegisub.log(1, "Video folder: " .. folder .. "\n")
        return folder
    else
        aegisub.log(1, "Failed to extract folder from video path: " .. decoded_path .. "\n")
        return nil
    end
end

-- Function to create a copy of a subtitle line
local function copy_line(line)
    local new_line = {}
    for k, v in pairs(line) do
        new_line[k] = v
    end
    return new_line
end

-- Load style file from video folder if it exists
local function load_style_file()
    local folder = get_video_folder()
    if not folder then
        aegisub.log(1, "No video folder found\n")
        return ""
    end
    
    -- Use correct path separator for Windows
    local style_path = folder .. "\\" .. STYLE_FILENAME
    aegisub.log(1, "Style file path: " .. style_path .. "\n")
    
    -- Verify file existence with better logging
    if not file_exists(style_path) then
        aegisub.log(1, "Style file not found at: " .. style_path .. "\n")
        -- Try alternative path formats
        local alt_path = folder .. "/" .. STYLE_FILENAME
        if file_exists(alt_path) then
            aegisub.log(1, "Found file with alternative path separator: " .. alt_path .. "\n")
            style_path = alt_path
        else
            aegisub.log(1, "File not found with any path format\n")
            return ""
        end
    end
    
    aegisub.log(1, "Style file exists, reading content...\n")
    local content = read_file(style_path)
    if content then
        aegisub.log(1, "Successfully loaded style file (length: " .. #content .. " bytes\n")
        return content
    else
        aegisub.log(1, "Failed to read style file\n")
        return ""
    end
end

-- Show help guide
local function show_help()
    local help_text = [[
HOW TO USE ACTOR DOUBLE BORDER STYLER

1. Place a file named 'actor-style.txt' in the same folder as your video file
   (NOTE: Must be EXACTLY 'actor-style.txt' - not 'actor-styles.txt' or other variations)

2. Format each line like:
   ActorName,PrimaryColor,OutlineColor1,OutlineColor2,BorderSize1,BorderSize2
   
Example:
   Erika,&HFFFFFF&,&HACBEF7&,&HFFFFFF&,5,9
   Hiro,&HFFFFFF&,&H9A5A8B&,&HFFFFFF&,5,9

Color Format: &HBBGGRR (same as color codes from Aegisub)
- PrimaryColor: Main text color
- OutlineColor1: Inner outline color
- OutlineColor2: Outer outline color

3. Make sure your video is loaded in Aegisub
4. Run this automation script

The script will:
- Find actor-style.txt in your video folder
- Apply double borders to all dialogue lines
- Create two layers for each line (inner and outer border)

]]

    -- Help dialog with copyable filename
    aegisub.dialog.display({
        {class="label", label=help_text, x=0, y=0, width=60, height=15},
        {class="label", label="Copy this filename:", x=0, y=15, width=1, height=1},
        {class="edit", name="filename", text="actor-style.txt", x=1, y=15, width=3, height=1, readonly=true}
    }, {"OK"})
end

-- Main processing function
local function process(subs, sel)
    aegisub.log(1, "\n--- Starting Actor Double Border Styler v1.10 ---\n")
    
    -- Load style file content automatically
    local content = load_style_file()
    
    local pressed, res
    while true do
        -- TEXT BOX DEFINITION WITH HEIGHT REDUCED TO 8
        local GUI = {
            {class="label", 
             label="Edit actor styles (format: Actor,PrimaryColor,OutlineColor1,OutlineColor2,BorderSize1,BorderSize2):", 
             x=0, y=0, width=4, height=1},
             
            {class="textbox", 
             name="styles", 
             text=content, 
             x=0, y=1, 
             width=4,  -- Width remains at 4 units
             height=8}, -- Height reduced to 8 lines
        }
        
        pressed, res = aegisub.dialog.display(GUI, {"Apply", "Help", "Cancel"})
        
        if pressed == "Help" then
            show_help()
        elseif pressed == "Apply" then
            content = res.styles  -- Use edited content
            break
        else -- Cancel or close
            aegisub.log(1, "Operation canceled by user\n")
            return
        end
    end
    
    -- Parse styles
    aegisub.log(1, "Parsing styles...\n")
    local styles = parse_styles(content)
    if not styles or next(styles) == nil then
        aegisub.log(1, "No valid actor styles found in content\n")
        aegisub.dialog.display({{class="label",label="No valid actor styles found!",x=0,y=0,width=2,height=1}}, {"OK"})
        return
    end
    
    aegisub.log(1, "Found styles for " .. table.maxn(styles) .. " actors\n")
    
    local clones = {}
    local processed = 0
    
    -- Iterate all lines (backwards to avoid indexing issues)
    aegisub.log(1, "Processing subtitle lines...\n")
    for i = #subs, 1, -1 do
        local line = subs[i]
        if line.class == "dialogue" and line.actor ~= "" then
            local s = styles[line.actor]
            if s then
                -- Create copy for second border (layer 1)
                local clone = copy_line(line)
                clone.layer = 1
                clone.text = add_tags(line.text, string.format("\\c%s\\3c%s\\bord%.1f\\shad0", s.c3_2, s.c3_2, s.bord2))
                table.insert(clones, clone)
                
                -- Modify original line (layer 2)
                line.layer = 2
                line.text = add_tags(line.text, string.format("\\c%s\\3c%s\\bord%.1f\\shad0", s.c1, s.c3_1, s.bord1))
                
                subs[i] = line
                processed = processed + 1
            end
        end
    end
    
    aegisub.log(1, "Processed " .. processed .. " dialogue lines\n")
    
    -- Insert all clones at the beginning
    aegisub.log(1, "Inserting " .. #clones .. " clone lines\n")
    for i = #clones, 1, -1 do
        subs.insert(1, clones[i])
    end
    
    aegisub.log(1, "Completed successfully!\n")
    aegisub.set_undo_point(script_name)
    
    -- Show completion message
    aegisub.dialog.display({
        {class="label", label=string.format("Success! Applied styles to %d lines", processed), x=0,y=0,width=2,height=1}
    }, {"OK"})
end

aegisub.register_macro(script_name, script_description, process)
