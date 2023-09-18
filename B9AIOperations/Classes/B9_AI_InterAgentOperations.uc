//////////////////////////////////////////////////////////////////////////
//
// Black 9 Artificial Intelligence Inter-Agent Operations Class
//
//////////////////////////////////////////////////////////////////////////

class B9_AI_InterAgentOperations extends Object;


function SendTargetAttackWarning( Actor target, Pawn attacker )
{
	local Pawn					targetPawn;
	local B9_ArchetypePawnBase	targetArchPawn;
	local Controller			targetArchController;
	local vector				fireDirection;

	targetPawn = Pawn( target );
	if( targetPawn != None )
	{
		targetArchPawn = B9_ArchetypePawnBase( targetPawn );
		if( targetPawn != None )
		{
			targetArchController = targetArchPawn.Controller;
			if( targetArchController != None )
			{
				fireDirection = Target.Location - attacker.Location;
				targetArchController.ReceiveWarning( attacker, attacker.Weapon.AmmoType.ProjectileClass.Default.Speed, fireDirection );
//				log( "ALEX: Send ReceiveWarning" );
			}
		}
	}
}
