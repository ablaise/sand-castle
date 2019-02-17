local Object = require('core/object')
local Stage  = require('core/stage')

local Title = {}
Object:instantiate(Title, Stage)

function Title:new(game)
  self.game = game
  
  self.font = love.graphics.newFont("assets/fonts/9k.ttf", 16)
  
  self.intro = love.audio.newSource("assets/audio/scenes/title/intro.mp3", "static")
  self.intro:setVolume(0.7)
  self.intro:setLooping(true)
  self.intro:play()
  
  self.background = {}
  for i=0,6 do
    self.background[i+1] = love.graphics.newImage("assets/img/scenes/title/0".. i ..".png")
  end
  self.title = love.graphics.newImage("assets/img/scenes/title/title.png")
  self.glove = love.graphics.newImage("assets/img/scenes/title/glove.png")
  
  self.state = {
    TITLE   = 0,
    FADING  = 1,
    PAUSE   = 2,
    CASTLE  = 3,
    LEAVING = 255
  }
  
  self.step = self.state.TITLE
  
  self.animation = {
    BEGIN  = Object:create('core/animation', 5000, false),
    BLINK  = Object:create('core/animation', 200,  true),
    PAUSE  = Object:create('core/animation', 6000, false),
    ENDING = Object:create('core/animation', 4000, false)
  }
  
  self.gui = {}
  self.gui.start = Object:create('core/ui/button', self.font, 16, 1, 16, 16)
  self.gui.quit  = Object:create('core/ui/button', self.font, 16, 1, 16, 16)
  self.gui.text  = Object:create('core/ui/font',   self.font, 16, 1, 16, 16)
  self.fading = 1

  -- clignotement du château
  self.blink = {1,2,3,4,5,6,7,6,5,4,3,2}
  self.index = 1
  
  self.entities = {}
  table.insert(self.entities, {id="CASTLE", x=358, y=177, width=168, height=105, mousevisible=true})
end

function Title:update(dt)
  if self.step >= self.state.CASTLE then
    self:cursor()
  end

  -- fondu sur la première scène du jeu
  if self.step == self.state.FADING then
    local progress = self.animation.BEGIN:update(dt)
    if progress > 0 then
      self.fading = progress
      self.intro:setVolume(self.fading)
    else
      self.intro:stop()
      self.game.wind:play()
      self.step = self.state.PAUSE
    end
  end

  -- pause de 6 secondes
  if self.step == self.state.PAUSE then
    local progress = self.animation.PAUSE:update(dt)
    if progress <= 0 then
      love.mouse.setVisible(true)
      self.step = self.state.CASTLE
    end
  end
  
  -- clignotement du château et activation des zones cliquables
  if self.step == self.state.CASTLE then
    local progress = self.animation.BLINK:update(dt)
    
    if progress <= 0 then
      if self.index < #self.blink then
        self.index = self.index + 1
      else
        self.index = 2
      end
    end
  end
  
  -- fondu vers la fin de la scène
  if self.step == self.state.LEAVING then
    local progress = self.animation.ENDING:update(dt)
    
    if progress > 0 then
      self.fading = progress
    else
      self.game:setStep(self.game.step.ENTRY)
    end
  end
end

function Title:draw()
  love.graphics.draw(self.background[self.blink[self.index]], 0, 0)
  love.graphics.draw(self.glove, 160, 204)
  
  if self.step == self.state.TITLE or self.step == self.state.FADING then
    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1, self.fading)
    love.graphics.draw(self.title, 185, 60)
    love.graphics.pop("all")
    
    self.gui.start:draw("Nouveau jeu", 246, 171, self.fading)
    self.gui.quit:draw("Quitter", 265, 210, self.fading)
  end
  
  if self.step == self.state.PAUSE or self.step == self.state.CASTLE then
    self.gui.text:draw("Des jours que j'erre dans le désert de mes rêves...", 15, 340)
    self.gui.text:draw("Cet étrange château me donnera peut-être des réponses.", 15, 360)
  end
  
  if self.step == self.state.LEAVING then
    self:leaving(1-self.fading)
  end
end

function Title:mousepressed(x, y, button)
  if button == 1 then
    if self.step == self.state.TITLE then
      if self.gui.start:click() then
        love.mouse.setVisible(false)
        self.gui.start:disable(true)
        self.gui.quit:disable(true)
        self.step = self.state.FADING
      end
      
      if self.gui.quit:click() then
        love.event.quit()
      end
    end
    
    if self.step == self.state.CASTLE then
      if self:isTouchingEntityById("CASTLE") then
        love.mouse.setVisible(false)
        self.step = self.state.LEAVING
      end
    end
  end
end

return Title