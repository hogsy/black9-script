//////////////////////////////////////////////////////////////////////////
//
// Black 9 Construction Mech Archetype Pawn Class
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnConstructionMech extends B9_ArchetypeCivilianPawn;


var array< CollisionMesh >	fCollisionParts;
var array< StaticMesh >	kCollisionPartMesh;
var array< Name >		kCollisionPartBoneName;


simulated function PostBeginPlay()
{
	local int	i;


	Super.PostBeginPlay();

	// turn off normal collision
	SetCollision( false, false, false );
	// make collision parts
	for ( i = 0; i < kCollisionPartMesh.Length; ++i )
	{
		CreateCollisionPart( kCollisionPartMesh[ i ], kCollisionPartBoneName[ i ] );
	}
	// turn on collision for parts
	for ( i = 0; i < fCollisionParts.Length; ++i )
	{
		fCollisionParts[ i ].SetCollision( true, true, true );
	}
}

simulated function Destroyed()
{
	local int	i;


	// clean up collision parts
	for ( i = 0; i < fCollisionParts.Length; ++i )
	{
		fCollisionParts[ i ].Destroy();
	}
	fCollisionParts.Length	= 0;

	Super.Destroyed();
}

simulated function CreateCollisionPart( StaticMesh collisionPartMesh, Name collisionPartBoneName )
{
	local CollisionMesh	collisionPart;


	collisionPart	= Spawn( class'CollisionMesh', Self );
	if ( collisionPart != None )
	{
		collisionPart.SetDrawType( DT_None );// must not be visible
		collisionPart.SetStaticMesh( collisionPartMesh );
		collisionPart.SetCollision( true, true, true );

		AttachToBone( collisionPart, collisionPartBoneName );

		fCollisionParts.Length	= fCollisionParts.Length + 1;
		fCollisionParts[ fCollisionParts.Length - 1 ]	= collisionPart;
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
}

// Animations
function AnimateWalking()
{
	MovementAnims[ 0 ] = 'nowpn_walk_f';
	MovementAnims[ 1 ] = 'nowpn_walk_b';
	MovementAnims[ 2 ] = 'nowpn_turn_l';
	MovementAnims[ 3 ] = 'nowpn_turn_r';
	TurnLeftAnim		= 'nowpn_turn_l';
	TurnRightAnim		= 'nowpn_turn_r';
}

function AnimateRunning()
{
	AnimateWalking();
}

simulated function AnimateSwimming()
{
	AnimateWalking();
}

simulated function AnimateTreading()
{
	AnimateWalking();
}

simulated function AnimateCrouchingWalking()
{
	AnimateWalking();
}

simulated function AnimateClimbing()
{
	AnimateWalking();
}

simulated function AnimateCowering()
{
	AnimateWalking();
}

simulated function AnimateStanding()
{
	if( bPhysicsAnimUpdate==true )
	{
		LoopIfNeeded( 'nowpn_idle', 1.0, 0.0 );
	}
}

defaultproperties
{
	kCollisionPartMesh=/* Array type was not detected. */
	kCollisionPartBoneName=/* Array type was not detected. */
	fCharacterMaxHealth=10000
	bCanCrouch=false
	bCanSwim=false
	bCanClimbLadders=false
	WaterSpeed=50
	Health=10000
	MenuName="B9_ConstructionMech"
	ControllerClass=Class'B9_AI_ControllerConstructionMech'
	Mesh=SkeletalMesh'B9_Zubrin_characters.constructionMech_mesh'
	CollisionRadius=300
	CollisionHeight=1038
	Buoyancy=10
}