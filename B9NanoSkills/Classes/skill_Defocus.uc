//=============================================================================
// skill_Defocus.uc
//
//	Defocus skill
//
//=============================================================================


class skill_Defocus extends BaseAttackSkill;


//////////////////////////////////
// Variables
//

var float fFireTimer;
var float fActiveTimer;


//////////////////////////////////
// Functions
//

function ServerActivate()
{
	B9_AdvancedPawn( Owner ).PlayNanoAttack();
}

simulated function Activate()
{
	ServerActivate();

	if( Role < ROLE_Authority )
	{
		B9_AdvancedPawn( Owner ).PlayNanoAttack();
	}
}

function FireNano()
{
	UseFocus();

	SpawnFX();

	GotoState( 'Active' );
}

function TraceFire( out Vector StartLoc, out Vector HitLoc, out Actor HitActor )
{
	local Actor A;
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local B9_AdvancedPawn P;

	GetAxes( Instigator.GetViewRotation(), X, Y, Z );
	
	StartTrace	= GetFireStart( X, Y, Z ); 
	AdjustedAim = Instigator.AdjustAim( None, StartTrace, 0 );	
	EndTrace	= StartTrace;
	X			= vector(AdjustedAim);
	EndTrace	+= ( 10000 * X ); 
	A			= Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );

	
	StartLoc = StartTrace;

	if( A == None )
	{
		HitLoc = EndTrace;
	}
	else
	{
		HitActor	= A;
		HitLoc		= HitLocation;

		if( Role == ROLE_Authority && A != None )
		{
			P = B9_AdvancedPawn( A );
			if( P != None )
			{
				P.fCharacterFocus -= 30;
			}
		}
	}
}

function SpawnFX()
{
	local vector	Start, HitLoc;
	local Emitter	emitCaster, emitTarget;
	local Actor		HitActor;


	TraceFire( Start, HitLoc, HitActor );
		
	emitCaster = spawn( class'NanoFX_Defocus_Caster', Instigator,, Start, Instigator.GetViewRotation() );
	Pawn(Owner).AttachToBone( emitCaster, 'NanoBone' );

	if( HitActor != None && !HitActor.bWorldGeometry )
	{
		emitTarget = spawn( class'NanoFX_Defocus_Target', Instigator,, HitActor.Location, HitActor.Rotation );
		emitTarget.SetBase( HitActor );
	}
}


//////////////////////////////////
// States
//

simulated state Active
{

	simulated function Activate() {}

	simulated function BeginState()
	{
		fActiveTimer	= 0.0;
		fFireTimer		= 0.0;
	}

	simulated function Tick( float DeltaTime )
	{
		fActiveTimer += DeltaTime;
		if( fActiveTimer >= 0.5 )
		{
			fActiveTimer = 0.0;
			GotoState( '' );
			return;
		}

		fFireTimer += DeltaTime;
		if( fFireTimer >= 0.05 )
		{
			fFireTimer = 0.0;
			SpawnFX();
		}
	}
}



//////////////////////////////////
// Initialization
//





defaultproperties
{
	fActivatable=true
	fSkillName="Chi Drain"
	fUniqueID=20
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Chi_drain_bricon'
}