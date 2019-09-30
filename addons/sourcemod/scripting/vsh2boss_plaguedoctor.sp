#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <vsh2>

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN

#define PlagueModel			"models/player/medic.mdl"
// #define PlagueModelPrefix		"models/player/medic"
#define ZombieModel			"models/player/scout.mdl"
// #define ZombieModelPrefix		"models/player/scout"


/// voicelines
#define PlagueIntro			"vo/medic_specialcompleted10.mp3"
#define PlagueRage1			"vo/medic_specialcompleted05.mp3"
#define PlagueRage2			"vo/medic_specialcompleted06.mp3"

methodmap CPlague < VSH2Player {
	public CPlague(const int ind, bool uid=false) {
		return view_as<CPlague>( VSH2Player(ind, uid) );
	}
	
	property float flCharge {
		public get() {
			return this.GetPropFloat("flCharge");
		}
		public set(const float val) {
			this.SetPropFloat("flCharge", val);
		}
	}
	property float flWeighDown {
		public get() {
			return this.GetPropFloat("flWeighDown");
		}
		public set(const float val) {
			this.SetPropFloat("flWeighDown", val);
		}
	}
	property float flRAGE {
		public get() {
			return this.GetPropFloat("flRAGE");
		}
		public set(const float val) {
			this.SetPropFloat("flRAGE", val);
		}
	}
	
	public void PlaySpawnClip() {
		this.PlayVoiceClip(PlagueIntro, VSH2_VOICE_INTRO);
	}
	
	public void Equip() {
		this.SetName("The Plague Doctor");
		this.RemoveAllItems();
		char attribs[128]; Format(attribs, sizeof(attribs), "68; 2.0; 2; 2.3; 259; 1.0; 252; 0.75; 200; 1.0; 551; 1.0");
		int SaxtonWeapon = this.SpawnWeapon("tf_weapon_shovel", 304, 100, 5, attribs);
		SetEntPropEnt(this.index, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
	public void RageAbility()
	{
		int attribute = 0;
		float value = 0.0; 
		TF2_AddCondition(this.index, TFCond_MegaHeal, 10.0);
		switch( GetRandomInt(0, 2) ) {
			case 0: { attribute = 2; value = 2.0; }	 /// Extra damage
			case 1: { attribute = 26; value = 100.0; }	/// Extra health
			case 2: { attribute = 107; value = 2.0; }	/// Extra speed
		}
		VSH2Player minion;
		for( int i=MaxClients; i; --i ) {
			if( !IsValidClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != VSH2Team_Boss )
				continue;
			minion = VSH2Player(i);
			bool IsMinion = minion.GetPropAny("bIsMinion");
			if( IsMinion ) {
			#if defined _tf2attributes_included
				bool tf2attribs_enabled = VSH2GameMode_GetPropAny("bTF2Attribs");
				if( tf2attribs_enabled ) {
					TF2Attrib_SetByDefIndex(i, attribute, value);
					SetPawnTimer(TF2AttribsRemove, 10.0, i);
				} else {
					char pdapower[32]; Format(pdapower, sizeof(pdapower), "%i; %f", attribute, value);
					int wep = minion.SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
					SetPawnTimer(RemoveWepFromSlot, 10.0, i, GetSlotFromWeapon(i, wep));
				}
			#else
				char pdapower[32]; Format(pdapower, sizeof(pdapower), "%i; %f", attribute, value);
				int wep = minion.SpawnWeapon("tf_weapon_builder", 28, 5, 10, pdapower);
				SetPawnTimer(RemoveWepFromSlot, 10.0, i, GetSlotFromWeapon(i, wep));
			#endif
			}
		}
		if( GetRandomInt(0, 2) )
			this.PlayVoiceClip(PlagueRage1, VSH2_VOICE_RAGE);
		else this.PlayVoiceClip(PlagueRage2, VSH2_VOICE_RAGE);
	}
	public void KilledPlayer(const VSH2Player victim, Event event) {
		/// GLITCH: suiciding allows boss to become own minion.
		if( this.userid == victim.userid )
			return;
		/// PATCH: Hitting spy with active deadringer turns them into Minion...
		else if( event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER )
			return;
		/// PATCH: killing spy with teammate disguise kills both spy and the teammate he disguised as...
		else if( TF2_IsPlayerInCondition(victim.index, TFCond_Disguised) )
			TF2_RemovePlayerDisguise(victim.index); //event.SetInt("userid", victim.userid);
		victim.SetPropInt("iOwnerBoss", this.userid);
		victim.ConvertToMinion(0.4);
	}
	public void Help() {
		if( IsVoteInProgress() )
			return;
		char helpstr[] = "Plague Doctor: Kill enemies and turn them into loyal Zombies!\nSuper Jump: crouch, look up and stand up.\nWeigh-down: in midair, look down and crouch\nRage (Powerup Minions): taunt when Rage is full to give powerups to your Zombies.";
		Panel panel = new Panel();
		panel.SetTitle(helpstr);
		panel.DrawItem("Exit");
		panel.Send(this.index, HintPanel, 10);
		delete panel;
	}
};

/// plague doctor conversion helper function.
public CPlague ToCPlague(const VSH2Player guy)
{
	return view_as<CPlague>(guy);
}


#if defined _tf2attributes_included
public void TF2AttribsRemove(const int iEntity)
{
	TF2Attrib_RemoveAll(iEntity);
}
#endif
public void RemoveWepFromSlot(const int client, const int wepslot)
{
	TF2_RemoveWeaponSlot(client, wepslot);
}


public Plugin myinfo = {
	name = "VSH2 Plague Doctor Subplugin",
	author = "Nergal/Assyrian",
	description = "",
	version = "1.0",
	url = "sus"
};

int g_iPlagueDocID;

ConVar
	g_vsh2_scout_rage_gen,
	g_vsh2_airblast_rage,
	g_vsh2_jarate_rage
;

public void OnAllPluginsLoaded()
{
	g_vsh2_scout_rage_gen = FindConVar("vsh2_scout_rage_gen");
	g_vsh2_airblast_rage = FindConVar("vsh2_airblast_rage");
	g_vsh2_jarate_rage = FindConVar("vsh2_jarate_rage");
	g_iPlagueDocID = VSH2_RegisterPlugin("plague_doctor");
	LoadVSH2Hooks();
}

public void LoadVSH2Hooks()
{
	if (!VSH2_HookEx(OnCallDownloads, PlagueDoc_OnCallDownloads))
		LogError("Error loading OnCallDownloads forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossMenu, PlagueDoc_OnBossMenu))
		LogError("Error loading OnBossMenu forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossSelected, PlagueDoc_OnBossSelected))
		LogError("Error loading OnBossSelected forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossThink, PlagueDoc_OnBossThink))
		LogError("Error loading OnBossThink forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossModelTimer, PlagueDoc_OnBossModelTimer))
		LogError("Error loading OnBossModelTimer forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossEquipped, PlagueDoc_OnBossEquipped))
		LogError("Error loading OnBossEquipped forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossInitialized, PlagueDoc_OnBossInitialized))
		LogError("Error loading OnBossInitialized forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnMinionInitialized, PlagueDoc_OnMinionInitialized))
		LogError("Error loading OnMinionInitialized forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossPlayIntro, PlagueDoc_OnBossPlayIntro))
		LogError("Error loading OnBossPlayIntro forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnPlayerKilled, PlagueDoc_OnPlayerKilled))
		LogError("Error loading OnPlayerKilled forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnPlayerHurt, PlagueDoc_OnPlayerHurt))
		LogError("Error loading OnPlayerHurt forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnPlayerAirblasted, PlagueDoc_OnPlayerAirblasted))
		LogError("Error loading OnPlayerAirblasted forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossMedicCall, PlagueDoc_OnBossMedicCall))
		LogError("Error loading OnBossMedicCall forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossTaunt, PlagueDoc_OnBossMedicCall))
		LogError("Error loading OnBossTaunt forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossJarated, PlagueDoc_OnBossJarated))
		LogError("Error loading OnBossJarated forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnMessageIntro, PlagueDoc_OnMessageIntro))
		LogError("Error loading OnMessageIntro forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnRoundEndInfo, PlagueDoc_OnRoundEndInfo))
		LogError("Error loading OnRoundEndInfo forwards for Plague Doctor subplugin.");
	
	if (!VSH2_HookEx(OnBossHealthCheck, PlagueDoc_OnBossHealthCheck))
		LogError("Error loading OnBossHealthCheck forwards for Plague Doctor subplugin.");
}
stock bool IsPlagueDoctor(const VSH2Player player) {
	return player.GetPropInt("iBossType") == g_iPlagueDocID;
}

public void PlagueDoc_OnCallDownloads()
{
	PrecacheModel(PlagueModel, true);
	PrecacheModel(ZombieModel, true);
	PrecacheSound(PlagueIntro, true);
	PrecacheSound(PlagueRage1, true);
	PrecacheSound(PlagueRage2, true);
}
public void PlagueDoc_OnBossMenu(Menu &menu)
{
	char tostr[10]; IntToString(g_iPlagueDocID, tostr, sizeof(tostr));
	menu.AddItem(tostr, "Plague Doctor (Subplugin Boss)");
}
public void PlagueDoc_OnBossSelected(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	ToCPlague(player).Help();
}
public void PlagueDoc_OnBossThink(const VSH2Player boss)
{
	int client = boss.index;
	if( !IsPlayerAlive(client) || !IsPlagueDoctor(boss) )
		return;
	
	CPlague player = ToCPlague(boss);
	int buttons = GetClientButtons(client);
	//float currtime = GetGameTime();
	int flags = GetEntityFlags(client);
	
	//int maxhp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	int health = player.GetPropInt("iHealth");
	int maxhealth = player.GetPropInt("iMaxHealth");
	float speed = 340.0 + 0.7 * (100-health*100/maxhealth);
	SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", speed);
	
	/// glowing code
	float glowtime = player.GetPropFloat("flGlowtime");
	if( player.GetPropFloat("flGlowtime") > 0.0 ) {
		player.SetPropInt("bGlow", 1);
		player.SetPropFloat("flGlowtime", glowtime - 0.1);
	}
	else if( glowtime <= 0.0 )
		player.SetPropInt("bGlow", 0);
	
	/// superjump code
	if( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (player.flCharge >= 0.0) ) {
		if( player.flCharge+2.5 < (25*1.0) )
			player.flCharge += 2.5;
		else player.flCharge = 25.0;
	} else if( player.flCharge < 0.0 )
		player.flCharge += 2.5;
	else {
		float EyeAngles[3]; GetClientEyeAngles(client, EyeAngles);
		if( player.flCharge > 1.0 && EyeAngles[0] < -5.0 ) {
			player.SuperJump(player.flCharge, -100.0);
			player.PlayVoiceClip("vo/medic_yes01.mp3", VSH2_VOICE_ABILITY);
		}
		else player.flCharge = 0.0;
	}
	
	if( OnlyScoutsLeft(VSH2Team_Red) )
		player.flRAGE += g_vsh2_scout_rage_gen.FloatValue;
	
	/// weighdown code
	if( flags & FL_ONGROUND )
		player.flWeighDown = 0.0;
	else player.flWeighDown += 0.1;
	if( (buttons & IN_DUCK) && player.flWeighDown >= 3.0 ) {
		float ang[3]; GetClientEyeAngles(client, ang);
		if( ang[0] > 60.0 ) {
			player.WeighDown(0.0);
		}
	}
	/// hud code
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	Handle hHudText = VSH2GameMode_GetHUDHandle();
	float jmp = player.flCharge;
	if( jmp > 0.0 )
		jmp *= 4.0;
	if( player.flRAGE >= 100.0 )
		ShowSyncHudText(client, hHudText, "Jump: %i | Rage: FULL - Call Medic (default: E) to activate", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp));
	else ShowSyncHudText(client, hHudText, "Jump: %i | Rage: %0.1f", player.GetPropInt("bSuperCharge") ? 1000 : RoundFloat(jmp), player.flRAGE);
}
public void PlagueDoc_OnBossModelTimer(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	int client = player.index;
	SetVariantString(PlagueModel);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
}
public void PlagueDoc_OnBossEquipped(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	ToCPlague(player).Equip();
}
public void PlagueDoc_OnBossInitialized(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	SetEntProp(player.index, Prop_Send, "m_iClass", view_as<int>(TFClass_Medic));
}
public void PlagueDoc_OnMinionInitialized(const VSH2Player player)
{
	VSH2Player ownerboss = VSH2Player(player.GetPropInt("iOwnerBoss"), true);
	if( !IsPlagueDoctor(ownerboss) )
		return;
	RecruitMinion(player);
}
public void PlagueDoc_OnBossPlayIntro(const VSH2Player player)
{
	if( !IsPlagueDoctor(player) )
		return;
	ToCPlague(player).PlaySpawnClip();
}

public void PlagueDoc_OnPlayerKilled(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	//int deathflags = event.GetInt("death_flags");
	/// attacker is plague doctor!
	if( attacker.GetPropInt("bIsBoss") && IsPlagueDoctor(attacker) ) {
		ToCPlague(attacker).KilledPlayer(victim, event);
	}
	/// attacker is a plague doctor minion!
	else if( attacker.GetPropInt("bIsMinion") ) {
		VSH2Player owner = VSH2Player(attacker.GetPropInt("iOwnerBoss"), true);
		if( IsPlagueDoctor(owner) )
			ToCPlague(owner).KilledPlayer(victim, event);
	}
	if( victim.GetPropInt("bIsMinion") ) {
		/// Cap respawning minions by the amount of minions there are. If 10 minions, then respawn him/her in 10 seconds.
		VSH2Player owner = VSH2Player(victim.GetPropInt("iOwnerBoss"), true);
		if( IsPlagueDoctor(owner) && IsPlayerAlive(owner.index) ) {
			int minions = VSH2GameMode_CountMinions(false);
			victim.ConvertToMinion(float(minions));
		}
	}
}
public void PlagueDoc_OnPlayerHurt(const VSH2Player attacker, const VSH2Player victim, Event event)
{
	int damage = event.GetInt("damageamount");
	if( !victim.GetPropInt("bIsBoss") && victim.GetPropInt("bIsMinion") && !attacker.GetPropInt("bIsMinion") ) {
		/** Have boss take damage if minions are hurt by players, this prevents bosses from hiding just because they gained minions
		 */
		VSH2Player ownerBoss = VSH2Player(victim.GetPropInt("iOwnerBoss"), true);
		if( IsPlagueDoctor(ownerBoss) ) {
			ownerBoss.SetPropInt("iHealth", ownerBoss.GetPropInt("iHealth")-damage);
			ownerBoss.GiveRage(damage);
		}
		return;
	}
	if( IsPlagueDoctor(victim) && victim.GetPropInt("bIsBoss") )
		victim.GiveRage(damage);
}
public void PlagueDoc_OnPlayerAirblasted(const VSH2Player airblaster, const VSH2Player airblasted, Event event)
{
	if( !IsPlagueDoctor(airblasted) )
		return;
	float rage = airblasted.GetPropFloat("flRAGE");
	airblasted.SetPropFloat("flRAGE", rage + g_vsh2_airblast_rage.FloatValue);
}
public void PlagueDoc_OnBossMedicCall(const VSH2Player rager)
{
	if( !IsPlagueDoctor(rager) )
		return;
	float rage = rager.GetPropFloat("flRAGE");
	if( rage < 100.0 )
		return;
	
	ToCPlague(rager).RageAbility();
	rager.SetPropFloat("flRAGE", 0.0);
}
public void PlagueDoc_OnBossJarated(const VSH2Player victim, const VSH2Player thrower)
{
	if( !IsPlagueDoctor(victim) )
		return;
	float rage = victim.GetPropFloat("flRAGE");
	victim.SetPropFloat("flRAGE", rage - g_vsh2_jarate_rage.FloatValue);
}
public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	VSH2Player player = VSH2Player(client);
	if( player.GetPropInt("bIsMinion") ) {
		VSH2Player ownerBoss = VSH2Player(player.GetPropInt("iOwnerBoss"), true);
		if( IsPlagueDoctor(ownerBoss) )
			player.ClimbWall(weapon, 400.0, 0.0, false);
		
		result = false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public void PlagueDoc_OnMessageIntro(const VSH2Player player, char message[512])
{
	if( !IsPlagueDoctor(player) )
		return;
	
	char name[MAX_BOSS_NAME_SIZE]; player.GetName(name);
	int health = player.GetPropInt("iHealth");
	Format(message, 512, "%s\n%N has become %s with %i Health", message, player.index, name, health);
}
public void PlagueDoc_OnRoundEndInfo(const VSH2Player player, bool bossBool, char message[512])
{
	if( !IsPlagueDoctor(player) )
		return;
	int health = player.GetPropInt("iHealth");
	int maxhealth = player.GetPropInt("iMaxHealth");
	char name[MAX_BOSS_NAME_SIZE]; player.GetName(name);
	
	Format(message, 512, "%s\n%s (%N) had %i (of %i) health left.", message, name, player.index, health, maxhealth);
	if( bossBool ) {
		/// play Boss Wins sounds here!
	}
}
public void PlagueDoc_OnBossHealthCheck(const VSH2Player player, bool bossBool, char message[512])
{
	if( !IsPlagueDoctor(player) )
		return;
	int health = player.GetPropInt("iHealth");
	int maxhealth = player.GetPropInt("iMaxHealth");
	char name[MAX_BOSS_NAME_SIZE]; player.GetName(name);
	if( bossBool )
		PrintCenterTextAll("%s showed his current HP: %i of %i", name, health, maxhealth);
	else Format(message, 512, "%s\n%s's current health is: %i of %i", message, name, health, maxhealth);
}



void RecruitMinion(const VSH2Player base)
{
	int client = base.index;
	TF2_SetPlayerClass(client, TFClass_Scout, _, false);
	base.RemoveAllItems();
#if defined _tf2attributes_included
	if( VSH2GameMode_GetPropInt("bTF2Attribs") )
		TF2Attrib_RemoveAll(client);
#endif
	int weapon = base.SpawnWeapon("tf_weapon_bat", 572, 100, 5, "6; 0.5; 57; 15.0; 26; 75.0; 49; 1.0; 68; -2.0");
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	TF2_AddCondition(client, TFCond_Ubercharged, 3.0);
	SetEntityHealth(client, 200);
	SetVariantString(ZombieModel);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	SetEntProp(client, Prop_Send, "m_nBody", 0);
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 30, 160, 255, 255);
}


stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
		return false; 
	return IsClientInGame(client); 
}
stock int GetSlotFromWeapon(const int iClient, const int iWeapon)
{
	for (int i=0; i<5; i++) {
		if( iWeapon == GetPlayerWeaponSlot(iClient, i) )
			return i;
	}
	return -1;
}
stock bool OnlyScoutsLeft(const int team)
{
	for (int i=MaxClients; i; --i) {
		if( !IsValidClient(i) || !IsPlayerAlive(i) )
			continue;
		if (GetClientTeam(i) == team && TF2_GetPlayerClass(i) != TFClass_Scout)
			return false;
	}
	return true;
}

stock void SetPawnTimer(Function func, float thinktime = 0.1, any param1 = -999, any param2 = -999)
{
	DataPack thinkpack = new DataPack();
	thinkpack.WriteFunction(func);
	thinkpack.WriteCell(param1);
	thinkpack.WriteCell(param2);
	CreateTimer(thinktime, DoThink, thinkpack, TIMER_DATA_HNDL_CLOSE);
}

public Action DoThink(Handle hTimer, DataPack hndl)
{
	hndl.Reset();
	
	Function pFunc = hndl.ReadFunction();
	Call_StartFunction( null, pFunc );
	
	any param1 = hndl.ReadCell();
	if( param1 != -999 )
		Call_PushCell(param1);
	
	any param2 = hndl.ReadCell();
	if( param2 != -999 )
		Call_PushCell(param2);
	
	Call_Finish();
	return Plugin_Continue;
}



public int HintPanel(Menu menu, MenuAction action, int param1, int param2)
{
	return;
}
