-- 低容量全国マップ専用LUAスクリプト (Z0-12対応版 / 構文エラー修正)

function init_function(name, is_first)
end

function exit_function()
end

function node_function()
  local place = Find("place")
  if place ~= "" then
    local mz = 12 -- デフォルトを12にする
    
    if place == "country" then
      mz = 0
    elseif place == "state" then -- 都道府県
      mz = 2
    elseif place == "city" then
      mz = 6 -- z6から市を表示
    elseif place == "town" then
      mz = 9 -- z9から町を表示
    elseif place == "suburb" or place == "quarter" then
      mz = 11 -- z11から地区名を表示
    else
      return
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
  local highway = Find("highway")
  local landuse = Find("landuse")
  local leisure = Find("leisure")
  local is_closed = IsClosed()

  -- 1. 海岸線 (陸地)
  if natural == "coastline" then
    Layer("water", true)
    Attribute("class", "land")
    MinZoom(0) -- ズーム 0 から陸地を表示
    return
  end
  
  -- 2. 水域 (湖、川)
  if natural == "water" or Find("waterway") == "riverbank" then
    Layer("water", true)
    
    -- ★★★ エラー修正 ★★★
    -- 変更前: Attribute("class", if natural == "water" then "lake" else "river" end)
    -- 変更後: Luaの (A and B or C) 形式の三項演算子を使用
    Attribute("class", (natural == "water" and "lake") or "river")
    
    MinZoom(is_closed and 4 or 8) -- 湖はz4から、川岸はz8から
    return
  end
  
  -- 3. 地表 (植生、地形)
  if is_closed then
    local l = natural
    if l == "" then l = leisure end
    if l == "" then l = landuse end

    local mz_land = 12
    local class = ""

    if l == "wood" or l == "forest" then
      class = "wood"
      mz_land = 8 -- z8から森林を表示
    elseif l == "farmland" or l == "farm" or l == "meadow" then
      class = "farmland"
      mz_land = 8 -- z8から農地を表示
    elseif l == "bare_rock" or l == "scree" or l == "fell" then
      class = "bare_rock"
      mz_land = 9
    elseif l == "park" or l == "garden" then
        class = "park"
        mz_land = 10
    elseif l == "" then
      -- 陸地として扱う（閉じたポリゴンで属性がない場合）
      class = "land"
      mz_land = 0 -- z0から地面を表示
    end

    if class ~= "" then
        Layer("landcover", true)
        Attribute("class", class)
        MinZoom(mz_land)
        return
    end
  end
  
  -- 4. 交通 (道路)
  if highway ~= "" then
    local mz = 12 -- デフォルトはz12
    local h = highway
    
    if highway == "motorway" or highway == "trunk" then
      mz = 2
    elseif highway == "primary" then
      mz = 4
    elseif highway == "secondary" then
      mz = 6
    elseif highway == "tertiary" then
      mz = 8
    elseif highway == "residential" or highway == "unclassified" then
      mz = 10 
    else
      return
    end
    
    Layer("transportation", false)
    Attribute("class", h)
    MinZoom(mz)
  end
end

function relation_function()
  local type = Find("type")
  
  -- 1. 行政界
  if type == "boundary" and Find("boundary") == "administrative" then
    local admin_level = Find("admin_level")
    local mz = 12
    
    if admin_level == "2" then -- 国境
      mz = 0
    elseif admin_level == "4" then -- 都道府県境
      mz = 2
    else
      return
    end
    
    Layer("boundary", false)
    Attribute("admin_level", admin_level)
    MinZoom(mz)
    return
  end
  
  -- 2. マルチポリゴン (海岸線、大きな湖、島の穴など)
  if type == "multipolygon" then
    ProcessWayMembers(way_function)
  end
end