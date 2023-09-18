//=============================================================================
// AI_BigSpider_Gun_Attachment.uc
//
// Attachment for BigSpider Gun
//
// 
//=============================================================================


class AI_BigSpider_Gun_Attachment extends B9_WeaponAttachment;




//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}


simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	fMuzzleFlash = spawn( class'B9FX.MuzzleFlashFX_Huge', Self );
	Pawn( Owner ).AttachToBone( fMuzzleFlash, 'weaponbone' );
	fMuzzleFlash.SetRotation( Pawn( Owner ).GetBoneRotation( 'weaponbone' ) );
}

simulated function SpawnEffect()
{
	local vector Start;
	local rotator Rot;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		GetEffectStart( Start, Rot );

		// Tracers
		//
		if( FlashCount % 2 == 0 )
		{
			spawn(class'B9FX.proj_TracerRound_TypeOne',Instigator,,Start,rotator(HitLoc - Start));
		}

		if( fMuzzleFlash != None )
		{
            fMuzzleFlash.SetRotation( Rot );
			fMuzzleFlash.Flash();
		}		
	}
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
	      
	SpawnEffect();
}

simulated function GetEffectStart(out vector Start, out rotator Rot)
{
	Start	= Location;
	Rot		= Instigator.GetViewRotation(); 
}

//////////////////////////////////
// Initialization
//


defaultproperties
{
	FiringMode=MODE_Auto
	DrawType=8
}