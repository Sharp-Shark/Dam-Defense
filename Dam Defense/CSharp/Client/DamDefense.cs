using System;
using System.Reflection;
using Barotrauma;
using Steamworks;

namespace DamDefense {
	public static class DamDefenseClass {
		
		public static string Path = System.Reflection.Assembly.GetEntryAssembly().Location.Replace(@"\", @"/");
		
		public static void OpenHTML (bool useSteamBrowser)
		{
			string url = "";
			string build = "";
			for (int i = 0; i < Path.Length; i++)
			{
				build = build + Path[i];
				if (Path[i] == '/')
				{
					url = url + build;
					build = "";
				}
			}
			url = url + "LocalMods/DamDefense.html";
			
			if (useSteamBrowser)
			{
				Steamworks.SteamFriends.OpenWebOverlay(url);
			}
			else
			{
				GameMain.ShowOpenUriPrompt(url);
			}
		}
	}
}