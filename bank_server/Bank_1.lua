local serverHostname = "bank_server"
local loginProtocol = serverHostname .. "_login"

local function Hash(str)
  local h = 2166136261
  for i = 1, #str do
    h = bit32.bxor(h, str:byte(i))
    h = (h * 16777619) % 2^32
  end
  return tostring(h)
end

function LoginPokeResponse(message)
    local payload = {
                type = "login_poke_response",
                status = "ok",
                nonce = math.random(100000, 999999)
            }
    local foundUser = fs.exists("Bank/User/" .. message.username)
    if not foundUser then
        print("[WARN] LoginPokeResponse: user " .. message.username .. " not found (returning error)")
        return {type = "login_poke_response", status = "error", reason = "user not found"}
    end
    local f = fs.open("Bank/User/" .. message.username .. "/lastNonce.txt", "w+")
    f.write(payload.nonce)
    f.close()
    print("[INFO] poke response resolved with status: ok")
    return payload
end

function LoginRequestResponse(message)
    local foundUser = fs.exists("Bank/User/" .. message.username)
    if not foundUser then
        print("[WARN] LoginRequestResponse: user " .. message.username .. " not found (returning error)")
        return {status = "error", reason = "user not found"}
    end
    
    local userFile = fs.open("Bank/User/" .. message.username .. "/password.txt", "r")
    local storedHash = userFile.readLine()
    userFile.close()

    local nonceFile = fs.open("Bank/User/" .. message.username .. "/lastNonce.txt", "a")
    local lastNonce = nonceFile.readLine()
    nonceFile.delete()
    nonceFile.close()

    if Hash(lastNonce .. storedHash) == message.proof then
        return {status = "ok"}
    else
        return {status = "error", reason = "invalid credentials"}
    end
end

while true do
    local incomingID, message, protocol = rednet.receive()
    print("[INFO] Received message from ID " .. tostring(incomingID) .. "type: " .. tostring(message.type))
    if protocol == loginProtocol then
        if message.type == "login_poke" then
            local answer = LoginPokeResponse(message)
            rednet.send(incomingID, answer, loginProtocol)
            print("[INFO] Sent login poke response to ID " .. tostring(incomingID))


        elseif message.type == "login_request" then
            local answer = LoginRequestResponse(message)
            rednet.send(incomingID, answer, loginProtocol)
            print("[INFO] Sent login request response to ID " .. tostring(incomingID))
        else
            print("[WARN] Unknown message type received: " .. tostring(message.type))
        end
    end
end