//=============================================================================
// GrapplingHook.uc
//
// Grappling Hook
//
// 
//=============================================================================


class GrapplingHook extends B9LightWeapon;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=GrapplingHookIcon FILE=Textures\GrapplingHookIcon.bmp


//////////////////////////////////
// Variables
//



//////////////////////////////////
// Functions
//

simulated function bool GrappleTrace()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor HitActor;
	local float Range;

	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 0);	
	EndTrace = StartTrace;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X); 
	HitActor = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	Range = vSize( HitLocation - StartTrace );

	if( HitActor == None || Range > TraceDist || !HitActor.IsA( 'GrapplingHookTarget' ) )
	{
		return false;
	}
	return true;
}

simulated function bool CanFire()
{
	local B9_BasicPlayerPawn	P;
	local actor A;
	local float Range;

	if( Pawn( Owner ).IsHumanControlled() )
	{
		P = B9_BasicPlayerPawn( Owner );
		if( P == None || P.IsPerformingExclusiveAction() )
		{
			return false;
		}
	}
	
	if( !GrappleTrace() )
	{
		return false;
	}

	return true;
}

simulated function bool NeedsToReload()
{
	return false;
}

function Finish()
{
	if( Instigator.IsLocallyControlled() )
	{
        ClientStoppedPressingFire();
	}
	SetActionExclusivity( false );
	GotoState( 'Idle' );
}



simulated function ClientFinish()
{
	SetActionExclusivity( false );
	ClientStoppedPressingFire();

	ClientStoppedPressingFire();
	GotoState('Idle');
}


//////////////////////////////////
// States
//

state NormalFire
{
	ignores AnimEnd;
Begin:
	
	ProjectileFire();
//	PlaySound( sound'prot_gun_firing_4', SLOT_None, 1.0f, false );
	Sleep( GetROF() );
	Finish();
}

state DownWeapon
{
	simulated function BeginState()
	{
		local GrapplingHookProjectile hook;

		// Kill the hook if necessary
		hook = GrapplingHookAmmunition(AmmoType).fHook;
		if ( hook != None )
		{
			hook.ReleaseHook();
		}

		Super.BeginState();
	}
}


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fROF=800
	fUniqueID=25
	fUsesAmmo=false
	fUsesClips=false
	fForceFeedbackEffectName="GrapplingHookFire"
	fIniLookupName="GrapplingHook"
	AmmoName=Class'GrapplingHookAmmunition'
	PickupAmmoCount=1
	ReloadCount=1
	AutoSwitchPriority=9
	FireSound=Sound'B9SoundFX.Bullet_Impacts.p9mm_fire'
	InventoryGroup=9
	PickupClass=Class'GrapplingHook_Pickup'
	AttachmentClass=Class'GrapplingHook_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.grappling_hook_bricon'
	ItemName="Grappling Hook"
	Mesh=SkeletalMesh'B9Weapons_models.Crossbow_mesh'
}