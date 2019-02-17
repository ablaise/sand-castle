local Object = require('core/object')
local Stage  = require('core/stage')

local Entry = {}
Object:instantiate(Entry, Stage)

function Entry:new(game)
  self.game = game

  self.lightning = {}
  for i=0,5 do
    self.lightning[i+1] = love.graphics.newImage("assets/img/scenes/entry/0".. i ..".png")
  end
  self.background = love.graphics.newImage("assets/img/scenes/entry/background.png")
  self.bone       = love.graphics.newImage("assets/img/items/2/bone-decor.png")
  self.crown1     = love.graphics.newImage("assets/img/items/2/crown-1-decor.png")
  
  self.animation = {
    BEGIN   = Object:create('core/animation', 200, true),
    LEAVING = Object:create('core/animation', 2000, false)
  }
  
  self.loot = {
    STICK  = false,
    BONE   = false,
    CROWN1 = false
  }
  
  self.state = {
    BEGIN   = 0,
    BONE    = 1,
    STICK   = 2,
    LEAVING = 255
  }
  
  self.step = self.state.BEGIN
  
  self.entities = {}
  table.insert(self.entities, {id="COLUMN", x=90, y=60,   width=28, height=192, mousevisible=true})
  table.insert(self.entities, {id="BONE",   x=304, y=246, width=self.bone:getWidth(), height=self.bone:getHeight(), mousevisible=true})
  table.insert(self.entities, {id="CROWN1", x=472, y=32,  width = self.crown1:getWidth(), height=self.crown1:getHeight(), mousevisible=true})
  table.insert(self.entities, {id="DOOR", x=508, y=40, width=52, height=230, mousevisible=true})
  
  self.fading = 1
  self.blink  = {1,2,3,4,5,4,3,2}
  self.index  = 1
end

function Entry:update(dt)
  love.mouse.setVisible(not self:blocked())
  
  self:cursor()
  self:blinking(dt)
  
  if self.step == self.state.LEAVING then
    local progress = self.animation.LEAVING:update(dt)
    
    if progress > 0 then
      self.fading = progress
    else
      self:enter()
      self.game:setStep(self.game.step.ROOM)
    end
  end
end

function Entry:draw()
  love.graphics.draw(self.background, 0, 0)
  love.graphics.draw(self.lightning[self.blink[self.index]], 508, 0)
  
  if not self.loot.BONE then
    love.graphics.draw(self.bone, 304, 246)
  end

  if not self.loot.CROWN1 then
    love.graphics.draw(self.crown1, 472, 32)
  end

  if self.step == self.state.LEAVING then
    self:leaving(1-self.fading)
  end
  
  self.game.text = {"J'ai l'impression de connaître", "cet endroit. Mais pourquoi ?", ""}
end

function Entry:blinking(dt)
  local progress = self.animation.BEGIN:update(dt)
  
  if progress <= 0 then
    if self.index < #self.blink then
      self.index = self.index + 1
    else
      self.index = 1
    end
  end
end

function Entry:blocked()
  return self.step == self.state.LEAVING
end

function Entry:mousepressed(x, y, button)
  if button == 1 and not self:blocked() then
    if self:isTouchingEntityById("DOOR") and not self.game.inventory:isDragging() then
      self.step = self.state.LEAVING
    end

    if not self.loot.STICK and self:isTouchingEntityById("COLUMN") and not self.game.inventory:isDragging() then
      self:removeEntity("COLUMN")
      self.game.inventory:add("STICK")
      self.step = self.state.STICK
      self.loot.STICK = true
    end
    
    if not self.loot.BONE and self:isTouchingEntityById("BONE") and not self.game.inventory:isDragging() then
      self:removeEntity("BONE")
      self.game.inventory:add("BONE")
      self.step = self.state.BONE
      self.loot.BONE = true
    end

    if not self.loot.CROWN1 and self:isTouchingEntityById("CROWN1") and not self.game.inventory:isDragging() then
      self:removeEntity("CROWN1")
      self.game.inventory:add("CROWN1")
      self.loot.CROWN1 = true
    end
  end
end

return Entry