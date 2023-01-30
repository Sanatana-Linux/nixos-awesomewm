-- trim strings
return function(input)
  local result = input:gsub("%s+", "")
  return string.gsub(result, "%s+", "")
end
