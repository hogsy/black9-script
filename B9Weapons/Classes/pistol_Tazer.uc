//=============================================================================
// pistol_Tazer.uc
//
// Tazer Pistol weapon
//
// 
//=============================================================================


class pistol_Tazer extends B9LightWeapon;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunIcon FILE=Textures\SwarmGunIcon.bmp


//////////////////////////////////
// Variables
//



//////////////////////////////////
// Functions
//
function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);	
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (TraceDist * X); 

	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	AmmoType.ProcessTraceHit(self, Other, HitLocation, HitNormal, X,Y,Z);

	if (Other==None)
		HitLocation = EndTrace;
	
	if (ThirdPersonActor!=None)
	{
		pistol_Tazer_Attachment(ThirdPersonActor).HitLoc=HitLocation;
	}
}

simulated function FakeTrace()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StartTrace = GetFireStart(X,Y,Z); 
	EndTrace = StartTrace + TraceDist * X; 
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	if (Other==None)
		HitLocation = EndTrace;

	if (ThirdPersonActor!=None)
	{
		pistol_Tazer_Attachment(ThirdPersonActor).HitLoc=HitLocation;
		pistol_Tazer_Attachment(ThirdPersonActor).ThirdPersonEffects();
	}
}

function ServerFire()
{
	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}

	GotoState('NormalFire');
	TraceFire(TraceAccuracy,0,0);
	LocalFire();
	
	if( ThirdPersonActor != None )
	{
		pistol_Tazer_Attachment(ThirdPersonActor).bAutoFire = true;
		pistol_Tazer_Attachment(ThirdPersonActor).FlashCount++;
	}
}

function Finish()
{
	if (!Instigator.PressingFire())
	{
		if (ThirdPersonActor!=None)
		{
			pistol_Tazer_Attachment(ThirdPersonActor).bAutoFire = false;
			if ( (Role==ROLE_Authority) && (Instigator.IsLocallyControlled() ) )
			{
				pistol_Tazer_Attachment(ThirdPersonActor).ThirdPersonEffects();
			}
		}
	}
	
	Super.Finish();		
}



simulated function ClientFinish()
{
	if (!Instigator.PressingFire())
	{
		if (ThirdPersonActor!=None)
		{
			pistol_Tazer_Attachment(ThirdPersonActor).bAutoFire = false;
			pistol_Tazer_Attachment(ThirdPersonActor).ThirdPersonEffects();
		}
	}

	Super.ClientFinish();		
}


simulated function PlayFiring()
{
	PlayAnim('nowpn_walk_idle_1',1.0);
	
	if ( Instigator.IsLocallyControlled() )
	{
		FakeTrace();
	}

	PlayOwnedSound( GetFireSound(), SLOT_None, 1.0f);
}


//////////////////////////////////
// States
//
state ClientFiring
{
	simulated function BeginState()
	{
		pistol_Tazer_Attachment(ThirdPersonActor).bAutoFire = true;
		pistol_Tazer_Attachment(ThirdPersonActor).FlashCount++;
	}
}


//////////////////////////////////
// Initialization
//








defaultproperties
{
	fAmmoExpendedPerShot=1
	fUniqueID=10
	fForceFeedbackEffectName="TazerFire"
	AmmoName=Class'ammo_Tazer'
	ReloadCount=15
	TraceDist=1024
	PickupClass=Class'pistol_Tazer_Pickup'
	AttachmentClass=Class'pistol_Tazer_Attachment'
	Icon=Texture'B9HUD_textures.Browser.ThugPistol_BrIcon_tex'
	ItemName="Tazer Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.StunGun_mesh'
}