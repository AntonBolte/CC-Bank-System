print("startup...")
mainPath = "Bank"
configName = "testconfig.txt"
configUrl = "https://raw.githubusercontent.com/AntonBolte/CC-Bank-System/refs/heads/main/config.txt"

function download(url, filePath)
  local content = http.get(url).readAll()
  if not content then
    error("[ERROR] could not connect to website!")
  end
  file = fs.open(filePath, "w")
  file.write(content)
  file.close()
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
