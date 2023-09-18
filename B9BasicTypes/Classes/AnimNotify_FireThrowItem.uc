class AnimNotify_FireThrowItem extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	Log("AnimNotify_FireThrowItem");
	B9_AdvancedPawn(Owner).FireThrowItem();
}
