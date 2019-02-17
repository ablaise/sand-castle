local Object = require('core/object')

local Stage = {}
Object:instantiate(Stage)

function Stage:new(game)
  self.game = game
  self.done = false
  self.step = 0
  self.checkpoint = 0
  self.animation  = {}
  self.entities   = {}
end

function Stage:cursor()
  if not self.game.inventory:isDragging() then
    if self:isTouchingEntity() and self:mouseVisibleEntity() then
      love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    else
      love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
    end
  end
end

function Stage:enter()
  if self.animation ~= nil then
    for key in pairs(self.animation) do
      self.animation[key]:reset()
    end
  end
  
  self.step = self.checkpoint
end

function Stage:leaving(fade)
  love.graphics.push("all")
  love.graphics.setColor(0, 0, 0, fade)
  love.graphics.rectangle("fill", 0, 0, 600, 400)
  love.graphics.pop("all")
end

function Stage:removeEntity(id)
  for i=1,#self.entities do
    if self.entities[i].id == id then
      table.remove(self.entities, i)
      return true
    end
  end

  return false
end

function Stage:setMouseVisibleEntity(id, value)
  for i=1,#self.entities do
    if self.entities[i].id == id then
      self.entities[i].mousevisible = value
      return true
    end
  end

  return false
end

function Stage:isTouchingEntity()
  for i=1,#self.entities do
    if self:isTouching(self.entities[i]) then
      return true
    end
  end

  return false
end

function Stage:isTouchingEntityById(id)
  for i=1,#self.entities do
    if self.entities[i].id == id and self:isTouching(self.entities[i]) then
      return true
    end
  end

  return false
end

function Stage:mouseVisibleEntity()
  for i=1,#self.entities do
    if self:isTouching(self.entities[i]) then
      return self.entities[i].mousevisible
    end
  end

  return false
end

function Stage:isTouching(area)
  return love.mouse.getX() >= area.x 
     and love.mouse.getX() <= (area.x + area.width)
     and love.mouse.getY() >= area.y
     and love.mouse.getY() <= (area.y + area.height)
end

function Stage:draw()
end

function Stage:mousepressed(x, y, button)
end

function Stage:mousereleased(x, y, button)
end

function Stage:getGUI()
  return self.gui
end

function Stage:setDone(value)
  self.done = value
end

function Stage:isDone()
  return self.done
end

return Stage