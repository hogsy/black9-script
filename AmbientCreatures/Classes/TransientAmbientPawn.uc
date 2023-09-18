

class TransientAmbientPawn extends AmbientPawn
	notplaceable
	abstract;

var bool bFlyer;
var bool bSwimmer;
var bool bDestroySoon;
var bool bPermanent;
var TransientAmbientPawn NextSlave; // list of slave pawns
var float SleepTime;

function MakePermanent()
{
	bPermanent = true;
	bStasis = true;
}

function Destroyed()
{
	local TransientAmbientPawn T;

	Super.Destroyed();
	if ( Controller != None )
	{
		if ( Controller.Pawn == self )
			TransientAmbientCreature(Controller).SlavePawnDied(self);

		// remove self from slave list
		for ( T=TransientAmbientPawn(Controller.Pawn); T!=None; T=T.NextSlave )
			if ( T.NextSlave == self )
			{
				T.NextSlave = NextSlave;
				break;
			}
	}
}

// add slaves
function Timer()
{
	local int SpawnNum, NumSlaves;
	local TransientAmbientPawn Last;

	NumSlaves = TransientAmbientCreature(Controller).NumSlaves;
	if ( (Controller.Pawn != Self) || (NumSlaves <= 0) )
	{
		SetTimer(0.0, false);
		return;
	}
	
	if ( NumSlaves < 4 )
		SpawnNum = Min(NumSlaves,2);
	else
		SpawnNum = NumSlaves/4;

	Last = self;
	While ( Last.NextSlave != None )
		Last = Last.NextSlave;

	TransientAmbientCreature(Controller).AddSlaves(Last,SpawnNum);
}


	
function DestroyAll()
{
	if ( NextSlave != None )
		NextSlave.DestroyAll();
	Destroy();
}

function VerifyLastRenderTime()
{
	if ( bPermanent )
	{
		Controller.Pawn.LastRenderTime = Level.TimeSeconds;
		return;
	}
	Controller.Pawn.LastRenderTime = Max(LastRenderTime,Controller.Pawn.LastRenderTime);
	if ( NextSlave != None )
		NextSlave.VerifyLastRenderTime();
}
	
event FellOutOfWorld(eKillZType KillType)
{
	Destroy();
}

function bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;
		
	return false;
}

function EncroachedBy( actor Other )
{
}

singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( (NewVolume.bWaterVolume && !bSwimmer) )
	{
		Velocity *= -1;
		Acceleration *= -1;
	}
}

function float MoveTimeTo(vector Destination)
{
	return 1;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	Died(instigatedBy.Controller,damageType,hitLocation);
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( Controller.Pawn == self )
		Controller.PawnDied(self);
	PlayDying(DamageType, HitLocation);
	GotoState('Dying');
	if ( PhysicsVolume.bDestructive )
	{
		Destroy();
		return;
	}
}

function float GetSleepTime()
{
	return (SleepTime * FRand());
}
// Wandering state used only by Slave Pawns
auto state Wandering
{
	ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

begin:
//////////////////////////////////////////
// X. Tan, Taldren, 5/27/03
// was if ( Controller == None )
	if ( (( Role == ROLE_Authority ) && (Controller == None)) )
// End Modification
/////////////////////////	
		Destroy();
	else if ( Controller.Pawn != self )
	{
		if ( Controller.Pawn == None )
		{
			Controller.PawnDied(self);
			Controller.GotoState('Wandering','KeepGoing');
		}
		else
		{
			// slaves pick destination to follow master pawn
			TransientAmbientCreature(Controller).PickSlaveDestination(self);
			Sleep( GetSleepTime() );
			Goto('Begin');
		}
	} 
}

State Dying
{
	ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
		GotoState('Dying', 'Dead');
		//fixme - destroy and leave splat mark if bug
	}	

	function BeginState()
	{
		// don't call super
	}

Dead:
	Sleep(5);
	if ( Level.bDropDetail || (Level.TimeSeconds - LastRenderTime > 1) )
		Destroy();
	else
		Goto('Dead');
Begin:
	StopAnimating();
	SetPhysics(PHYS_Falling);
}

defaultproperties
{
	SleepTime=2
	bLOSHearing=false
	RemoteRole=0
	bUnlit=true
	CollisionRadius=0
	CollisionHeight=0
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	bProjTarget=false
}