print("startup...")
mainPath = "Bank"
configName = "config.txt"


if fs.exists(mainPath) == false
    then print("[WARN] directory '" .. mainPath .. "' could not me found in Root!")
         fs.makeDir("Bank")
         print("[INFO] directory '" .. mainPath .. "' was created")
    else print("[INFO] directory '" .. mainPath .. "' exists already")
    end

if fs.exists(mainPath .. "/" .. configName) == false
    then print("[WARN] config file could not be found at:\n'" .. mainPath .. "/" .. configName .. "' !")
         local file = fs.open(mainPath .. "/" .. configName , "w")
            file.write("This is a Test")
            file.close()
         print("[INFO] file '" .. mainPath .. "/" .. configName .. "' was created")
    else print("[INFO] file '" .. mainPath .. "/" .. configName .. "' exists already")
    end

    