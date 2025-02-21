using System;
using System.Reflection;
using Barotrauma;
using Steamworks;
using HarmonyLib;

namespace DamDefense {
	public static class DamDefenseClass {
		
		public static string Path = System.Reflection.Assembly.GetEntryAssembly().Location.Replace(@"\", @"/");
		
		public static void OpenHTML (bool useSteamBrowser)
		{
			string url = "https://sharp-shark.github.io/Dam-Defense/main.html#main";
			
			FieldInfo fieldInfoInitialized = AccessTools.Field("Steamworks.SteamClient:initialized");
			bool canUseSteamBrowser = Convert.ToBoolean(fieldInfoInitialized.GetValue(fieldInfoInitialized));
			if (canUseSteamBrowser & useSteamBrowser)
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