--- The Path class.
-- The `path` class is a structure which represents a path (ordered set of nodes) from a start location to a goal.
-- An instance from this class would be a result of a request addressed to `Pathfinder:getPath`.
--
-- This module is internally used by the library on purpose.
-- It should normally not be used explicitely, yet it remains fully accessible.
--


if (...) then
	
  -- Dependencies
	local _PATH = (...):match('(.+)%.path$')
  local Heuristic = require (_PATH .. '.heuristics')
	
	 -- Local references
  local abs, max = math.abs, math.max
	local t_insert, t_remove = table.insert, table.remove
	
	--- The `Path` class.<br/>
	-- This class is callable.
	-- Therefore,_ <code>Path(...)</code> _acts as a shortcut to_ <code>Path:new(...)</code>.
	-- @type Path
  local Path = {}
  Path.__index = Path

  --- Inits a new `path`.
  -- @class function
  -- @treturn path a `path`
	-- @usage local p = Path()
  function Path:new()
    return setmetatable({_nodes = {}}, Path)
  end

  --- Iterates on each single `node` along a `path`. At each step of iteration,
  -- returns the `node` plus a count value. Aliased as @{Path:nodes}
  -- @class function
  -- @treturn node a `node`
  -- @treturn int the count for the number of nodes
	-- @see Path:nodes
	-- @usage
	-- for node, count in p:iter() do
	--   ...
	-- end
  function Path:iter()
    local i,pathLen = 1,#self._nodes
    return function()
      if self._nodes[i] then
        i = i+1
        return self._nodes[i-1],i-1
      end
    end
  end
  
  --- Iterates on each single `node` along a `path`. At each step of iteration,
  -- returns a `node` plus a count value. Alias for @{Path:iter}
  -- @class function
	-- @name Path:nodes
  -- @treturn node a `node`
  -- @treturn int the count for the number of nodes
	-- @see Path:iter	
	-- @usage
	-- for node, count in p:nodes() do
	--   ...
	-- end	
	Path.nodes = Path.iter
	
  --- Evaluates the `path` length
  -- @class function
  -- @treturn number the `path` length
	-- @usage local len = p:getLength()
  function Path:getLength()
    local len = 0
    for i = 2,#self._nodes do
      len = len + Heuristic.EUCLIDIAN(self._nodes[i], self._nodes[i-1])
    end
    return len
  end
	
	--- Counts the number of steps.
	-- Returns the number of waypoints (nodes) in the current path.
	-- @class function
	-- @tparam node node a node to be added to the path
	-- @tparam[opt] int index the index at which the node will be inserted. If omitted, the node will be appended after the last node in the path.
	-- @treturn path self (the calling `path` itself, can be chained)
	-- @usage local nSteps = p:countSteps()
	function Path:addNode(node, index)
		index = index or #self._nodes+1
		t_insert(self._nodes, index, node)
		return self
	end
	
	
  --- `Path` filling modifier. Interpolates between non contiguous nodes along a `path`
  -- to build a fully continuous `path`. This maybe useful when using search algorithms such as Jump Point Search.
  -- Does the opposite of @{Path:filter}
  -- @class function
	-- @treturn path self (the calling `path` itself, can be chained)	
  -- @see Path:filter
	-- @usage p:fill()
  function Path:fill()
    local i = 2
    local xi,yi,dx,dy
    local N = #self._nodes
    local incrX, incrY
    while true do
      xi,yi = self._nodes[i]._x,self._nodes[i]._y
      dx,dy = xi-self._nodes[i-1]._x,yi-self._nodes[i-1]._y
      if (abs(dx) > 1 or abs(dy) > 1) then
        incrX = dx/max(abs(dx),1)
        incrY = dy/max(abs(dy),1)
        t_insert(self._nodes, i, self._grid:getNodeAt(self._nodes[i-1]._x + incrX, self._nodes[i-1]._y +incrY))
        N = N+1
      else i=i+1
      end
      if i>N then break end
    end
		return self
  end

  --- `Path` compression modifier. Given a `path`, eliminates useless nodes to return a lighter `path` 
	-- consisting of straight moves. Does the opposite of @{Path:fill}
  -- @class function
	-- @treturn path self (the calling `path` itself, can be chained)	
  -- @see Path:fill
	-- @usage p:filter()
  function Path:filter()
    local i = 2
    local xi,yi,dx,dy, olddx, olddy
    xi,yi = self._nodes[i]._x, self._nodes[i]._y
    dx, dy = xi - self._nodes[i-1]._x, yi-self._nodes[i-1]._y
    while true do
      olddx, olddy = dx, dy
      if self._nodes[i+1] then
        i = i+1
        xi, yi = self._nodes[i]._x, self._nodes[i]._y
        dx, dy = xi - self._nodes[i-1]._x, yi - self._nodes[i-1]._y
        if olddx == dx and olddy == dy then
          t_remove(self._nodes, i-1)
          i = i - 1
        end
      else break end
    end
		return self
  end

  return setmetatable(Path,
    {__call = function(self,...)
      return Path:new(...)
    end
  })
end