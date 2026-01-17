-- Bank_1.lua

function GetFileData(path)
    find = find(path)
    if find == "" then
        return "File not found"
    end

    print("Getting data from " .. path)
    local f = fs.open(path, "r")
    local data = textutils.unserialize(f.readAll())
    f.close()
    return data
end

function WriteFileData(path, data)
    print("Writing data to " .. path)
    local f = fs.open(path, "w")
    f.write(textutils.serialize(data))
    f.close()
end

function Add(name, amount)
    local data = GetFileData("Bank/Accounts/" .. name .. ".txt")
    if data == "File not found" then
        return "Account does not exist"
    end
    data.Balance = data.Balance + tonumber(amount)
    WriteFileData("Bank/Accounts/" .. name .. ".txt", data.Balance)
end

print("Enter command (e.g., 'add Alice 100'):")
local input = io.read():match("^%s*(.-)%s*$")
local action, name, amount = string.match(input, "(%a+)%s+(%a+)%s+(%d+)")

print("Action: " .. action)
print("Account Name: " .. name)
print("Amount: " .. amount)

if action == "add" then
    local result = Add(name, amount)
    if result then
        print(result)
    else
        print("Added " .. amount .. " to " .. name .. "'s account.")
    end
else
    print("Unknown action: " .. action)
end
