--checks for basalt, installs if not found
if not fs.exists("basalt.lua") then
  shell.run("wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -f")
end
local basalt = require("basalt")

--definitions (these need to be the same as in the server)
local bankHostname = "bank_server"
local loginProtocol = bankHostname .. "_login"

local function Hash(str)
  local h = 2166136261
  for i = 1, #str do
    h = bit32.bxor(h, str:byte(i))
    h = (h * 16777619) % 2^32
  end
  return tostring(h)
end


function RednetConnect()
    if rednet.isOpen() then
        return
    end

    local modemOpen = false
    local modemSide = peripheral.getNames("modem")[1]
    print("opening modem on side: " .. modemSide)
    if modemSide then
        rednet.open(modemSide)
        modemOpen = true
        return "info: rednet opend"
    else
        return "error: no modem found"
    end
end

function DiscoverServer()
    local serverID = rednet.lookup(loginProtocol, bankHostname)
    if serverID then
        return serverID
    else
        return "error: no server found"
    end
end

function LoginPoke(username)
    local rConnectResponse = RednetConnect()
    if string.match(rConnectResponse, "error") then
        return "error: error returned by function RednetConnect (" .. rConnectResponse .. ")"
    end

    local serverID = DiscoverServer()
    if string.match(serverID, "error") then
        return serverID
    end
    rednet.send(serverID, {type = "login_poke", username = username}, loginProtocol)

    local incomingID, message, protocol = rednet.receive(loginProtocol, 5)
    if not incomingID  == serverID then
        return "error: wrong id responded"
    end

    if not message.status == "ok" then
        return "error: server returned error status:" .. tostring(message.status)
    end

    return message
end

function LoginRequest(username, password)
    local pokeAnswer = LoginPoke(username)
    if string.match(pokeAnswer, "error") then
        return "error: error returned by function LoginPoke (" .. pokeAnswer .. ")"
    end

    local serverID = DiscoverServer()
    if string.match(serverID, "error") then
        return "error: error returned by function DiscoverServer (" .. serverID .. ")"
    end

    --expects pokeAnswer to contain a nonce field
    local payload = {
        type = "login_request",
        username = username,
        proof = Hash(pokeAnswer.nonce .. Hash(password))
    }

    rednet.send(serverID, payload, loginProtocol)

    local incomingID, message, protocol = rednet.receive(loginProtocol, 5)
    if not incomingID  == serverID then
        return "error: wrong id responded"
    end

    return message
end


RednetConnect()



local screenWidth, screenHeight = term.getSize()

local main = basalt.getMainFrame()

local loginFrame = main:addFrame({
    width = screenWidth,
    height = screenHeight,
    background = colors.black
})

local loginBox = loginFrame:addFrame({
    width = 26 +1,
    height = screenHeight +1,
    background = colors.gray
}):center()

local usernameInput = loginBox:addInput({
    width = 16,
    x = 5,                             
    y = 5,
    background = colors.lightGray,
    foreground = colors.white,
    placeholder = "Username",
    placeholderColor = colors.white
})
usernameInput:onChange(function(self, pword)
    print(pword)
    local username = value
end)

local passwordInput = loginBox:addInput({
    width = 16,
    x = 5,                             
    y = 10,
    background = colors.lightGray,
    foreground = colors.white,
    placeholder = "Password",
    placeholderColor = colors.white,
    replaceChar = "*"
})
passwordInput:onChange(function(self, uname)
    local password = uname
end)

local loginButton = loginBox:addButton({
    width = 12,
    x = 8,
    y = 15,
    background = colors.purple,
    foreground = colors.white,
    text = "Login",
})

loginButton:onClick(function(self)
        if not password or username then
            self:setBackground(colors.red)
            self:setText("Fill all fields")
            sleep(2)
            self:setBackground(colors.purple)
            self:setText("Login")
            return
        end

        self:setBackground(colors.lightGray)
        self:setText("Logging in...")

        local loginResponse = LoginRequest(username, password)
        if string.match(loginResponse, "error") then
            self:setBackground(colors.red)
            self:setText("Login Failed")
            sleep(2)
            self:setBackground(colors.purple)
            self:setText("Login")
        else
            if loginResponse.status == "ok" then
                self:setBackground(colors.green)
                self:setText("Login Successful")
                --proceed to next part of the app
            else
                self:setBackground(colors.red)
                self:setText("Login Failed")
                sleep(2)
                self:setBackground(colors.purple)
                self:setText("Login")
            end
        end
    end)

basalt.run()