//=============================================================================
// AI_SmallSpider_Gun_Attachment.uc
//
// Attachment for SmallSpider Gun
//
// 
//=============================================================================


class AI_SmallSpider_Gun_Attachment extends B9_WeaponAttachment;



var B9_MuzzleFlashAttachment	fMuzzleFlashRight;

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

	fMuzzleFlash = spawn( class'B9FX.MuzzleFlashFX_Medium', Self );
	Pawn( Owner ).AttachToBone( fMuzzleFlash, 'gun mount left' );
	fMuzzleFlash.SetRotation( Pawn( Owner ).GetBoneRotation( 'gun mount left' ) );

	fMuzzleFlashRight = spawn( class'B9FX.MuzzleFlashFX_Medium', Self );
	Pawn( Owner ).AttachToBone( fMuzzleFlashRight, 'gun mount right' );
	fMuzzleFlashRight.SetRotation( Pawn( Owner ).GetBoneRotation( 'gun mount right' ) );
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
		spawn(class'B9FX.proj_TracerRound_TypeOne',Instigator,,Start,rotator(HitLoc - Start));
		
		if( FlashCount % 2 == 0 )
		{
			if( fMuzzleFlashRight != None )
			{
				fMuzzleFlashRight.Flash();
			}
		}
		else
		{
			if( fMuzzleFlash != None )
			{
				fMuzzleFlash.Flash();
			}
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
	//Start	= fMuzzleDummy.Location;
	//Rot	= Instigator.GetViewRotation();
	
	//Start	= Pawn( Owner ).GetBoneCoords( 'weaponbone' ).Origin;
	//Start	= Location;
	Rot		= Instigator.GetViewRotation(); 


	if( FlashCount % 2 == 0 )
	{
		Start = Pawn( Owner ).GetBoneCoords( 'gun mount right' ).Origin;
	}
	else
	{
		Start = Pawn( Owner ).GetBoneCoords( 'gun mount left' ).Origin;
	}

}

simulated event Destroyed()
{
	if( fMuzzleFlashRight != None )
	{
		fMuzzleFlashRight.Destroy();
		fMuzzleFlashRight = None;
	}

	Super.Destroyed();
}

//////////////////////////////////
// Initialization
//


defaultproperties
{
	FiringMode=MODE_Auto
	DrawType=8
}