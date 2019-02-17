local Font = require('core/ui/font')

local Button = {}
Button.__index = Button

setmetatable(Button, {
  __index = Font,
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    Font:new(...)
    self:new(...)
    return self
  end,
})

function Button:new(...)
  self.interactive = true
  self.oldHover = false
  
  self.sound = {}
  self.sound.hover = love.audio.newSource("assets/audio/hover.wav", "static")
  self.sound.click = love.audio.newSource("assets/audio/click.wav", "static")
  self.sound.hover:setVolume(0.5)
  self.sound.click:setVolume(0.5)
end

function Button:click()
  if self:isHover() then
    self.sound.click:play()
    return true
  end
  
  return false
end

function Button:hoverEvent()
  
  if love.mouse.getCursor() == love.mouse.getSystemCursor("arrow") and not self.oldHover then
    love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
  end
  
  if not self.oldHover then
    self.sound.hover:play()
    self.oldHover = true
  end
  
end

function Button:endHoverEvent()
  
  if love.mouse.getCursor() == love.mouse.getSystemCursor("hand") and self.oldHover then
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
  end
  
  self.oldHover = false
  
end

return Button