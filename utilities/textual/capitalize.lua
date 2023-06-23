return function(txt)
    return string.upper(string.sub(txt, 1, 1)) .. string.sub(txt, 2, #txt)
end
