local Object = require('core/object')
local Stage = require('core/stage')

local Credit = {}
Object:instantiate(Credit, Stage)

function Credit:new(game)
  self.game = game
  self.background = love.graphics.newImage("assets/img/scenes/credit/background.png")
end

function Credit:update(dt)
end

function Credit:draw()
  love.graphics.draw(self.background, 0, 0)
end

function Credit:mousepressed(x, y, button)
end

return Credit