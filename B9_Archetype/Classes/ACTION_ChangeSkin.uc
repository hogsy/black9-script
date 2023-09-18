class ACTION_ChangeSkin extends ScriptedAction;

var(Action) enum ESkins
{
	SKIN_Zubrin
}Disguise;


var material JakeZubinSkin[4];
var material GruberZubinSkin[4];
var material SaharaZubinSkin[4];
//var material YlsaZubinSkin[4];

function bool InitActionFor(ScriptedController C)
{
	local B9_PlayerPawn			fPlayer;

	ForEach C.AllActors(class'B9_PlayerPawn', fPlayer)
	{
		if(fPlayer.IsA('B9_player_norm_male'))
		{
			switch(Disguise)
			{
			case SKIN_Zubrin:
				fPlayer.Skins[0] = JakeZubinSkin[0];
				fPlayer.Skins[1] = JakeZubinSkin[1];
				fPlayer.Skins[2] = JakeZubinSkin[2];
				fPlayer.Skins[3] = JakeZubinSkin[3];
				break;
			}
		}
		if(fPlayer.IsA('B9_player_mutant_male'))
		{
			switch(Disguise)
			{
			case SKIN_Zubrin:	
				fPlayer.Skins[0] = GruberZubinSkin[0];
				fPlayer.Skins[1] = GruberZubinSkin[1];
				fPlayer.Skins[2] = GruberZubinSkin[2];
				fPlayer.Skins[3] = GruberZubinSkin[3];
				break;
			}
		}
		
		if(fPlayer.IsA('B9_player_norm_female'))
		{
			switch(Disguise)
			{
			case SKIN_Zubrin:
				fPlayer.Skins[0] = SaharaZubinSkin[0];
				fPlayer.Skins[1] = SaharaZubinSkin[1];
				fPlayer.Skins[2] = SaharaZubinSkin[2];
				fPlayer.Skins[3] = SaharaZubinSkin[3];
				break;
			}
		}
		
		//if(fPlayer.IsA('B9_player_mutant_female'))
		//{
		//	Switch(Disguise)
		//	{
		//	Case 1:
		//		Skins[0] = YlsaZubinSkin[0];
		//		Skins[1] = YlsaZubinSkin[1];
		//		Skins[2] = YlsaZubinSkin[2];
		//		Skins[3] = YlsaZubinSkin[3];
		//	}
		//}
	
	}
	return true;	
}

function string GetActionString()
{
	return ActionString;
}


defaultproperties
{
	JakeZubinSkin[0]=Shader'B9_Players_tex.Normal_male_gold.Mprotag02Gold_shader'
	JakeZubinSkin[1]=Shader'B9_Players_tex.Normal_male_gold.Mprotag01Gold_shader'
	JakeZubinSkin[2]=Shader'B9_Players_tex.Normal_male_gold.Mprotag03Gold_shader'
	JakeZubinSkin[3]=Shader'B9_Players_tex.Normal_male_gold.Mprotag04Gold_shader'
	GruberZubinSkin[0]=Shader'B9_Players_tex.Mutant_male_gold.Mmutant02Gold_shader'
	GruberZubinSkin[1]=Shader'B9_Players_tex.Mutant_male_gold.Mmutant01Gold_shader'
	GruberZubinSkin[2]=Shader'B9_Players_tex.Mutant_male_gold.Mmutant03Gold_shader'
	GruberZubinSkin[3]=Shader'B9_Players_tex.Mutant_male_gold.Mmutant04Gold_shader'
	SaharaZubinSkin[0]=Shader'B9_Players_tex.Normal_Female_gold.Fprotag02Gold_shader'
	SaharaZubinSkin[1]=Shader'B9_Players_tex.Normal_Female_gold.Fprotag01Gold_shader'
	SaharaZubinSkin[2]=Shader'B9_Players_tex.Normal_Female_gold.Fprotag03Gold_shader'
	SaharaZubinSkin[3]=Shader'B9_Players_tex.Normal_Female_gold.Fprotag04Gold_shader'
	ActionString="Change Skin"
}