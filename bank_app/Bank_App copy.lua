--checks for basalt, installs if not found
if not fs.exists("basalt") then
  shell.run("wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -f")
end

local basalt = require("basalt")

-- Centralized theme definitions
local themes = {
  dark = {
    bg = colors.black,
    box = colors.gray,
    input = colors.lightGray,
    text = colors.white,
    palette = {
      gray = {0.106, 0.106, 0.122}, -- #1b1b1f
      lightGray = {0.25, 0.25, 0.25}
    }
  },
  light = {
    palette = {
      gray = {0.8, 0.8, 0.8},
      lightGray = {0.95, 0.95, 0.95}
    },
    
    bg = colors.lightGray,   -- page background (very light)
    box = colors.white,      -- box sits on top of bg
    input = colors.lightGray, -- inputs slightly darker than box
    text = colors.lightGray -- subtle text in light mode
  }
}

-- Theme state
local isDarkMode = true
local current = themes.dark

-- Main Frame
local main = basalt.getMainFrame()

--Log.setEnabled()
--Log.setLogToFile()

-- Get screen dimensions
local screenWidth, screenHeight = term.getSize()

-- Function to apply theme
local function applyTheme()
  current = isDarkMode and themes.dark or themes.light

  -- set global background and palettes
  main:setBackground(current.bg)
  local g = current.palette.gray
  term.setPaletteColor(colors.gray, g[1], g[2], g[3])
  local lg = current.palette.lightGray
  term.setPaletteColor(colors.lightGray, lg[1], lg[2], lg[3])

  -- Update UI element colors (only if they exist)
  if loginBox then loginBox:setBackground(current.box) end
  if title then title:setBackground(current.box):setForeground(current.text) end
  if usernameInput then usernameInput:setBackground(current.input):setForeground(current.text) end
  if passwordInput then passwordInput:setBackground(current.input):setForeground(current.text) end
  if loginButton then loginButton:setBackground(current.input):setForeground(current.text) end
  if themeBtn then themeBtn:setBackground(current.box):setForeground(current.text) end
end

-- Box dimensions
local boxWidth = 30
local boxHeight = 12
local boxX = math.floor((screenWidth - boxWidth) / 2) + 1
local boxY = math.floor((screenHeight - boxHeight) / 2) + 1

-- Create a frame for the box
local loginBox = main:addFrame()
  :setPosition(boxX, boxY)
  :setSize(boxWidth, boxHeight)
  :setBackground(current.box)

-- Dark/Light mode switch (top-right)
themeBtn = main:addButton()
  :setText(isDarkMode and "☾" or "☀")
  :setPosition(screenWidth - 3, 1)
  :setSize(3, 1)
  :setBackground(current.box)
  :setForeground(current.text)
  :onClick(function(self)
    isDarkMode = not isDarkMode
    self:setText(isDarkMode and "☾" or "☀")
    applyTheme()
  end)

-- Title (big font)
local title = loginBox:addBigFont()
  :setText("LOGIN")
  :setPosition(3, 1)
  :setBackground(current.box)
  :setForeground(current.text)

-- Username input
local usernameInput = loginBox:addInput()
  :setPosition(2, 4)
  :setSize(26, 1)
  :setPlaceholder("Username...")
  :setBackground(current.input)
  :setForeground(current.text)

-- Password input
local passwordInput = loginBox:addInput()
  :setPosition(2, 6)
  :setSize(26, 1)
  :setPlaceholder("Password...")
  :setReplaceChar("*")  -- Hides password
  :setBackground(current.input)
  :setForeground(current.text)

-- Login button
local loginButton = loginBox:addButton()
  :setText("LOGIN")
  :setPosition(12, 7)
  :setSize(8, 1)
  :setBackground(current.input)
  :setForeground(current.text)
  :onClick(function(self)
    local username = usernameInput:getValue()
    local password = passwordInput:getValue()
    print("Username: " .. username)
    print("Password: " .. password)
  end)

-- Apply initial theme
applyTheme()

basalt.run()