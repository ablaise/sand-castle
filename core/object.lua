local Object = {}

function Object:instantiate(Class, Sub)
  Class.__index = Class
  setmetatable(Class, {
    __index = Sub,
    __call = function (cls, ...)
      local self = setmetatable({}, cls)
      if Sub ~= nil then
        Sub:new(...)
      end
      self:new(...)
      return self
    end
  })
end

function Object:create(name, ...)
  local class = Object:require(name)
  local instance = class(...)
  
  -- clear unused module and object
  self:unrequire(name)
  class = nil
  
  return instance
end

function Object:require(m)
  return require(m)
end

function Object:unrequire(m)
  package.loaded[m] = nil
  _G[m] = nil
end

return Object