local Object = require('core/object')

local Inventory = {}
Object:instantiate(Inventory)

function Inventory:new()
  self.inventory = {}
  self.itemdb = {}
  
  self.loot = love.audio.newSource("assets/audio/loot.mp3", "static")
  self.loot:setVolume(0.6)
  
  self.pick = love.audio.newSource("assets/audio/inventory.wav", "static")
  self.pick:setVolume(0.2)
  
  -- inventory slots
  self.slots = {}
  table.insert(self.slots, {x=346, y=340})
  table.insert(self.slots, {x=390, y=340})
  table.insert(self.slots, {x=434, y=340})
  table.insert(self.slots, {x=478, y=340})
  table.insert(self.slots, {x=522, y=340})
  
  -- items database
  table.insert(self.itemdb, self:createItem("BONE",    "assets/img/items/1/bone-inventory.png"))
  table.insert(self.itemdb, self:createItem("POMMEL",  "assets/img/items/1/pommel-inventory.png"))
  table.insert(self.itemdb, self:createItem("STICK",   "assets/img/items/1/stick-inventory.png"))
  table.insert(self.itemdb, self:createItem("SCEPTER", "assets/img/items/1/scepter-inventory.png"))
  table.insert(self.itemdb, self:createItem("CROWN1",  "assets/img/items/1/crown-1-inventory.png"))
  table.insert(self.itemdb, self:createItem("CROWN2",  "assets/img/items/1/crown-2-inventory.png"))
  table.insert(self.itemdb, self:createItem("CROWN3",  "assets/img/items/1/crown-3-inventory.png"))
  table.insert(self.itemdb, self:createItem("CROWN",   "assets/img/items/1/crown-complete-inventory.png"))
  
  self.dragging = false
  self.picked = nil
end

function Inventory:update(dt)
  if self:isTouchingItem() and not self:isDragging() then
    love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
  end
end

function Inventory:draw()
  for i=1,#self.inventory do
    love.graphics.draw(self.inventory[i].image, self.slots[i].x, self.slots[i].y)
  end
end

function Inventory:add(id)
  for i=1,#self.itemdb do
    if self.itemdb[i].id == id then
      table.insert(self.inventory, self.itemdb[i])
      self.loot:play()
      return true
    end
  end
  
  return false
end

function Inventory:createItem(id, icon)
  local item = {}
  item.id = id
  item.image = love.graphics.newImage(icon)
  item.icon = icon
  item.position = #self.inventory + 1
  item.visble = true

  return item
end

function Inventory:delete(id)
  for i=1,#self.inventory do
    if self.inventory[i].id == id then
      table.remove(self.inventory, i)
      return true
    end
  end
  
  return false
end

function Inventory:hasItem(id)
  for i=1,#self.inventory do
    if self.inventory[i].id == id then
      return true
    end
  end
  
  return false
end

function Inventory:getItemPosition(id)
  for i=1,#self.inventory do
    if self.inventory[i].id == id then
      return i
    end
  end
  
  return false
end

function Inventory:isTouchingItem()
  local slot = {}
  slot.width  = 40
  slot.height = 40
  
  for i=1,#self.slots do
    slot.x = self.slots[i].x
    slot.y = self.slots[i].y
    
    if self:isTouching(slot) then
      return self.inventory[i]
    end
  end

  return nil
end

function Inventory:mousepressed(x, y, button)
  local item = self:isTouchingItem()
  
  self.dragging = false
  self.picked = nil
  
  if item ~= nil then
    -- clicking on an inventory box
    self.pick:play()
    love.mouse.setCursor(love.mouse.newCursor(item.icon, 20, 20))
    self.dragging = true
    self.picked = item.id
  end
end

function Inventory:release()
  self.dragging = false
  self.picked = nil
end

function Inventory:isDragging()
  return self.dragging
end

function Inventory:isDraggingItem(id)
  return self.picked == id
end

function Inventory:isTouching(area)
  return love.mouse.getX() >= area.x 
     and love.mouse.getX() <= (area.x + area.width)
     and love.mouse.getY() >= area.y
     and love.mouse.getY() <= (area.y + area.height)
end

return Inventory