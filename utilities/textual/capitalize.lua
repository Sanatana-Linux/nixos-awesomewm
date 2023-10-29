--             ______               __ __          __ __
--            |      |.---.-.-----.|__|  |_.---.-.|  |__|.-----.-----.
--            |   ---||  _  |  _  ||  |   _|  _  ||  |  ||-- __|  -__|
--            |______||___._|   __||__|____|___._||__|__||_____|_____|
--                          |__|
--   +---------------------------------------------------------------+
-- A real capital idea!
-- @param txt string
-- @return string the contents of txt but capitalized
return function(txt)
    return string.upper(string.sub(txt, 1, 1)) .. string.sub(txt, 2, #txt)
end
