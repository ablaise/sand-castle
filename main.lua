io.stdout:setvbuf("no")
love.graphics.setDefaultFilter("nearest")

local Object = require('core/object')
local Game = Object:create('game')

function love.load()
  love.window.setTitle("Sand Castle - Gamecodeur game jam 16")
  love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
  love.mouse.setVisible(true)
  love.window.setMode(600, 400)
end

function love.update(dt)
  Game:update(dt)
end

function love.draw()
  Game:draw()
end

function love.keypressed(key)
  Game:keypressed(key)
end

function love.keyreleased(key)
  Game:keyreleased(key)
end

function love.mousepressed(x, y, button)
  Game:mousepressed(x, y, button)
end
 
function love.mousereleased(x, y, button)
  Game:mousereleased(x, y, button)
end