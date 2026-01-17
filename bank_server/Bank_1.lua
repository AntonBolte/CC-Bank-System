-- Bank_1.lua

function GetFileData(path)
    local f = fs.open(path, "r")
    if not f then
        return nil
    end
    print("Getting data from " .. path)
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

local commands = {
    add = function(name, amount)
        local data = GetFileData("Bank/Accounts/" .. name .. ".txt")
        if not data then
            return "Account does not exist"
        end
        data.Balance = data.Balance + tonumber(amount)
        WriteFileData("Bank/Accounts/" .. name .. ".txt", data)
        return "Added " .. amount .. " to " .. name .. "'s account."
    end,
    
    create = function(name)
        local data = { Name = name, Balance = 0 }
        WriteFileData("Bank/Accounts/" .. name .. ".txt", data)
        return "Created account for " .. name
    end,
    
    balance = function(name)
        local data = GetFileData("Bank/Accounts/" .. name .. ".txt")
        if not data then
            return "Account does not exist"
        end
        return name .. "'s balance: " .. data.Balance
    end,
    
    remove = function(name, amount)
        local data = GetFileData("Bank/Accounts/" .. name .. ".txt")
        if not data then
            return "Account does not exist"
        end
        if data.Balance < tonumber(amount) then
            return "Insufficient funds"
        end
        data.Balance = data.Balance - tonumber(amount)
        WriteFileData("Bank/Accounts/" .. name .. ".txt", data)
        return "Withdrew " .. amount .. " from " .. name .. "'s account."
    end
}

print("Enter command (e.g., 'add Alice 100', 'create Bob', 'balance Alice'):")
local input = io.read():match("^%s*(.-)%s*$")
local action, name, amount = string.match(input, "(%a+)%s+(%a+)%s*(%-?%d*)")

if commands[action] then
    local result = commands[action](name, amount ~= "" and amount or nil)
    print(result)
else
    print("Unknown action: " .. action)
end