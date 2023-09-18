class AnimNotify_StepSoundLeft extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	B9_AdvancedPawn(Owner).PlayFootStepLeft();
}
