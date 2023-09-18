class ACTION_SetPosture extends ScriptedAction;

var(Action) enum EAnimPosture
{
	POSTURE_Normal,
	POSTURE_Relaxed,
	POSTURE_Patroling,
	POSTURE_Alert
} AnimationPosture;

function bool InitActionFor(ScriptedController C)
{
	if ( C.Pawn == None )
		return false;
	switch( AnimationPosture )
	{
		case POSTURE_Normal:
			C.Pawn.SetAnimStatus('Normal');
			break;
		case POSTURE_Relaxed:
			C.Pawn.SetAnimStatus('Relaxed');
			break;
		case POSTURE_Patroling:
			C.Pawn.SetAnimStatus('Patroling');
			break;
		case POSTURE_Alert:
			C.Pawn.SetAnimStatus('Alert');
			break;
	}
	return false;	
}
