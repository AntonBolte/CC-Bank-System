print("startup...")
mainPath = "Bank"
configName = "testconfig.txt"
configUrl = "https://raw.githubusercontent.com/AntonBolte/CC-Bank-System/refs/heads/main/config.txt"

-- Function to download a file from a URL and save it to a specified path
function download(url, filePath)
  local content = http.get(url).readAll()
  if not content then
    error("[ERROR] could not connect to website!")
  end
  file = fs.open(filePath, "w")
  file.write(content)
  file.close()
end

-- Function to write (save) a table to a file in JSON-like format
function saveData(filename, data)
    local file = fs.open(filename, "w")  -- Open file for writing
    if file then
        file.write(textutils.serialize(data))  -- Serialize table to string and write
        file.close()
        print("Data saved to " .. filename)
    else
        print("Error: Could not open file for writing")
    end
end

-- Function to read (load) a table from a file in JSON-like format
function loadData(filename)
    local file = fs.open(filename, "r")  -- Open file for reading
    if file then
        local content = file.readAll()  -- Read entire file
        file.close()
        local data = textutils.unserialize(content)  -- Deserialize string to table
        if data then
            print("Data loaded from " .. filename)
            return data
        else
            print("Error: Could not deserialize data")
            return nil
        end
    else
        print("Error: Could not open file for reading")
        return nil
    end
end

if fs.exists(mainPath) == false
    then print("[WARN] directory '" .. mainPath .. "' could not me found in Root!")
         fs.makeDir("Bank")
         print("[INFO] directory '" .. mainPath .. "' was created")
    else print("[INFO] directory '" .. mainPath .. "' exists already")
    end

if fs.exists(mainPath .. "/" .. configName) == false
    then print("[WARN] config file could not be found at:\n'" .. mainPath .. "/" .. configName .. "' !")
         download(configUrl , mainPath .. "/" .. configName)
         print("[INFO] file '" .. mainPath .. "/" .. configName .. "' was created")
    else print("[INFO] file '" .. mainPath .. "/" .. configName .. "' exists already")
    end

saveData("test.txt", {name="Anton", age=21, balance=1500})