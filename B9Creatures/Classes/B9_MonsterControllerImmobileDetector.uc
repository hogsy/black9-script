/*=============================================================================

 // B9_MonsterControllerImmobileDetector

=============================================================================*/
class B9_MonsterControllerImmobileDetector extends AIController;


// Variables
#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX

var float	Aggressiveness; //0.0 to 1.0 (typically)
var		float       BaseAggressiveness; 
var   	Pawn		OldEnemy;
var		float		MeanderTime;
var		float		TimeJammed;
var		float		JammCamTime;
var(Combat) class<actor> RangedProjectile;
var(Combat)	float	ProjectileSpeed;
var(Combat) bool	bLeadTarget;		// lead target with projectile attack
var(Combat) bool	bWarnTarget;		// warn target when projectile attack
var			bool	fbIntruderSpotted;
var protected B9_mgun_muzzle_flash fMuzzleFlash;
var bool fPlayerSeen;
var Pawn fPlayerSeenPawn;
var float fMinimumJamTime;
// Global Functions

function JamCam( int Strength )
{
	JammCamTime = (FRand() * Strength) + fMinimumJamTime;
	gotostate( 'JamCammed' );
}

auto state lookingforplayer
{
	function tick( float DeltaTime )
	{
		local emitter e;
		local Actor A;
		if( fbIntruderSpotted == false && fPlayerSeen == true)
		{
			ForEach DynamicActors( class 'Actor', A, Event )
			{
				A.Trigger(self, fPlayerSeenPawn);
			}

			fbIntruderSpotted = true;
			log("Alerted Others");
		}

	}
	event SeePlayer( Pawn Seen )
	{
		fPlayerSeen = true;
		fPlayerSeenPawn = Seen;

	}

	event SeeMonster( Pawn Seen )
	{
			
	}

	

Begin:
	enable('SeePlayer');
}

state JamCammed
{
	function Tick(Float DeltaTime)
	{
		Super.Tick( DeltaTime );
		TimeJammed = TimeJammed + DeltaTime;
		if( TimeJammed > JammCamTime )
		{
			TimeJammed = 0;
			gotostate( 'lookingforplayer' );
		}
	}
	event SeePlayer( Pawn Seen )
	{
		log("Can see but Jammed!");
	}

	event SeeMonster( Pawn Seen )
	{
			
	}
}

defaultproperties
{
	Aggressiveness=0.3
	BaseAggressiveness=0.3
	ProjectileSpeed=700
	bLeadTarget=true
	bWarnTarget=true
	fMinimumJamTime=10
	bAlwaysRelevant=true
}