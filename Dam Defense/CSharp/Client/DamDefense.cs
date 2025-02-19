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