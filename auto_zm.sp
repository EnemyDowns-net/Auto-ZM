#include <sourcemod>
#include <mapchooser>
#include <mapchooser_extended>

ArrayList maps;
ArrayList zmmaplist;
int serial = -1;

ConVar g_Cvar_LessPlayer;

int lessplayer;

public Plugin myinfo =
{
	name = "Auto Addding ZM Map",
	author = "Oylsister",
	description = "Auto nomination ZM map",
	version = "1.0",
	url = ""
}

public void OnPluginStart()
{
	g_Cvar_LessPlayer = CreateConVar("sm_autozm_lessplayer", "20", "Specific the player number that required to not auto-nominate zm map", _, true, 0.0, true, 63.0);

	HookConVarChange(g_Cvar_LessPlayer, OnConVarChange);
}

public OnConVarChange(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	lessplayer = g_Cvar_LessPlayer.IntValue;
}

public void OnMapStart()
{
	maps = new ArrayList(512, 0);
	zmmaplist = new ArrayList(512);

	ReadMapList(maps, serial);

	for(int i = 0; i < maps.Length; i++)
	{
		char mapname[PLATFORM_MAX_PATH];

		maps.GetString(i, mapname, PLATFORM_MAX_PATH);

		if(StrContains(mapname, "zm_", false) != -1)
		{
			zmmaplist.PushString(mapname);
		}
	}
}

public void OnMapEnd()
{
	delete maps;
	delete zmmaplist;
}

public void OnMapVoteWarningStart()
{
	if (ReadMapList(maps, serial) == null || serial == -1 || maps == INVALID_HANDLE)
		return;

	int totalclient = GetClientCount(true);
	lessplayer = g_Cvar_LessPlayer.IntValue;

	if(totalclient > lessplayer)
		return;

	PrintToChatAll(" \x04[Maps] \x01There are less than %d players in the server, Auto-Nomination has been activated.", lessplayer);

	int one = GetRandomInt(0, zmmaplist.Length - 1);
	int two = GetRandomInt(0, zmmaplist.Length - 1);

	if(one == two)
	{
		while(one == two)
		{
			two = GetRandomInt(0, zmmaplist.Length);
		}
	}

	char mapone[128];
	char maptwo[128];

	zmmaplist.GetString(one, mapone, 128);
	zmmaplist.GetString(two, maptwo, 128);

	NominateMap(mapone, true, 0);
	NominateMap(maptwo, true, 0);

	PrintToChatAll(" \x04[Maps] \x05\"%s\" \x01has been auto-added to nomination pool.", mapone);
	PrintToChatAll(" \x04[Maps] \x05\"%s\" \x01has been auto-added to nomination pool.", maptwo);
}