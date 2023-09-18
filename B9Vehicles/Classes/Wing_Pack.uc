class Wing_Pack extends B9_Powerups;


var Emitter		Exhaust;
var Emitter		LeftTip;
var Emitter		RightTip;
var Sound		OnAmbientSound;

function FlameOn()
{
	if ( Exhaust == None )
	{
		Exhaust = spawn(class'WingPackExhaustEmitter',Self,, GetBoneCoords( 'exhaustbone' ).Origin, GetBoneRotation( 'exhaustbone' ) );
		AttachToBone( Exhaust, 'exhaustbone' );
	}
	if ( LeftTip == None )
	{
		LeftTip = spawn(class'WingPackWingTipEmitter',Self,, GetBoneCoords( 'lstreamerbone' ).Origin, GetBoneRotation( 'lstreamerbone' ) );
		AttachToBone( LeftTip, 'lstreamerbone' );		
	}
	if ( RightTip == None )
	{
		RightTip = spawn(class'WingPackWingTipEmitter',Self,, GetBoneCoords( 'rstreamerbone' ).Origin, GetBoneRotation( 'rstreamerbone' ) );
		AttachToBone( RightTip, 'rstreamerbone' );
	}
}

function FlameOff()
{
	if ( Exhaust != None )
	{
		Exhaust.Destroy();
		Exhaust = none;
	}
	if ( LeftTip != None )
	{
		LeftTip.Destroy();
		LeftTip = none;
	}
	if ( RightTip != None )
	{
		RightTip.Destroy();
		RightTip = none;
	}
}

auto state Deactivated
{
	function BeginState()
	{
		bActive = false;
		bHidden	= true;
	}

	function EndState()
	{
	}

	function Activate()
	{
		GotoState( 'Activating' );
	}
}

state Activating
{
	function BeginState()
	{
		GotoState( 'Activated' );
	}

	function EndState()
	{
	}

	function Activate()
	{
		GotoState( 'Deactivating' );
	}
}

state Activated
{
	function BeginState()
	{
		local vector	rotX, rotY, rotZ;


		bActive = true;
		bHidden	= false;

		// this should be replaced by possession attachment system
		Owner.AttachToBone( Self, 'spacesuitbone2' );

		PlayAnim('unfolding',5.0f);
		AmbientSound = OnAmbientSound;
		FlameOn();

		Pawn( Owner ).Controller.GotoState( 'PlayerFlying' );
		// start with a little hop
		Pawn( Owner ).Velocity	+= vect( 0, 0, 1 ) * 100;
	}

	function EndState()
	{
	}

	function Activate()
	{
		GotoState( 'Deactivating' );
	}
}

state Deactivating
{
	function BeginState()
	{
		Pawn( Owner ).SetPhysics( PHYS_Falling );
		PlayAnim('folding',5.0f);
		AmbientSound = None;
		FlameOff();
	}

	function EndState()
	{
	}

	simulated function Tick( Float DeltaTime )
	{
		if ( Pawn( Owner ).Physics != PHYS_Falling )
		{
			Pawn( Owner ).Controller.GotoState( 'PlayerWalking' );
			GotoState( 'Deactivated' );
		}
		else
		{
			// slow fall

			//Velocity	-= ( PhysicsVolume.Gravity * DeltaTime * 0.5f ) * 0.75;
		}
	}

	function Activate()
	{
		GotoState( 'Activating' );
	}
}




defaultproperties
{
	OnAmbientSound=Sound'B9Misc_Sounds.Spaceship.spaceship_flight_loop1'
	fUniqueID=10
	bActivatable=true
	bDisplayableInv=true
	PickupClass=Class'Wing_Pack_Pickup'
	Icon=Texture'B9HUD_textures.Browser_items.wingpack_bricon'
	ItemName="Wing Pack"
	DrawType=2
	RemoteRole=1
	Mesh=SkeletalMesh'B9Vehicles_models.wingpack_mesh'
	SoundVolume=232
}