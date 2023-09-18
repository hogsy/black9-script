class AnimNotify_FireUseItem extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	Log("AnimNotify_FireUseItem");
	B9_AdvancedPawn(Owner).FireUseItem();
}
