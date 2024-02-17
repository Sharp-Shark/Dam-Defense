-- Initial function provided by Evil Factory
-- Anything stupid you may find was added by me
DD.downloadAndApplyUpdate = function ()
	local id = DD.steamWorkshopId
	local path = DD.path

    Steam.GetWorkshopItem(UInt64(id), function (item)
        if item == nil then
            print(string.format("Couldn't find workshop item with id %s.", id))
            return
        end

        print(string.format("Downloading latest version of '%s'...", item.Title))

        Steam.DownloadWorkshopItem(item, path, function (downloadedItem)
            print(string.format("'%s' was successfully downloaded and placed in %s!", downloadedItem.Title, path))
			print('Reloading lua in 2 seconds to apply lua changes.')
			
			Timer.Wait(function ()
				if SERVER then
					Game.ExecuteCommand('reloadlua')
				elseif CLIENT then
					Game.ExecuteCommand('cl_reloadlua')
				end
			end, 1000 * 2)
        end)
    end)
end