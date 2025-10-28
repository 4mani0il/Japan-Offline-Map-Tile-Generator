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
      mz = 2 -- z0からz2に変更（容量削減）
    elseif place == "state" then -- 都道府県
      mz = 3 -- z2からz3に変更（容量削減）
    elseif place == "city" then
      mz = 7 -- z6からz7に変更
    elseif place == "town" then
      mz = 10 -- z9からz10に変更
    elseif place == "suburb" or place == "quarter" then
      return -- 地区名は除外して容量削減
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
  
  -- 3. 地表 (植生、地形) - 容量削減のため重要度の高いもののみ
  if is_closed then
    local l = natural
    if l == "" then l = leisure end
    if l == "" then l = landuse end

    local mz_land = 12
    local class = ""

    if l == "wood" or l == "forest" then
      class = "wood"
      mz_land = 9 -- z9から森林を表示（8から9に変更）
    elseif l == "farmland" or l == "farm" then
      class = "farmland"
      mz_land = 9 -- z9から農地を表示（8から9に変更）
    elseif l == "" then
      -- 陸地として扱う（閉じたポリゴンで属性がない場合）
      class = "land"
      mz_land = 0 -- z0から地面を表示
    end
    -- meadow, park, bare_rock等は除外して容量削減

    if class ~= "" then
        Layer("landcover", true)
        Attribute("class", class)
        MinZoom(mz_land)
        return
    end
  end
  
  -- 4. 交通 (道路) - 容量削減のため主要道路のみ
  if highway ~= "" then
    local mz = 12 -- デフォルトはz12
    local h = highway
    
    if highway == "motorway" or highway == "trunk" then
      mz = 4
    elseif highway == "primary" then
      mz = 6
    elseif highway == "secondary" then
      mz = 8
    elseif highway == "tertiary" then
      mz = 10
    else
      return -- residential/unclassifiedは除外
    end
    
    Layer("transportation", false)
    Attribute("class", h)
    MinZoom(mz)
  end
end

function relation_function()
  local type = Find("type")
  
  -- 1. 行政界 - 容量削減のため国境と都道府県境のみ
  if type == "boundary" and Find("boundary") == "administrative" then
    local admin_level = Find("admin_level")
    local mz = 12
    
    if admin_level == "2" then -- 国境
      mz = 2 -- z0からz2に変更
    elseif admin_level == "4" then -- 都道府県境
      mz = 3 -- z2からz3に変更
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