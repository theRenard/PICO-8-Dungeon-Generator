-- class

class=setmetatable({
	extend=function(self,tbl)
		tbl=tbl or {}
		tbl.__index=tbl
		return setmetatable(tbl,{
			__index=self,
			__call=function(self,...)
				return self:new(...)
			end
		})
	end,

	new=function(self,tbl)
		tbl=setmetatable(tbl or {},self)
		tbl:init()
		return tbl
	end,

	init=noop,
},{ __index=_ENV })