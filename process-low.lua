-- process-low.lua
-- 超軽量マップ専用の、最小限のLUAスクリプト (修正版 3)

Layers = {}

function setup_function()
  Layers.water = Layer("water")
  Layers.place = Layer("place")
  SetAreaLayers(Layers.water)
end

-- 4. ノード（点）の処理
function node_function(node)
  -- ▼▼▼▼▼ ここを修正 ▼▼▼▼▼
  -- 1. 'node'自体がnilでないか確認
  if not node then
    return
  end
  -- ▲▲▲▲▲ 修正ここまで ▲▲▲▲▲

  local tags = node:Tags()
  
  -- 'tags'がnilでないか、'tags.place'が存在するかを確認
  if tags and tags.place then 
    if tags.place == 'city' or 
       tags.place == 'town' or 
       tags.place == 'village' or 
       tags.place == 'hamlet' or
       tags.place == 'state' or
       tags.place == 'country' then
      Layers.place:AddPoint(node)
    end
  end
end

-- 5. ウェイ（線）の処理
function way_function(way)
  -- ▼▼▼▼▼ 念のため追加 ▼▼▼▼▼
  if not way then
    return
  end
  -- ▲▲▲▲▲ 追加ここまで ▲▲▲▲▲

  local tags = way:Tags()
  
  if tags then
    if tags.natural == 'water' or 
       tags.waterway == 'riverbank' or 
       tags.natural == 'coastline' then
      Layers.water:AddPolygon(way)
    end
  end
end

-- 6. リレーション（関係）の処理
function relation_function(relation)
  -- ▼▼▼▼▼ 念のため追加 ▼▼▼▼▼
  if not relation then
    return
  end
  -- ▲▲▲▲▲ 追加ここまで ▲▲▲▲▲

  local tags = relation:Tags()
  
  if tags then
    if tags.type == 'multipolygon' then
      if tags.natural == 'water' or 
         tags.waterway == 'riverbank' or 
         tags.natural == 'coastline' then
        Layers.water:AddMultiPolygon(relation)
      end
    end
  end
end
