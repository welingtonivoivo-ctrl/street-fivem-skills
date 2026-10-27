-- Favorite clothes: per character (citizenid) and ped model, in the server KVP.
-- Shape: { [section] = { [pieceKey] = true } }. section = side tab id (masks, jackets...),
-- pieceKey = "<collection>:<localDrawable>" (or the global number for the base game).

local LIMIT_PER_SECTION = 300

local function kvpKey(source, model)
    local player = exports.qbx_core:GetPlayer(source)
    local cid = player and player.PlayerData and player.PlayerData.citizenid
    if not cid or type(model) ~= 'number' then return end
    return ('fav:%s:%d'):format(cid, model)
end

local function read(key)
    local ok, data = pcall(json.decode, GetResourceKvpString(key) or '{}')
    return ok and type(data) == 'table' and data or {}
end

lib.callback.register('mri_Qappearance:favorites:get', function(source, model)
    local key = kvpKey(source, model)
    return key and read(key) or {}
end)

lib.callback.register('mri_Qappearance:favorites:toggle', function(source, model, section, piece, on)
    local key = kvpKey(source, model)
    -- Everything below comes from the NUI: short plain text only.
    if not key or type(section) ~= 'string' or #section > 32 or not section:match('^[%w_]+$') then return false end
    piece = tostring(piece)
    if #piece > 80 or not piece:match('^[%w_]*:?%-?%d+$') then return false end

    local data = read(key)
    data[section] = data[section] or {}
    if on == true then
        local count = 0
        for _ in pairs(data[section]) do count = count + 1 end
        if count >= LIMIT_PER_SECTION then return false end
        data[section][piece] = true
    else
        data[section][piece] = nil
        if next(data[section]) == nil then data[section] = nil end
    end
    SetResourceKvp(key, json.encode(data))
    return true
end)
