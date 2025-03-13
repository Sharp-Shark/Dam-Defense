if SERVER then return end
Timer.Wait(function ()
    if DD == nil then return end
    DD.wikiData.restorationDam = {related = {'main', 'dams'}}
    DD.localizations.english.wikiName_restorationDam = 'Restoration'
    DD.localizations.english.wikiText_restorationDam = 'The third Dam Defense map, made for large player counts. The dam was built upon an earlier Nexpharma holding, brought to ruin for some unknown reason. In a grand show of efficiency, the Dam is already in use and staffed while still under reconstruction! The basin is made of grand rocks with vast holes inbetween them allowing mostly open movement, and with an abandoned outpost below it.\n\nMap by Barry Ballast.'
    if not DD.tableHas(DD.wikiData.dams.related, 'restorationDam') then
        table.insert(DD.wikiData.dams.related, 'restorationDam')
    end
end, 100)