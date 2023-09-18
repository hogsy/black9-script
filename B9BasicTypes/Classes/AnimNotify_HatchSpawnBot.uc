class AnimNotify_HatchSpawnBot extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
//	Log("AnimNotify_HatchSpawnBot");
	B9_BotHatch(Owner).SpawnBot();
}
