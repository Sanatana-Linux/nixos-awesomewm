--       _______               __
--      |     __|.--.--.-----.|  |_.-----.--------.
--      |__     ||  |  |__ --||   _|  -__|        |
--      |_______||___  |_____||____|_____|__|__|__|
--               |_____|
--   +---------------------------------------------------------------+
--      Initializes the system-wide control signals
return {
  require(... .. ".bluetooth"),
  require(... .. ".brightness"),
  require(... .. ".network"),
  require(... .. ".picom"),
  require(... .. ".volume"),
}
