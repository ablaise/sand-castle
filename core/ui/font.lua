local Font = {}
Font.__index = Font

setmetatable(Font, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:new(...)
    return self
  end,
})

function Font:new(font, size, border, height, width, prop)
  love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
  self.interactive = false
  self.disabled = false
  self.font = font
  self.font:setFilter("nearest", "nearest")
  love.graphics.setFont(self.font)
  
  self.border = border
  self.height = height
  self.width = width
  self.text = ""
  self.x = 0
  self.y = 0
  
  -- blanc par défaut
  self.color = {}
  self.color.red = 1
  self.color.green = 1
  self.color.blue = 1
  self.color.alpha = 1
end

function Font:disabled(value)
  self.disable = value
end

function Font:draw(text, x, y, opacity)
  if text ~= "" then
    self.text = text
    self.x = x
    self.y = y
    
    -- création de la bordure noire et du texte
    love.graphics.push("all")
      self:drawBorder(opacity)
      self:print(opacity)
    love.graphics.pop("all")
  end
end

function Font:drawBorder(opacity)
  love.graphics.setColor(0, 0, 0, opacity)
  for i=1,self.border do
    love.graphics.print(self.text, self.x - i, self.y)
    love.graphics.print(self.text, self.x + i, self.y)
    love.graphics.print(self.text, self.x, self.y - i)
    love.graphics.print(self.text, self.x, self.y + i)
    -- diagonales
    love.graphics.print(self.text, self.x + i, self.y + i)
    love.graphics.print(self.text, self.x - i, self.y - i)
    love.graphics.print(self.text, self.x + i, self.y - i)
    love.graphics.print(self.text, self.x - i, self.y + i)
  end
end

function Font:disable(value)
  self.disabled = value
end

function Font:print(opacity)
  if not self.disabled then
    if self:isHover() and self.interactive then
      love.graphics.setColor(0.96, 0.72, 0.51, opacity)
      
      -- trigger on event
      self:hoverEvent()
    else
      love.graphics.setColor(self.color.red, self.color.green, self.color.blue, opacity)
      
      -- trigger off event
      self:endHoverEvent()
    end
  else
    love.graphics.setColor(self.color.red, self.color.green, self.color.blue, opacity)
  end

  love.graphics.print(self.text, self.x, self.y)
end

function Font:isHover()
  return love.mouse.getX() >= self.x and love.mouse.getX() <= (self.x + self:getTextWidth()) and love.mouse.getY() >= self.y and love.mouse.getY() <= (self.y + self:getTextHeight())
end

function Font:drawLines(lines, x, y)
  for i=1,#lines do
    self:draw(lines[i], x, y + (i-1)*self.font:getHeight())
  end
end

function Font:hoverEvent()
end

function Font:endHoverEvent()
end

function Font:setColor(red, green, blue, alpha)
  self.color.red = red
  self.color.green = green
  self.color.blue = blue
  self.color.alpha = alpha
end

function Font:getTextWidth()
  return self.font:getWidth(self.text)
end

function Font:getTextHeight()
  return self.font:getHeight(self.text)
end

function Font:getHeight()
  return self.height
end

function Font:getWidth()
  return self.width
end

return Font