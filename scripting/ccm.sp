#include <sdktools>
#include <sourcemod>
#include <sdkhooks>
//#undef REQUIRE_PLUGIN
//#tryinclude <updater>

#define GAME_TF2
#include <thelpers>

#pragma semicolon		1
#pragma newdecls		required

#define PLUGIN_VERSION		"1.0"
public Plugin myinfo = 
{
	name 			= "Custom Structures",
	author 			= "nergal/assyrian",
	description 		= "Allows Players to take their resupply lockers with them anywhere!",
	version 		= PLUGIN_VERSION,
	url 			= "hue"
}

//defines
#define IsValidClient(%1)	( 0 < %1.Index && %1.Index <= MaxClients && %1.IsInGame )
#define PLYR			MAXPLAYERS+1
#define nullvec			NULL_VECTOR

//cvar handles
ConVar bEnabled = null;
ConVar AllowBlu = null;
ConVar AllowRed = null;

//float flTimer[MAXPLAYERS+1];

enum //Structures
{
	Bridge = 0,
	Sandbags,
	Bunker,
	SentryNest,
	MedStation,
	AmmoStation
}
/*
methodmap CBaseStructure < CBaseAnimating
{
	public CBaseStructure( int entIndex )
	{
		return view_as<CBaseStructure>( new CBaseAnimating( entIndex ) );
	}
};
*/

CBaseAnimating Structures[PLYR][6];

