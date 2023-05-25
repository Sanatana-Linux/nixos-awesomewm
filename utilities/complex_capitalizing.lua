local capitalize = require('utilities.capitalize')
-- a fully capitalizing helper.
return function(s)
	local r, i = '', 0
	for w in s:gsub('-', ' '):gmatch('%S+') do
		local cs = capitalize(w)
		if i == 0 then
			r = cs
		else
			r = r .. ' ' .. cs
		end
		i = i + 1
	end

	return r
end
