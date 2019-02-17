local Object = require('core/object')
local Stage  = require('core/stage')

local Room = {}
Object:instantiate(Room, Stage)

function Room:new(game)
  self.game = game
  
  self.lightning = {}
  for i=0,5 do
    self.lightning[i+1] = love.graphics.newImage("assets/img/scenes/room/0".. i ..".png")
  end
  
  self.background = love.graphics.newImage("assets/img/scenes/room/background.png")
  
  self.skull = {}
  self.skull.a = love.graphics.newImage("assets/img/items/2/skull.png")
  self.skull.b = love.graphics.newImage("assets/img/items/2/skull-broke.png")
  self.eye     = love.graphics.newImage("assets/img/items/2/eye.png")
  self.crown2  = love.graphics.newImage("assets/img/items/2/crown-2-decor.png")
  self.crown3  = love.graphics.newImage("assets/img/items/2/crown-3-decor.png")
  self.glove   = love.graphics.newImage("assets/img/scenes/room/glove.png")
  
  self.broke = love.audio.newSource("assets/audio/scenes/room/broke.mp3", "static")
  self.door  = love.audio.newSource("assets/audio/scenes/room/door.mp3", "static")
  
  self.state = {
    BEGIN   = 0,
    SKULL   = 1,
    ENDING  = 2,
    LEAVING = 255
  }
  
  self.loot = {
    POMMEL = false,
    CROWN2 = false,
    CROWN3 = false
  }
  
  self.animation = {
    BEGIN   = Object:create('core/animation', 200,  true),
    LEAVING = Object:create('core/animation', 2000, false),
    ENDING  = Object:create('core/animation', 2000, false)
  }
  
  self.step = self.state.BEGIN
  
  self.entities = {}
  table.insert(self.entities, {id="SKULL", x=274, y=254, width=self.skull.a:getWidth(), height=self.skull.a:getHeight(), mousevisible=false})
  table.insert(self.entities, {id="CROWN2", x=246, y=24, width=self.crown2:getWidth(), height=self.crown2:getHeight(), mousevisible=true})
  table.insert(self.entities, {id="CROWN3", x=374, y=254, width = self.crown3:getWidth(), height=self.crown3:getHeight(), mousevisible=true})
  table.insert(self.entities, {id="DOOR", x=508, y=40, width=52, height=230, mousevisible=true})
  table.insert(self.entities, {id="EXIT", x=0, y=16, width=90, height=254, mousevisible=false})

  self.blink = {1,2,3,4,5,4,3,2}
  self.index = 1
end

function Room:update(dt)
  love.mouse.setVisible(not self:blocked())
  
  self:cursor()
  self:blinking(dt)
  
  if self.step == self.state.LEAVING then
    local progress = self.animation.LEAVING:update(dt)
    
    if progress > 0 then
      self.fading = progress
    else
      self:enter()
      self.game:setStep(self.game.step.ENTRY)
    end
  end
  
  if self.step == self.state.ENDING then
    local progress = self.animation.ENDING:update(dt)
    
    if progress > 0 then
      self.fading = progress
    else
      self.game:setStep(self.game.step.THRONE)
      self.game.inventory:delete("CROWN")
      self.game.inventory:delete("SCEPTER")
    end
  end
end

function Room:draw()
  love.graphics.draw(self.background, 0, 0)
  love.graphics.draw(self.lightning[self.blink[self.index]], 92, 16)
  love.graphics.draw(self.glove, 228, 210)
  
  if not self.loot.POMMEL then
    love.graphics.draw(self.skull.a, 274, 254)
  else
    love.graphics.draw(self.skull.b, 276, 260)
  end

  if self.game.inventory:hasItem("SCEPTER") then
    love.graphics.draw(self.eye, 6, 118)
  end
  
  if self.game.inventory:hasItem("CROWN") then
    love.graphics.draw(self.eye, 48, 118)
  end

  if not self.loot.CROWN2 then
    love.graphics.draw(self.crown2, 246, 24)
  end
  
  if not self.loot.CROWN3 then
    love.graphics.draw(self.crown3, 374, 254)
  end
  
  if self.game.inventory:hasItem("SCEPTER") and self.game.inventory:hasItem("CROWN") then
    self:setMouseVisibleEntity("EXIT", true)
    self.game.text = {"La porte s'est ouverte.", "", ""}
  else
    self.game.text = {"Je dois trouver le moyen de passer.", "", ""}
  end
  
  if self.step == self.state.LEAVING then
    self:leaving(1-self.fading)
  end
  
  if self.step == self.state.ENDING then
    self:leaving(1-self.fading)
  end
end

function Room:blinking(dt)
  local progress = self.animation.BEGIN:update(dt)
  
  if progress <= 0 then
    if self.index < #self.blink then
      self.index = self.index + 1
    else
      self.index = 1
    end
  end
end

function Room:blocked()
  return self.step == self.state.LEAVING or self.step == self.state.ENDING
end

function Room:mousepressed(x, y, button)
  if button == 1 and not self:blocked() then
    if self.step ~= self.state.ENDING and self:isTouchingEntityById("DOOR") and not self.game.inventory:isDragging() then
      self.step = self.state.LEAVING
    end
    
    if self.game.inventory:hasItem("SCEPTER") and self.game.inventory:hasItem("CROWN") and self:isTouchingEntityById("EXIT") and not self.game.inventory:isDragging() then
      self.door:play()
      self.step = self.state.ENDING
    end
    
    if self:isTouchingEntityById("SKULL") and self.game.inventory:isDraggingItem("BONE") then
      self:removeEntity("SKULL")
      self.loot.POMMEL = true
      self.broke:play()
      self.game.inventory:delete("BONE")
      self.game.inventory:add("POMMEL")
      self.step = self.state.SKULL
    end
    
    if not self.loot.CROWN2 and self:isTouchingEntityById("CROWN2") and not self.game.inventory:isDragging() then
      self:removeEntity("CROWN2")
      self.game.inventory:add("CROWN2")
      self.loot.CROWN2 = true
    end
    
    if not self.loot.CROWN3 and self:isTouchingEntityById("CROWN3") and not self.game.inventory:isDragging() then
      self:removeEntity("CROWN3")
      self.game.inventory:add("CROWN3")
      self.loot.CROWN3 = true
    end
  end
end

return Room