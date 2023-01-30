--  ___ ___ __
-- |   |   |__|.----.-----.
-- |   |   |  ||  __|  -__|
--  \_____/|__||____|_____|
-- ------------------------------------------------- --
-- The vice base16 theme for awesomewm, yes I made my own base16 theme
-- instead of using Nord or Gruvbox or Catppucin or whatever cool kids like
-- this week. I like what I like and its not any of those color schemes
-- ------------------------------------------------- --
--  TIP: tailwind shades website is great for finding shades of color, or colorspace for matching colors
return {
  -- ------------------------------------------------- --
  -- Colors

  color1 = "#919191",
  color2 = "#ff5c72",
  color3 = "#44ffdd",
  color4 = "#ffffaf",
  color5 = "#00caff",
  color6 = "#664ed0",
  color7 = "#38ffff",
  color8 = "#b6b6b6",
  color9 = "#9d0216",
  color10 = "#00b893",
  color11 = "#ffff73",
  color12 = "#008fb3",
  color13 = "#8265ff",
  color14 = "#03ddc4",
  color15 = "#a9a9a9",
  color16 = "#b92b27",
  color17 = "#05d69e",
  color18 = "#f7f990",
  color19 = "#1b9bac",
  color20 = "#8236ec",
  color21 = "#06bbe0",

  -- ------------------------------------------------- --
  -- Grays
  colorA = "#0c0c0c",
  colorB = "#111111",
  colorC = "#181818",
  colorD = "#1c1c1c",
  colorE = "#202020",
  colorF = "#222222",
  colorG = "#252525",
  colorH = "#262626",
  colorI = "#272727",
  colorJ = "#282828",
  colorK = "#292929",
  colorL = "#2a2a2a",
  colorM = "#2f2f2f",
  colorN = "#323232",
  colorO = "#353535",
  colorP = "#3b3b3b",
  colorQ = "#404040",
  colorR = "#444444",
  colorS = "#525252",
  colorT = "#555555",
  colorU = "#595959",
  colorV = "#5f5F5F",
  colorW = "#696969",
  colorX = "#818181",
  colorY = "#919191",
  colorZ = "#bbbbbb",
  -- ------------------------------------------------- --
  lesswhite = "#d1d1d1",
  white = "#e9e9e9",
  black = "#111111",
  blacker = "#000000",
  icons = "#e9e9e9",
  alpha = function(color, alpha)
    return color .. alpha
  end
}
