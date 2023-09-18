/////////////////////////////////////////////////
// Triggerable_Pain_Volume
// Christian
//

class Triggerable_Pain_Volume extends PhysicsVolume
	placeable;

function CausePainTo(Actor Other)
{
	local float depth;
	local Pawn P;

	if(bPainCausing)
	{
		depth = 1;
		P = Pawn(Other);

		if ( DamagePerSec > 0 )
		{
			if ( Region.Zone.bSoftKillZ && (Other.Physics != PHYS_Walking) )
				return;
			Other.TakeDamage(int(DamagePerSec * depth), None, Location, vect(0,0,0), DamageType); 
			if ( (P != None) && (P.Controller != None) )
				P.Controller.PawnIsInPain(self);
		}	
		else
		{
			if ( (P != None) && (P.Health < P.Default.Health) )
			P.Health = Min(P.Default.Health, P.Health - depth * DamagePerSec);
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	if (bPainCausing)
	{
		bPainCausing = false;
	}
	else
	{
		bPainCausing = true;
	}
}

defaultproperties
{
	bStatic=false
}