local Object = require('core/object')

local Game = {}
Object:instantiate(Game)

function Game:new()
  self.gui = {}
  self.font = love.graphics.newFont("assets/fonts/9k.ttf", 16)
  self.gui.text = Object:create('core/ui/font', self.font, 16, 1, 16, 16)
  self.text = {"", "", ""}
  
  self.panel = love.graphics.newImage("assets/img/panel.png")
  
  self.wind = love.audio.newSource("assets/audio/scenes/title/wind.mp3", "static")
  self.wind:setVolume(1)
  self.wind:setLooping(true)
  
  self.inventory = Object:create('inventory')
  
  self.craft = love.audio.newSource("assets/audio/metal-clash.wav", "static")
  self.craft:setVolume(0.1)
  
  self.stage = {}
  self.stage.title  = Object:create('stage/title', self)
  self.stage.entry  = Object:create('stage/entry', self)
  self.stage.room   = Object:create('stage/room', self)
  self.stage.throne = Object:create('stage/throne', self)
  self.stage.credit = Object:create('stage/credit', self)
  
  self.step = {
    TITLE  = 1,
    ENTRY  = 2,
    ROOM   = 3,
    THRONE = 4,
    CREDIT = 5
  }

  self.current = self.step.TITLE
  
  self.crafting = {}
  self.crafting.scepter = {}
  self.crafting.scepter.reward = "SCEPTER"
  table.insert(self.crafting.scepter, "STICK")
  table.insert(self.crafting.scepter, "POMMEL")
  
  self.crafting.crown = {}
  self.crafting.crown.reward = "CROWN"
  table.insert(self.crafting.crown, "CROWN1")
  table.insert(self.crafting.crown, "CROWN2")
  table.insert(self.crafting.crown, "CROWN3")
  
  self.lastposition = 0
end

function Game:update(dt)
  if self.current == self.step.TITLE then
    self.stage.title:update(dt)
  elseif self.current == self.step.ENTRY then
    self.stage.entry:update(dt)
  elseif self.current == self.step.ROOM then
    self.stage.room:update(dt)
  elseif self.current == self.step.THRONE then
    self.stage.throne:update(dt)
  elseif self.current == self.step.CREDIT then
    self.stage.credit:update(dt)
  end
  
  if self.current == self.step.ENTRY or self.current == self.step.ROOM then
    self.inventory:update(dt)
  end
end

function Game:draw()
  if self.current == self.step.TITLE then
    self.stage.title:draw()
  elseif self.current == self.step.ENTRY then
    self.stage.entry:draw()
  elseif self.current == self.step.ROOM then
    self.stage.room:draw()
  elseif self.current == self.step.THRONE then
    self.stage.throne:draw()
  elseif self.current == self.step.CREDIT then
    self.stage.credit:draw()
  end
  
  if self.current == self.step.ENTRY or self.current == self.step.ROOM then
    love.graphics.draw(self.panel, 0, 320)
    self:drawText()
    self.inventory:draw()
  end
end

function Game:drawText()
  local count = 0
  
  for i=1,#self.text do
    if self.text[i] ~= "" then
      count = count + 1
    end
  end
  
  if count == 1 then
    self.gui.text:draw(self.text[1], 35, 347)
  elseif count == 2 then
    self.gui.text:draw(self.text[1], 35, 337)
    self.gui.text:draw(self.text[2], 35, 357)
  elseif count == 3 then
    self.gui.text:draw(self.text[1], 35, 329)
    self.gui.text:draw(self.text[2], 35, 347)
    self.gui.text:draw(self.text[3], 35, 365)
  end
end

function Game:mousepressed(x, y, button)
  if self.current == self.step.TITLE then
    self.stage.title:mousepressed(x, y, button)
  elseif self.current == self.step.ENTRY then
    self.stage.entry:mousepressed(x, y, button)
  elseif self.current == self.step.ROOM then
    self.stage.room:mousepressed(x, y, button)
  elseif self.current == self.step.THRONE then
    self.stage.throne:mousepressed(x, y, button)
  elseif self.current == self.step.CREDIT then
    self.stage.credit:mousepressed(x, y, button)
  end
  
  self.inventory:mousepressed(x, y, button)
  
  if button == 1 then
    -- target item
    local item = self.inventory:isTouchingItem()
    
    if item ~= nil then
      
      if self.lastposition ~= 0 and self.lastposition ~= self.inventory:getItemPosition(item.id) and self.inventory:isDragging() then
        for k in pairs(self.crafting) do 
          local complete = true
          local from = false
          local to = false
          
          -- if all the items of a set are in our inventory
          for i=1,#self.crafting[k] do
            complete = complete and self.inventory:hasItem(self.crafting[k][i])
            from = from or self.lastposition == self.inventory:getItemPosition(self.crafting[k][i])
            to = to or self.inventory:getItemPosition(item.id) == self.inventory:getItemPosition(self.crafting[k][i])
          end

          -- we can combine items
          if complete and from and to then
            for i=1,#self.crafting[k] do
              self.inventory:delete(self.crafting[k][i])
            end
            
            self.inventory:add(self.crafting[k]["reward"])
            self.inventory:release()
            self.craft:play()
          end
        end
      end
      self.lastposition = self.inventory:getItemPosition(item.id)
    else
      self.lastposition = 0
    end
  end
end

function Game:setStep(value)
  love.mouse.setVisible(true)
  
  if value == self.step.ENTRY then
    self.wind:setVolume(0.66)
    self.wind:play()
  elseif value == self.step.ROOM then
    self.wind:setVolume(0.33)
    self.wind:play()
  elseif value == self.step.THRONE then
    self.inventory:release()
    self.wind:stop()
  end

  self.current = value
end

function Game:mousereleased(x, y, button)
end

function Game:keypressed(key)
end

function Game:keyreleased(key)
end

return Game