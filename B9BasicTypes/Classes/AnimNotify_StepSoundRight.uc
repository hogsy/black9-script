class AnimNotify_StepSoundRight extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	B9_AdvancedPawn(Owner).PlayFootStepRight();
}
