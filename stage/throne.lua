local Object = require('core/object')
local Stage  = require('core/stage')

local Throne = {}
Object:instantiate(Throne, Stage)

function Throne:new(game)
  self.game = game
  
  self.scream = love.audio.newSource("assets/audio/scenes/throne/scream.mp3", "static")
  self.scream:setVolume(0.1)
  
  self.lightning = {}
  for i=0,5 do
    self.lightning[i+1] = love.graphics.newImage("assets/img/scenes/throne/0".. i ..".png")
  end
  
  self.background  = love.graphics.newImage("assets/img/scenes/throne/background.png")
  self.background2 = love.graphics.newImage("assets/img/scenes/throne/background2.png")
  self.character   = love.graphics.newImage("assets/img/scenes/throne/char-standing-blurry.png")
  
  self.animation = {
    BEGIN  = Object:create('core/animation', 200,   true),
    DIALOG = Object:create('core/animation', 4000,  false),
    PAUSE  = Object:create('core/animation', 1000,  false),
    FADING = Object:create('core/animation', 16000, false),
    ZOOM   = Object:create('core/animation', 8300,  false),
    ENDING = Object:create('core/animation', 2000,  false)
  }
  
  self.state = {
    BEGIN  = 0,
    DIALOG = 1,
    PAUSE  = 2,
    ZOOM   = 3,
    ENDING = 255
  }
  
  self.diablog = {
    "Je me souviens désormais...",
    "J'étais jadis le maître de ces lieux.",
    "Ce château est...",
    "Mon tombeau."
  }
  
  self.step = self.state.BEGIN

  self.blink = {1,2,3,4,5,4,3,2}
  self.index = 1
  
  self.fading = 1
  self.scaling = 1
  self.plot = 1
  self.translate = 0
  
  self.diablog.step = 1
  
  self.entities = {}
  table.insert(self.entities, {id="THRONE", x=230, y=108, width=140, height=172, mousevisible=true})
end

function Throne:zoom(dt)
  local progress = self.animation.ZOOM:update(dt)
  
  if progress > 0 then
    self.scaling = 1+(1-progress)
    self.translate = 600 - (600/self.scaling) 
  end
end

function Throne:ending(dt)
  local progress = self.animation.FADING:update(dt)
  
  if progress > 0 then
    self.fading = progress
  else
    self.step = self.state.ENDING
  end
end

function Throne:nextDialog(dt)
  local progress = self.animation.DIALOG:update(dt)
  
  if progress <= 0 then
    self.animation.DIALOG:reset()
    return true
  end
  
  return false
end

function Throne:update(dt)
  self:cursor()
  
  self:blinking(dt)
  
  if self.step == self.state.DIALOG then
      if self.diablog.step == 1 then
        if self:nextDialog(dt) then
          self.diablog.step = self.diablog.step + 1
        end
      elseif self.diablog.step == 2 then
        if self:nextDialog(dt) then
          self.diablog.step = self.diablog.step + 1
        end
      elseif self.diablog.step == 3 then
        if self:nextDialog(dt) then
          self.diablog.step = self.diablog.step + 1
        end
      else if self.diablog.step == 4 then
        if self:nextDialog(dt) then
          self.step = self.state.PAUSE
        end
      end
    end
  end
  
  if self.step == self.state.PAUSE then
    local progress = self.animation.PAUSE:update(dt)
    
    if progress <= 0 then
      self.step = self.state.ZOOM
      self.scream:play()
    end
  end
  
  if self.step == self.state.ZOOM then
    self:zoom(dt)
    self:ending(dt)
  end
  
  if self.step == self.state.ENDING then
    self.game:setStep(self.game.step.CREDIT)
  end
end

function Throne:draw()
  love.graphics.push()

  if self.step == self.state.ZOOM then
    love.graphics.scale(self.scaling, self.scaling)
    love.graphics.translate(-self.translate/2, -self.translate/5)
  end
  
  if self.step < self.state.ZOOM then
    love.graphics.draw(self.background, 0, 0)
    love.graphics.draw(self.character, 100, 174)
  else
    love.graphics.draw(self.background2, 0, 0)
    love.graphics.draw(self.lightning[self.blink[self.index]], 192, 70)
  end

  if self.step == self.state.DIALOG or self.step == self.state.PAUSE then
    self.game.gui.text:draw(self.diablog[self.diablog.step], 15, 380 - 16)
  end
  
  if self.step == self.state.PAUSE then
    love.graphics.push("all")
    love.graphics.setColor(0, 0, 0, self.plot)
    love.graphics.rectangle("fill", 0, 0, 600, 400)
    love.graphics.pop("all")
  end

  if self.step == self.state.ZOOM then
    self:leaving(1-self.fading)
  end

  love.graphics.pop()
end

function Throne:blinking(dt)
  local progress = self.animation.BEGIN:update(dt)
  
  if progress <= 0 then
    if self.index < #self.blink then
      self.index = self.index + 1
    else
      self.index = 1
    end
  end
end

function Throne:mousepressed(x, y, button)
  if button == 1 then
    if self.step == self.state.BEGIN and self:isTouchingEntityById("THRONE") then
      self:removeEntity("THRONE")
      love.mouse.setVisible(false)
      self.step = self.state.DIALOG
    end
  end
end

return Throne