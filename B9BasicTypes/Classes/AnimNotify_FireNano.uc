class AnimNotify_FireNano extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	Log("AnimNotify_FireNano");
	B9_AdvancedPawn(Owner).FireNanoAttack();
}
