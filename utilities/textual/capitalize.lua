-- @param txt string
-- @return string the contents of txt but capitalized
return function(txt)
    return string.upper(string.sub(txt, 1, 1)) .. string.sub(txt, 2, #txt)
end
