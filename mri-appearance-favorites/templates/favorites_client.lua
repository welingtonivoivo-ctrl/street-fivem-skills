-- NUI -> server. The ped model goes along so male and female favorites stay apart.

RegisterNUICallback('appearance_fav_get', function(_, cb)
    cb(lib.callback.await('mri_Qappearance:favorites:get', false, GetEntityModel(cache.ped)) or {})
end)

RegisterNUICallback('appearance_fav_toggle', function(data, cb)
    if type(data) ~= 'table' then return cb(false) end
    cb(lib.callback.await('mri_Qappearance:favorites:toggle', false, GetEntityModel(cache.ped), data.section, data.piece, data.on == true))
end)
