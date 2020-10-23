void LoadFF2Plugins()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "plugins/freaks");
	
	DirectoryListing hDir = OpenDirectory(path);
	FileType fileType;
	
	while ( hDir.GetNext(path, sizeof(path), fileType) ) {
		if ( fileType == FileType_File && StrContains(path, ".ff2") != -1 ) {
			ServerCommand("sm plugins load freaks\\%s", path);
		}
	}
}

void UnloadFF2Plugins()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "plugins/freaks");
	
	DirectoryListing hDir = OpenDirectory(path);
	FileType fileType;
	
	while ( hDir.GetNext(path, sizeof(path), fileType) ) {
		if ( fileType == FileType_File && StrContains(path, ".ff2") != -1 ) {
			ServerCommand("sm plugins unload freaks\\%s", path);
		}
	}
}

void ProcessOnCallDownload()
{
	///	Precache Sounds
	{
		StringMapSnapshot snap = ff2_cfgmgr.Snapshot();
		StringMapSnapshot snap_list;
		
		FF2SoundList list;
		FF2Identity identity;
		FF2SoundIdentity snd_id;
		
		char _key[32];
		for (int i = snap.Length - 1; i >= 0; i--) {
			snap.GetKey(i, _key, sizeof(_key));
			ff2_cfgmgr.GetIdentity(_key, identity);
			
			snap_list = identity.sndHash.Snapshot();
			
			for (int j = snap_list.Length - 1; j >= 0; j--) {
				snap_list.GetKey(j, _key, sizeof(_key));
				list = identity.sndHash.GetAssertedList(_key);
				
				for (int k = list.Length - 1; k >= 0; k--) {
					list.At(k, snd_id);
					if (snd_id.path[0]) {
						PrecacheSound(snd_id.path);
					}
				}
			}
			
			delete snap_list;
		}
		
		delete snap;
	}
}

void Call_FF2OnAbility(const FF2Player player, int mode)
{
	static char curKey[64];
	static char pl_ab[2][MAX_SUBPLUGIN_NAME];
	
#define FOR_EACH_CALLBACK \
		static FF2AbilityList list; list = player.HookedAbilities; \
		StringMapSnapshot snap = list.Snapshot(); \
		for (int i = 0; i < snap.Length; i++)
	
	
	int boss = player.index;
		
	FOR_EACH_CALLBACK {
		
		snap.GetKey(i, curKey, sizeof(curKey));
		
		FF2AbilityList.GetKeyVal(curKey, pl_ab);
		
		Call_StartForward(ff2.m_forwards[FF2OnPreAbility]);
		Call_PushCell(boss);
		Call_PushString(pl_ab[0]);
		Call_PushString(pl_ab[1]);
		Call_PushCell(mode);
		bool enabled = true;
		Call_PushCellRef(enabled);
		Call_Finish();
		
		if(!enabled) {
			continue;
		}
		
		Action act;
		Call_StartForward(ff2.m_forwards[FF2OnAbility]);
		Call_PushCell(boss);
		Call_PushString(pl_ab[0]);
		Call_PushString(pl_ab[1]);
		Call_PushCell(mode);
		Call_Finish(act);
	/*
		if ( act ) {
			/// TODO
		}
	*/
	}
	
	delete snap;
	
	#undef FOR_EACH_CALLBACK
	
	player.SetPropFloat("flRAGE", 0.0);
}

bool RandomAbilitySound(FF2SoundList list, int slot, char[] res, int maxlen)
{
	if ( !list ) return false;
	
	int[] slots = new int[15];
	int count, cur_slot;
	
	char name[6]; FormatEx(name, sizeof(name), "slot%i", slot);
	FF2SoundIdentity curEntry;
	
	for (int i = list.Length - 1; i >= 0; i--) {
		list.At(i, curEntry);
		
		int pos = FindCharInString(curEntry.name, '_', true);
		cur_slot = StringToInt(curEntry.name[pos + 1]);
		
		if ( cur_slot == slot ) {
			slots[count++] = i;
		}
	}
	
	if ( !count ) return false;
	
	list.At(slots[GetRandomInt(0, count - 1)], curEntry);
	FormatEx(res, maxlen, "%s", curEntry.path);
	
	return true;
}
