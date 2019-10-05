#include <sourcemod>
#include <morecolors>
#include <vsh2>

#pragma semicolon		1
#pragma newdecls		required

methodmap VSH2Derived < VSH2Player
{
	public VSH2Derived (const int x, bool userid=false)
	{
		return view_as< VSH2Derived >( VSH2Player(x, userid) );
	}
	
	property int iNewProperty {
		public get() {
			return this.GetPropInt("iNewProperty");
		}
		public set(const int i) {
			this.SetPropInt("iNewProperty", i);
		}
	}
};

public Plugin myinfo = {
	name = "vsh2_natives_tester",
	author = "Assyrian/Nergal",
	description = "plugin for testing vsh2 natives and forwards",
	version = "1.0",
	url = "http://www.sourcemod.net/"
};

/** YOU NEED TO USE OnAllPluginsLoaded() TO REGISTER PLUGINS BECAUSE WE NEED TO MAKE SURE THE VSH2 PLUGIN LOADS FIRST */
//int ThisPluginIndex;
public void OnAllPluginsLoaded()
{
	//VSH2_RegisterPlugin("test_plugin_boss");
	RegConsoleCmd("sm_testvsh2natives", CommandInfo, "clever command explanation heer.");
	LoadVSH2Hooks();
}

public Action CommandInfo(int client, int args)
{	PrintToConsole(client, "calling natives command");
	VSH2Player player = VSH2Player(client);
	if (player) {
		PrintToConsole(client, "VSH2Player methodmap Constructor is working");
		PrintToConsole(client, "player.index = %d | player.userid = %d", player.index, player.userid);
		int damage = player.GetPropInt("iDamage");
		PrintToConsole(client, "players damage is %d", damage);
		
		player.SetPropInt("iState", 999);
		int boss_status = player.GetPropInt("iState");
		PrintToConsole(client, "players state is %d", boss_status);
		VSH2Derived deriver = VSH2Derived(client);
		PrintToConsole(client, "made derived");
		deriver.iNewProperty = 643;
		PrintToConsole(client, "made new property and initialized it to %d", deriver.iNewProperty);
		deriver.SetPropInt("iState", 3245);
		boss_status = deriver.GetPropInt("iState");
		PrintToConsole(client, "testing inheritance and boss status is %d", boss_status);
	}
	return Plugin_Handled;
}

public void fwdOnDownloadsCalled()
{
	for (int i=0; i < 5; ++i)
		PrintToServer("Forward OnDownloadsCalled called");
}
public Action fwdBossSelected(const VSH2Player base)
{
	for (int i=MaxClients; i; --i)
		if( IsClientInGame(i) )
			PrintToConsole(i, "fwdBossSelected:: ==> %N @ index: %i", base.index, base.index);
}

public void fwdOnTouchPlayer(const VSH2Player victim, const VSH2Player attacker)
{
	PrintToConsole(attacker.index, "fwdOnTouchPlayer:: ==> attacker name: %N | victim name: %N", attacker.index, victim.index);
	PrintToConsole(victim.index, "fwdOnTouchPlayer:: ==> attacker name: %N | victim name: %N", attacker.index, victim.index);
}

public void fwdOnTouchBuilding(const VSH2Player attacker, const int building)
{
	PrintToConsole(attacker.index, "fwdOnTouchBuilding:: ==> attacker name: %N | Building Reference %i", attacker.index, building);
}

public Action fwdOnBossThink(const VSH2Player player)
{
	player.SetPropInt("iHealth", player.GetPropInt("iHealth") + 1);
}
public Action fwdOnBossModelTimer(const VSH2Player player)
{
	player.SetPropFloat("flRAGE", player.GetPropFloat("flRAGE") + 1.0);
}

public void fwdOnBossDeath(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossDeath:: %N", player.index);
}

public void fwdOnBossEquipped(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossEquipped:: %N", player.index);
}
public void fwdOnBossInitialized(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossInitialized:: %N", player.index);
}
public void fwdOnMinionInitialized(const VSH2Player player, const VSH2Player master)
{
	PrintToConsole(player.index, "fwdOnMinionInitialized:: %N, owner boss: %N", player.index, master.index);
}
public void fwdOnBossPlayIntro(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossPlayIntro:: %N", player.index);
}