public void OnPluginStart()
{
	bEnabled = CreateConVar("sm_structures_enabled", "1", "Enable Structures plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	AllowBlu = CreateConVar("sm_structures_blu", "1", "(Dis)Allow Structures for BLU team", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AllowRed = CreateConVar("sm_structures_red", "1", "(Dis)Allow Structures for RED team", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);

	//AddCommandListener(Listener_Voice, "voicemenu");
	//RegAdminCmd("sm_portableresupply", CreatePortableResupply, ADMFLAG_KICK);
	RegConsoleCmd("sm_bstructs", CommandBuildings);
	RegConsoleCmd("sm_structs", CommandBuildings);
	RegConsoleCmd("sm_structures", CommandBuildings);
	RegConsoleCmd("sm_structure", CommandBuildings);

	CTFPlayer player;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( (player = new CTFPlayer(i)) == null ) continue;
		if ( !IsValidClient(player) ) continue;
		OnClientPutInServer(i);
	}
}
public void OnClientPutInServer(int client)
{
	for (int i = 0; i < 6; i++)
	{
		Structures[client][i] = null;
	}
}
public void OnClientDisconnect(int client)
{
	for (int i = 0; i < 6; i++)
	{
		if ( Structures[client][i] != null && Structures[client][i].IsValid )
		{
			CreateTimer( 0.1, RemoveEnt, Structures[client][i].Ref );
			Structures[client][i] = null;
		}
	}
}
public void OnMapStart()
{
	char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	char extensionsb[][] = { ".vtf", ".vmt" };
	char s[PLATFORM_MAX_PATH];
	int i;
	for (i = 0; i < sizeof(extensions); i++)
	{
		Format(s, PLATFORM_MAX_PATH, "models/mrmof/sandbags01%s", extensions[i]);
		Format(s, PLATFORM_MAX_PATH, "models/bunker/shelter%s", extensions[i]);
		CheckDownload(s);
	}
	for (i = 0; i < sizeof(extensionsb); i++)
	{
		Format(s, PLATFORM_MAX_PATH, "materials/models/mrmof/sandbags01%s", extensionsb[i]);
		CheckDownload(s);
		Format(s, PLATFORM_MAX_PATH, "materials/models/mrmof/sandbags01_normal%s", extensionsb[i]);
		CheckDownload(s);
	}
}
stock CBaseAnimating CreateStructure(CTFPlayer pPlayer, char[] szModel, float flOrigin[3], float flAngles[3] = NULL_VECTOR)
{
	CBaseAnimating pNewStruct = view_as<CBaseAnimating>( CBaseEntity.CreateByName("prop_dynamic_override") );
	if ( pNewStruct != null && pNewStruct.IsValid )
	{
		PrecacheModel(szModel, true);
		//pNewStruct.OwnerEntity = pPlayer;
		pNewStruct.SolidType = SOLID_VPHYSICS;
		pNewStruct.SetModel(szModel);
		int iTeam = view_as<int>( pPlayer.Team );
		pNewStruct.Team = iTeam;
		//pNewStruct.Health = 500;
		pNewStruct.Spawn();

		pNewStruct.SetProp(Prop_Data, "m_takedamage", 2);
		pNewStruct.SetProp(Prop_Data, "m_iHealth", 500);
		//DispatchKeyValue(resupplier, "targetname", "portable_resupply");
		//CreateTimer(0.1, MyDearWatson, pResupply.Ref, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		pNewStruct.Teleport(flOrigin, flAngles, NULL_VECTOR);
		return pNewStruct;
	}
	return null;
}
public Action CommandBuildings(int client, int args)
{
	if (!bEnabled.BoolValue) return Plugin_Handled;

	CTFPlayer pCreator = new CTFPlayer(client);
	if ( !pCreator ) return Plugin_Handled;
	if ( !pCreator.IsAlive ) { PrintToChat(pCreator.Index, "You need to be alive to build"); return Plugin_Handled; }

	int team = view_as<int>(pCreator.Team);
	if ( (!AllowBlu.BoolValue && (team == 3)) || (!AllowRed.BoolValue && (team == 2)) )
		return Plugin_Handled;

	Menu pStructs = new Menu(MenuHandlerStructures);
	pStructs.SetTitle("[Structs] Main Menu");
	pStructs.AddItem("tier1", "Build Defensive Structure");
	//pStructs.AddItem("tier2", "Build Base Structure");
	//pStructs.AddItem("tier3", "Rotate a Structure");
	pStructs.AddItem("tier4", "Destroy a Structure");
	pStructs.AddItem("tier4", "Destroy All Built Structures");
	pStructs.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public int MenuHandlerStructures(Menu menu, MenuAction action, int client, int selection)
{
	char info[32];
	menu.GetItem( selection, info, sizeof(info) );
	if (action == MenuAction_Select)
        {
		switch (selection)
		{
			case 0: DefensiveMenu(client);
			case 1: DestroyMenu(client);
			case 2:
			{
				for (int i = 0; i < 6; i++)
				{
					if ( Structures[client][i] != null && Structures[client][i].IsValid )
					{
						CreateTimer( 0.1, RemoveEnt, Structures[client][i].Ref );
						Structures[client][i] = null;
					}
				}
				CommandBuildings(client, -1);
			}
		}
        }
	else if (action == MenuAction_End) delete menu;	
}
public void DestroyMenu(int client)
{
	Menu pStructs = new Menu(MenuHandlerDestroyStructures);
	pStructs.SetTitle("[Structs] Destroy a Structure");
	pStructs.AddItem("tier1", "Small Bridge");
	pStructs.AddItem("tier1", "Sandbag Wall");
	pStructs.Display(client, MENU_TIME_FOREVER);
}
public int MenuHandlerDestroyStructures(Menu menu, MenuAction action, int client, int selection)
{
	char info[32];
	menu.GetItem(selection, info, sizeof(info));
	if (action == MenuAction_Select)
        {
		if ( Structures[client][selection] != null && Structures[client][selection].IsValid )
		{
			CreateTimer( 0.1, RemoveEnt, Structures[client][selection].Ref );
			Structures[client][selection] = null;
		}
		else Structures[client][selection] = null;
		CommandBuildings(client, -1);
        }
	else if (action == MenuAction_End) delete menu;	
}
public void DefensiveMenu(int client)
{
	Menu pStructs = new Menu(MenuHandlerDefensiveStructures);
	pStructs.SetTitle("[Structs] Defensive Structures");
	pStructs.AddItem("tier1", "Small Bridge");
	pStructs.AddItem("tier1", "Sandbag Wall");
	pStructs.Display(client, MENU_TIME_FOREVER);
}
public int MenuHandlerDefensiveStructures(Menu menu, MenuAction action, int client, int selection)
{
	char info[32];
	menu.GetItem(selection, info, sizeof(info));
	if (action == MenuAction_Select)
        {
		GetBuilding(client, selection);
		CommandBuildings(client, -1);
        }
	else if (action == MenuAction_End) delete menu;	
}
public void GetBuilding(int client, int type)
{
	CTFPlayer pCreator = new CTFPlayer(client);
	if ( pCreator != null && pCreator.IsAlive )
	{
		float flEyePos[3], flAng[3];
		pCreator.GetEyePosition(flEyePos);
		pCreator.GetEyeAngles(flAng);
		int iClient = pCreator.Index;

		TR_TraceRayFilter(flEyePos, flAng, MASK_PLAYERSOLID_BRUSHONLY, RayType_Infinite, TraceFilterIgnorePlayers, iClient);
		//float StructAng[3]; TR_GetPlaneNormal(StructAng);
		if ( TR_GetFraction() < 1.0 )
		{
			float flEndPos[3]; TR_GetEndPosition(flEndPos);
			float mins[3], maxs[3];

			switch (type)
			{
				case Bridge:
				{
					flEndPos[2] += 10.0;
					mins[0] = -48.25, mins[1] = -220.0, mins[2] = -21.0;
					maxs[0] = 52.02, maxs[1] = 252.0, maxs[2] = 8.0;
					//mins[0] = 0.0, mins[1] = 0.0, mins[2] = 0.0;
					//maxs[0] = 100.27, maxs[1] = 472.0, maxs[2] = 29.0;
				}
				case Sandbags:
				{
					flEndPos[2] += 2.0;
					//mins[0] = 0.0, mins[1] = 0.0, mins[2] = 0.0;
					//maxs[0] = 100.27, maxs[1] = 472.0, maxs[2] = 29.0;
					mins[0] = 0.0, mins[1] = 0.0, mins[2] = 0.0;
					maxs[0] = 192.1, maxs[1] = 29.0, maxs[2] = 50.0;
				}
			}
			if ( CanBuildHere(flEndPos, mins, maxs) )
			{
				CBaseAnimating pStruct;
				pCreator.GetAbsAngles(flAng);
				switch (type)
				{
					case Bridge:
					{
						flAng[1] += 90.0;
						pStruct = CreateStructure(pCreator, "models/props_forest/sawmill_bridge.mdl", flEndPos, flAng);
					}
					case Sandbags:
					{
						flAng[1] += 90.0;
						pStruct = CreateStructure(pCreator, "models/mrmof/sandbags01.mdl", flEndPos, flAng);
					}
				}
				if ( pStruct != null && pStruct.IsValid )
				{
					if (Structures[iClient][type] != null)
					{
						CreateTimer( 0.1, RemoveEnt, Structures[client][type].Ref );
						Structures[iClient][type] = null;
					}
					Structures[iClient][type] = pStruct;
					PrintStructureSize(pCreator, pStruct);
				}
			}
			else PrintToChat(iClient, "Can't build structure there");
		}
	}
	return;
}

//stocks
stock void PrintStructureSize(CTFPlayer pOwner, CBaseEntity pEnt)
{
	if ( !pEnt || !pEnt.IsValid ) return;
	else if ( !pOwner || !pOwner.IsValid ) return;

	float mins[3], maxs[3];

	pEnt.GetPropVector(Prop_Send, "m_vecMins", mins );
	pEnt.GetPropVector(Prop_Send, "m_vecMaxs", maxs );
	PrintToConsole(pOwner.Index, "Bridge Vec Mins %f x, %f y, %f z", mins[0], mins[1], mins[2]);
	PrintToConsole(pOwner.Index, "Bridge Vec Maxs %f x, %f y, %f z", maxs[0], maxs[1], maxs[2]);
}
stock bool IsInRange( CBaseEntity pEnt, CBaseEntity pTarget, float dist, bool bTrace )
{
	float entitypos[3]; pEnt.GetAbsOrigin( entitypos );
	float targetpos[3]; pTarget.GetAbsOrigin( targetpos );

	if ( GetVectorDistance(entitypos, targetpos) <= dist )
	{
		if (!bTrace) return true;
		else {
			TR_TraceRayFilter( entitypos, targetpos, MASK_SHOT, RayType_EndPoint, TraceRayDontHitSelf, pEnt.Index );
			if ( TR_GetFraction() > 0.98 ) return true;
			//I have no fucking clue how but above code works more accurately than the commented...
			//if ( TR_DidHit() && TR_GetEntityIndex() == target ) return true;
		}
	}
	return false;
}
public bool TraceRayDontHitSelf(int entity, int contentsMask, any data)
{
	return ( entity != data );
}
stock bool CanBuildHere(float flPos[3], float flMins[3], float flMaxs[3])
{
	TR_TraceHull(flPos, flPos, flMins, flMaxs, MASK_PLAYERSOLID);

	int beamcolor[4];
	beamcolor[0] = 0, beamcolor[1] = 255, beamcolor[2] = 90, beamcolor[3] = 255;
	int lasermodel = PrecacheModel("sprites/laser.vmt", true);

	float vecMins[3]; vecMins = flPos; SubtractVectors(vecMins, flMins, vecMins);
	TE_SetupBeamPoints( flPos, vecMins, lasermodel, lasermodel, 1, 1, 5.0, 8.0, 8.0, 5, 2.0, beamcolor, 0 );
	TE_SendToAll();

	float vecMaxs[3]; vecMaxs = flPos; AddVectors(vecMaxs, flMins, vecMaxs);
	TE_SetupBeamPoints( flPos, vecMaxs, lasermodel, lasermodel, 1, 1, 5.0, 8.0, 8.0, 5, 2.0, beamcolor, 0 );
	TE_SendToAll();

	return ( TR_GetFraction() > 0.98 );
}
public bool TraceFilterIgnorePlayers(int entity, int contentsMask, any client)
{
	return ( !(entity > 0 && entity <= MaxClients) );
}
public Action RemoveEnt(Handle timer, any entid)
{
	CBaseEntity pEnt = new CBaseEntity( EntRefToEntIndex(entid) );
	if ( pEnt != null && pEnt.IsValid ) pEnt.AcceptInput("Kill");
	return Plugin_Continue;
}
stock void CheckDownload(char[] dlpath)
{
	if ( FileExists(dlpath) ) AddFileToDownloadsTable(dlpath);
}
stock float Vector2DLength( const float vec[2] )
{
	return SquareRoot(vec[0]*vec[0] + vec[1]*vec[1]);		
}
stock float fMax(float a, float b) { return (a > b) ? a : b; }
stock float fMin(float a, float b) { return (a < b) ? a : b; }












/*
							Legacy testing code
*/

/*public Action MyDearWatson(Handle timer, any entid)
{
	CBaseAnimating pEnt = new CBaseAnimating( EntRefToEntIndex(entid) );
	if ( !pEnt || !pEnt.IsValid ) return Plugin_Stop;

	CTFPlayer player;
	for (int i = 1; i <= MaxClients; ++i)
	{
		if ( (player = new CTFPlayer(i)) == null ) continue;
		if ( !IsValidClient(player) ) continue;

		if ( (!AllowBlu.BoolValue && player.Team == TFTeam_Blue) || (!AllowRed.BoolValue && player.Team == TFTeam_Red) )
			continue;

		if ( IsInRange(player, pEnt, 100.0, false) && flTimer[player.Index] <= GetGameTime() )
		{
			SetVariantString("open");
			pEnt.AcceptInput("SetAnimation");
			ResupplyPlayer(player.UserID);
		}
		else
		{
			SetVariantString("close");
			pEnt.AcceptInput("SetAnimation");
		}
	}
	return Plugin_Continue;
}
public void ResupplyPlayer(int userid)
{
	CTFPlayer pUser = view_as<CTFPlayer>( Player_FromUserId(userid) );
	if ( IsValidClient(pUser) && pUser.IsAlive )
	{
		float cooldown = Cooldown.FloatValue;

		if (!ArenaMode.BoolValue) pUser.Regenerate();
		else
		{
			pUser.Health = pUser.GetProp(Prop_Data, "m_iMaxHealth");
		}

		EmitSoundToClient(pUser.Index, "items/regenerate.wav");
		if (bAllOrNone.BoolValue)
		{
			CTFPlayer player;
			for (int i = 1; i <= MaxClients; i++)
			{
				if ( (player = new CTFPlayer(i)) == null ) continue;
				if ( !IsValidClient(player) ) continue;

				if (player.Team == pUser.Team) {
					flTimer[player.Index] = GetGameTime()+cooldown;
				}
			}
		}
		else flTimer[pUser.Index] = GetGameTime()+cooldown;
	}
	return;
}

public Action CreatePortableResupply(int client, int args)
{
	if (bEnabled.BoolValue)
	{
		CTFPlayer pCreator = new CTFPlayer(client);
		if ( !pCreator || !pCreator.IsAlive ) return Plugin_Continue;

		int team = view_as<int>(pCreator.Team);
		if ( (!AllowBlu.BoolValue && (team == 3)) || (!AllowRed.BoolValue && (team == 2)) )
			return Plugin_Continue;

		if (iResuppliesBuilt[team-2] <= 0)
		{
			float flPos[3], flAng[3];
			pCreator.GetEyePosition(flPos);
			pCreator.GetEyeAngles(flAng);

			TR_TraceRayFilter(flPos, flAng, MASK_SHOT, RayType_Infinite, TraceFilterIgnorePlayers, pCreator.Index);
			if ( TR_DidHit() )
			{
				float flEndPos[3]; TR_GetEndPosition(flEndPos);
				flEndPos[2] += 5.0;

				float mins[3] = {-24.0, -24.0, 0.0};
				float maxs[3] = {24.0, 24.0, 55.0};

				if ( CanBuildHere(flEndPos, mins, maxs) )
				{
					pCreator.GetAbsAngles(flAng);
					CBaseAnimating pResupply = CreateResupply(pCreator, flEndPos, flAng);

					switch (pCreator.Team)
					{
						case TFTeam_Red: pRedSupply = pResupply;
						case TFTeam_Blue: pBluSupply = pResupply;
					}
					//CreateTimer(0.1, MyDearWatson, pResupply.Ref, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					PrintToConsole(pCreator.Index, "built resupply");
				}
				else PrintToChat(pCreator.Index, "Can't build Resupply there");
			}
		}
		else
		{
			CBaseAnimating pEnt = null;
			switch (pCreator.Team)
			{
				case TFTeam_Red:	pEnt = pRedSupply;
				case TFTeam_Blue:	pEnt = pBluSupply;
			}
			PrintToConsole(pCreator.Index, "got ent");

			if ( pEnt != null && pEnt.IsValid ) CreateTimer( 0.1, RemoveEnt, pEnt.Ref );
			else PrintToConsole(pCreator.Index, "entity wasn't valid, resetting");

			iResuppliesBuilt[team-2]--;
			CreatePortableResupply(pCreator.Index, -1);
		}
	}
	return Plugin_Handled;
}*/