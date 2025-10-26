-- process-low.lua
-- 低容量全国マップ専用の最小限のLUAスクリプト
-- tilemaker v3.0.0対応版

function init_function(name, is_first)
end

function exit_function()
end

function node_function()
  local place = Find("place")
  if place ~= "" then
    local mz = 13
    if place == "country" then
      mz = 2
    elseif place == "state" then
      mz = 4
    elseif place == "city" then
      mz = 6
    elseif place == "town" then
      mz = 8
    elseif place == "village" then
      mz = 10
    elseif place == "hamlet" then
      mz = 10
    end
    
    Layer("place", false)
    Attribute("class", place)
    MinZoom(mz)
    local name = Find("name")
    if name ~= "" then
      Attribute("name", name)
    end
  end
end

function way_function()
  local natural = Find("natural")
  local waterway = Find("waterway")
  
  if natural == "water" or waterway == "riverbank" or natural == "coastline" or waterway == "river" or waterway == "stream" then
    Layer("water", false)
    MinZoom(0)
  end
end

function relation_function()
  local type = Find("type")
  local natural = Find("natural")
  local waterway = Find("waterway")
  
  if type == "multipolygon" then
    if natural == "water" or waterway == "riverbank" or natural == "coastline" or waterway == "river" or waterway == "stream" then
      Layer("water", false)
      MinZoom(0)
    end
  end
end