public Action fwdOnBossTakeDamage(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossTakeDamage_OnStabbed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnStabbed:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnStabbed:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnTelefragged(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnTelefragged:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnTelefragged:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnSwordTaunt(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnSwordTaunt:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnSwordTaunt:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHeavyShotgun(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHeavyShotgun:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHeavyShotgun:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnSniped(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnSniped:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnSniped:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnThirdDegreed(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnThirdDegreed:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnThirdDegreed:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHitSword(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHitSword:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHitSword:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHitFanOWar(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHitFanOWar:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHitFanOWar:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHitCandyCane(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHitCandyCane:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHitCandyCane:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnMarketGardened(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnMarketGardened:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnMarketGardened:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnPowerJack(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnPowerJack:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnPowerJack:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnKatana(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnKatana:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnKatana:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnAmbassadorHeadshot(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnAmbassadorHeadshot:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnAmbassadorHeadshot:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnDiamondbackManmelterCrit(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnDiamondbackManmelterCrit:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnDiamondbackManmelterCrit:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}
public Action fwdOnBossTakeDamage_OnHolidayPunch(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossTakeDamage_OnHolidayPunch:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossTakeDamage_OnHolidayPunch:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}


public Action fwdOnBossDealDamage(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnStomp(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnStomp:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnStomp:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitDefBuff(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitDefBuff:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitDefBuff:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitCritMmmph(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitCritMmmph:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitCritMmmph:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitMedic(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitMedic:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitMedic:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitDeadRinger(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitDeadRinger:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitDeadRinger:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitCloakedSpy(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitCloakedSpy:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitCloakedSpy:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossDealDamage_OnHitShield(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossDealDamage_OnHitShield:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossDealDamage_OnHitShield:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public void fwdOnPlayerKilled(const VSH2Player player, const VSH2Player victim, Event event)
{
	PrintToConsole(player.index, "fwdOnPlayerKilled:: ==> attacker name: %N | victim name: %N", player.index, victim.index);
	PrintToConsole(victim.index, "fwdOnPlayerKilled:: ==> attacker name: %N | victim name: %N", player.index, victim.index);
}

public void fwdOnPlayerAirblasted(const VSH2Player player, const VSH2Player victim, Event event)
{
	PrintToConsole(player.index, "fwdOnPlayerAirblasted:: ==> attacker name: %N | victim name: %N", player.index, victim.index);
	PrintToConsole(victim.index, "fwdOnPlayerAirblasted:: ==> attacker name: %N | victim name: %N", player.index, victim.index);
}

public void fwdOnTraceAttack(const VSH2Player player, const VSH2Player attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
	PrintToConsole(player.index, "fwdOnTraceAttack:: ==> attacker name: %N | victim name: %N", attacker.index, player.index);
	PrintToConsole(attacker.index, "fwdOnTraceAttack:: ==> attacker name: %N | victim name: %N", attacker.index, player.index);
}

public void fwdOnBossMedicCall(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossMedicCall:: %N", player.index);
}

public void fwdOnBossTaunt(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnBossTaunt:: %N", player.index);
}

public void fwdOnBossKillBuilding(const VSH2Player attacker, const int building, Event event)
{
	PrintToConsole(attacker.index, "fwdOnBossKillBuilding:: %N | build -> %i", attacker.index, building);
}

public void fwdOnBossJarated(const VSH2Player victim, const VSH2Player attacker)
{
	PrintToConsole(attacker.index, "fwdOnBossJarated:: ==> attacker name: %N | victim name: %N", attacker.index, victim.index);
	PrintToConsole(victim.index, "fwdOnBossJarated:: ==> attacker name: %N | victim name: %N", attacker.index, victim.index);
}

public void fwdOnMessageIntro(const VSH2Player boss, char message[512])
{
	PrintToConsole(boss.index, "fwdOnMessageIntro:: %N", boss.index);
}

public void fwdOnBossPickUpItem(const VSH2Player player, const char item[64])
{
	PrintToConsole(player.index, "fwdOnBossPickUpItem:: %N ==> item is %s", player.index, item);
}

public void fwdOnVariablesReset(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnVariablesReset:: %N", player.index);
}
public void fwdOnUberDeployed(const VSH2Player victim, const VSH2Player attacker)
{
	PrintToConsole(attacker.index, "fwdOnUberDeployed:: ==> Medic name: %N | Target name: %N", attacker.index, victim.index);
	PrintToConsole(victim.index, "fwdOnUberDeployed:: ==> Medic name: %N | Target name: %N", attacker.index, victim.index);
}
public void fwdOnUberLoop(const VSH2Player victim, const VSH2Player attacker)
{
	PrintToConsole(attacker.index, "fwdOnUberLoop:: ==> Medic name: %N | Target name: %N", attacker.index, victim.index);
	PrintToConsole(victim.index, "fwdOnUberLoop:: ==> Medic name: %N | Target name: %N", attacker.index, victim.index);
}
public void fwdOnMusic(char song[PLATFORM_MAX_PATH], float &time, const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnMusic:: ==> Called");
}
public void fwdOnRoundEndInfo(const VSH2Player player, bool bossBool, char message[512])
{
	PrintToConsole(player.index, "fwdOnRoundEndInfo:: %N", player.index);
}
public void fwdOnLastPlayer(const VSH2Player boss)
{
	for (int i=MaxClients; i; --i)
		if( IsClientInGame(i) )
			PrintToConsole(i, "fwdOnLastPlayer:: ==> Called");
}

public void fwdOnBossHealthCheck(const VSH2Player player, bool bossBool, char message[512])
{
	PrintToConsole(player.index, "fwdOnBossHealthCheck:: %N", player.index);
}

public void fwdOnControlPointCapped(char cappers[MAXPLAYERS+1], const int team)
{
	PrintToConsole(cappers[0], "fwdOnControlPointCapped:: %N", cappers[0]);
}

public void fwdOnPrepRedTeam(const VSH2Player player)
{
	PrintToConsole(player.index, "fwdOnPrepRedTeam:: %N", player.index);
}

public void fwdOnRedPlayerThink(const VSH2Player player)
{
	player.SetPropInt("iDamage", player.GetPropInt("iDamage") + 1);
}

public Action fwdOnScoreTally(const VSH2Player player, int& points_earned, int& queue_earned)
{
	PrintToChatAll("fwdOnScoreTally:: %N: points - %i, queue - %i", player.index, points_earned, queue_earned);
}

public Action fwdOnItemOverride(const VSH2Player player, const char[] classname, int itemdef, Handle& item)
{
	PrintToChat(player.index, "%s - %i", classname, itemdef);
	return Plugin_Continue;
}

public void fwdOnBossSuperJump(const VSH2Player player)
{
	PrintToChat(player.index, "OnBossSuperJump:: %N", player.index);
}

public Action fwdOnBossDoRageStun(const VSH2Player player, float& dist)
{
	PrintToChat(player.index, "OnBossDoRageStun:: %N - dist: %f", player.index, dist);
	return Plugin_Continue;
}

public void fwdOnBossWeighDown(const VSH2Player player)
{
	PrintToChat(player.index, "OnBossWeighDown:: %N", player.index);
}

public void fwdOnRPSTaunt(const VSH2Player loser, const VSH2Player winner)
{
	PrintToChatAll("fwdOnRPSTaunt:: winner: %N | loser: %N", winner.index, loser.index);
}

public Action fwdOnBossAirShotProj(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(attacker, "fwdOnBossAirShotProj:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	PrintToConsole(victim.index, "fwdOnBossAirShotProj:: ==> attacker name: %N | victim name: %N", attacker, victim.index);
	return Plugin_Continue;
}

public Action fwdOnBossTakeFallDamage(VSH2Player victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	PrintToConsole(victim.index, "fwdOnBossTakeFallDamage:: ==> victim name: %N | damage: %f", victim.index, damage);
	return Plugin_Continue;
}

public void fwdOnBossGiveRage(VSH2Player player, int damage, float& amount)
{
	PrintToConsole(player.index, "fwdOnBossGiveRage:: ==> player name: %N | damage: %i, calculated rage amount: %f", player.index, damage, amount);
}

public void LoadVSH2Hooks()
{
	if (!VSH2_HookEx(OnCallDownloads, fwdOnDownloadsCalled))
		LogError("Error Hooking OnCallDownloads forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossSelected, fwdBossSelected))
		LogError("Error Hooking OnBossSelected forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnTouchPlayer, fwdOnTouchPlayer))
		LogError("Error Hooking OnTouchPlayer forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnTouchBuilding, fwdOnTouchBuilding))
		LogError("Error Hooking OnTouchBuilding forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossThink, fwdOnBossThink))
		LogError("Error Hooking OnBossThink forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossModelTimer, fwdOnBossModelTimer))
		LogError("Error Hooking OnBossModelTimer forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDeath, fwdOnBossDeath))
		LogError("Error Hooking OnBossDeath forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossEquipped, fwdOnBossEquipped))
		LogError("Error Hooking OnBossEquipped forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossInitialized, fwdOnBossInitialized))
		LogError("Error Hooking OnBossInitialized forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnMinionInitialized, fwdOnMinionInitialized))
		LogError("Error Hooking OnMinionInitialized forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossPlayIntro, fwdOnBossPlayIntro))
		LogError("Error Hooking OnBossPlayIntro forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage, fwdOnBossTakeDamage))
		LogError("Error Hooking OnBossTakeDamage forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage, fwdOnBossDealDamage))
		LogError("Error Hooking OnBossDealDamage forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnPlayerKilled, fwdOnPlayerKilled))
		LogError("Error Hooking OnPlayerKilled forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnPlayerAirblasted, fwdOnPlayerAirblasted))
		LogError("Error Hooking OnPlayerAirblasted forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnTraceAttack, fwdOnTraceAttack))
		LogError("Error Hooking OnTraceAttack forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossMedicCall, fwdOnBossMedicCall))
		LogError("Error Hooking OnBossMedicCall forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTaunt, fwdOnBossTaunt))
		LogError("Error Hooking OnBossTaunt forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossKillBuilding, fwdOnBossKillBuilding))
		LogError("Error Hooking OnBossKillBuilding forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossJarated, fwdOnBossJarated))
		LogError("Error Hooking OnBossJarated forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnMessageIntro, fwdOnMessageIntro))
		LogError("Error Hooking OnMessageIntro forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossPickUpItem, fwdOnBossPickUpItem))
		LogError("Error Hooking OnBossPickUpItem forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnVariablesReset, fwdOnVariablesReset))
		LogError("Error Hooking OnVariablesReset forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnUberDeployed, fwdOnUberDeployed))
		LogError("Error Hooking OnUberDeployed forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnUberLoop, fwdOnUberLoop))
		LogError("Error Hooking OnUberLoop forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnMusic, fwdOnMusic))
		LogError("Error Hooking OnMusic forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnRoundEndInfo, fwdOnRoundEndInfo))
		LogError("Error Hooking OnRoundEndInfo forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnLastPlayer, fwdOnLastPlayer))
		LogError("Error Hooking OnLastPlayer forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossHealthCheck, fwdOnBossHealthCheck))
		LogError("Error Hooking OnBossHealthCheck forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnControlPointCapped, fwdOnControlPointCapped))
		LogError("Error Hooking OnControlPointCapped forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnPrepRedTeam, fwdOnPrepRedTeam))
		LogError("Error Hooking OnPrepRedTeam forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnRedPlayerThink, fwdOnRedPlayerThink))
		LogError("Error Hooking OnRedPlayerThink forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnScoreTally, fwdOnScoreTally))
		LogError("Error Hooking OnScoreTally forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnItemOverride, fwdOnItemOverride))
		LogError("Error Hooking OnItemOverride forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnStomp, fwdOnBossDealDamage_OnStomp))
		LogError("Error Hooking OnBossDealDamage_OnStomp forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitDefBuff, fwdOnBossDealDamage_OnHitDefBuff))
		LogError("Error Hooking OnBossDealDamage_OnHitDefBuff forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitCritMmmph, fwdOnBossDealDamage_OnHitCritMmmph))
		LogError("Error Hooking OnBossDealDamage_OnHitCritMmmph forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitMedic, fwdOnBossDealDamage_OnHitMedic))
		LogError("Error Hooking OnBossDealDamage_OnHitMedic forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitDeadRinger, fwdOnBossDealDamage_OnHitDeadRinger))
		LogError("Error Hooking OnBossDealDamage_OnHitDeadRinger forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitCloakedSpy, fwdOnBossDealDamage_OnHitCloakedSpy))
		LogError("Error Hooking OnBossDealDamage_OnHitCloakedSpy forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDealDamage_OnHitShield, fwdOnBossDealDamage_OnHitShield))
		LogError("Error Hooking OnBossDealDamage_OnHitShield forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnStabbed, fwdOnBossTakeDamage_OnStabbed))
		LogError("Error Hooking OnBossTakeDamage_OnStabbed forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnTelefragged, fwdOnBossTakeDamage_OnTelefragged))
		LogError("Error Hooking OnBossTakeDamage_OnTelefragged forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnSwordTaunt, fwdOnBossTakeDamage_OnSwordTaunt))
		LogError("Error Hooking OnBossTakeDamage_OnSwordTaunt forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnHeavyShotgun, fwdOnBossTakeDamage_OnHeavyShotgun))
		LogError("Error Hooking OnBossTakeDamage_OnHeavyShotgun forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnSniped, fwdOnBossTakeDamage_OnSniped))
		LogError("Error Hooking OnBossTakeDamage_OnSniped forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnThirdDegreed, fwdOnBossTakeDamage_OnThirdDegreed))
		LogError("Error Hooking OnBossTakeDamage_OnThirdDegreed forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnHitSword, fwdOnBossTakeDamage_OnHitSword))
		LogError("Error Hooking OnBossTakeDamage_OnHitSword forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnHitFanOWar, fwdOnBossTakeDamage_OnHitFanOWar))
		LogError("Error Hooking OnBossTakeDamage_OnHitFanOWar forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnHitCandyCane, fwdOnBossTakeDamage_OnHitCandyCane))
		LogError("Error Hooking OnBossTakeDamage_OnHitCandyCane forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnMarketGardened, fwdOnBossTakeDamage_OnMarketGardened))
		LogError("Error Hooking OnBossTakeDamage_OnMarketGardened forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnPowerJack, fwdOnBossTakeDamage_OnPowerJack))
		LogError("Error Hooking OnBossTakeDamage_OnPowerJack forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnKatana, fwdOnBossTakeDamage_OnKatana))
		LogError("Error Hooking OnBossTakeDamage_OnKatana forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnAmbassadorHeadshot, fwdOnBossTakeDamage_OnAmbassadorHeadshot))
		LogError("Error Hooking OnBossTakeDamage_OnAmbassadorHeadshot forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnDiamondbackManmelterCrit, fwdOnBossTakeDamage_OnDiamondbackManmelterCrit))
		LogError("Error Hooking OnBossTakeDamage_OnDiamondbackManmelterCrit forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeDamage_OnHolidayPunch, fwdOnBossTakeDamage_OnHolidayPunch))
		LogError("Error Hooking OnBossTakeDamage_OnHolidayPunch forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossSuperJump, fwdOnBossSuperJump))
		LogError("Error Hooking OnBossSuperJump forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossDoRageStun, fwdOnBossDoRageStun))
		LogError("Error Hooking OnBossDoRageStun forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossWeighDown, fwdOnBossWeighDown))
		LogError("Error Hooking OnBossWeighDown forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnRPSTaunt, fwdOnRPSTaunt))
		LogError("Error Hooking OnRPSTaunt forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossAirShotProj, fwdOnBossAirShotProj))
		LogError("Error Hooking OnBossAirShotProj forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossTakeFallDamage, fwdOnBossTakeFallDamage))
		LogError("Error Hooking OnBossTakeFallDamage forward for VSH2 Test plugin.");
		
	if (!VSH2_HookEx(OnBossGiveRage, fwdOnBossGiveRage))
		LogError("Error Hooking OnBossGiveRage forward for VSH2 Test plugin.");
}
