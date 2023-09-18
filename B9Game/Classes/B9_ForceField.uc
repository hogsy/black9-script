
class B9_ForceField extends B9_Special_Level_Objects
	placeable;


var(ForceField)	bool	fActive;
var				Sound	Activate;
var				Sound	Deactivate;
var				Sound	ForceFieldAmbSound;
var				float	ForceFieldVolume;

const	kBounceFactor	= -1000;
const	kDamage			= 2;


simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( fActive )
	{
		AmbientSound	= ForceFieldAmbSound;
		bHidden			= false;
		bProjTarget		= true;
		SetCollision( true, false, true );
	}
	else
	{
		AmbientSound	= None;
		bHidden			= true;
		bProjTarget		= false;
		SetCollision( false, false, false );
	}
}


function Trigger( actor Other, pawn EventInstigator )
{
	if( fActive )
	{
		AmbientSound	= None;
		fActive			= false;
		bHidden			= true;
		bProjTarget		= false;
		SetCollision( false, false, false );
		PlaySound(Deactivate, SLOT_None, ForceFieldVolume,,400);
	}
	else
	{
		AmbientSound	= ForceFieldAmbSound;
		fActive			= true;
		bHidden			= false;
		bProjTarget		= true;
		SetCollision( true, false, true );
		PlaySound(Activate, SLOT_None, ForceFieldVolume,,400);
		
	}
}

singular function Bump( Actor Other )
{
	local Vector velDir, v1, v2, v3;
	local B9_AdvancedPawn P;
	local PlayerController	PC;
	
	if( !fActive )
	{
		return;
	}

	P = B9_AdvancedPawn( Other );
	if( P == None )
	{
		return;
	}

	v1 = Vector( Other.Rotation );
	v2 = Normal( v1 );
	v3 = ( v2 * kBounceFactor );

	Spawn( class'HitFX_ForceField',,,Other.Location,Rotation );

	P.TakeDamage( kDamage, None, Other.Location, vect(0,0,0), class'Impact' );
	Other.SetPhysics( PHYS_Falling );
	Other.Velocity = v3;

	PC = PlayerController( Pawn( Other ).Controller );
	if( PC != None )
	{
		PC.ClientPlayForceFeedback( "ForceField" );
	}
}






defaultproperties
{
	fActive=true
	Activate=Sound'B9Fixtures_sounds.ForceField.forcefield_activate'
	DeActivate=Sound'B9Fixtures_sounds.ForceField.forcefield_deactivate'
	ForceFieldAmbSound=Sound'B9Fixtures_sounds.ForceField.forcefield_loop'
	ForceFieldVolume=2
	DrawType=8
	StaticMesh=StaticMesh'Luna_hanger_mesh_HD.force_field.force_field_mesh'
	RemoteRole=2
	SoundRadius=512
	bCollideActors=true
	bBlockPlayers=true
	bProjTarget=true
}