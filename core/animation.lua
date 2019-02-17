local Object = require('core/object')

local Animation = {}
Object:instantiate(Animation)

function Animation:new(delay, loop)
  self.argdelay = delay
  self.argloop = loop
  self:reset()
  
  return self
end

function Animation:reset()
  self.loop  = self.argloop
  self.done  = false
  self.timer = 0
  self.speed = self.argdelay/1000
  self.value = 0
end

function Animation:update(dt)
  if self.timer < self.speed then
    self.timer = self.timer + dt
    self.value = (100 - math.floor(self.timer * 100 / self.speed)) / 100
    
    if self.timer >= self.speed then
      if self.loop then
        self.value = 0
        self.timer = 0
      else
        self.done = true
      end
    end
  end
  
  return self.value
end

function Animation:isRunning()
  return self.done
end

return Animation