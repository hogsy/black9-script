class AnimNotify_FireUseSwitch extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	Log("AnimNotify_FireUseSwitch");
	B9_AdvancedPawn(Owner).FireUseSwitch();
}
