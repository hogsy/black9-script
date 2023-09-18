//=============================================================================
// AI_Intimidator_Gun_Attachment.uc
//
// Attachment for INtimidator Gun
//
// 
//=============================================================================


class AI_Intimidator_Gun_Attachment extends B9_WeaponAttachment;


var IntimidatorFlash Flash;
var float fWeaponClock;
var float fMuzzleFlashDisplayTime;
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

	Flash = spawn(class'IntimidatorFlash', self);
	Pawn( Owner ).AttachToBone( Flash, 'weaponbone' );
	Flash.SetRotation( Pawn( Owner ).GetBoneRotation( 'weaponbone' ) );
	Flash.bHidden = true;


}

simulated function SpawnEffect()
{
	local vector Start;
	local rotator Rot;
	local Rotator FlashRot;
	local vector FlashScale3D;
	local Emitter Flame;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		GetEffectStart( Start, Rot );

 		Flame = spawn( class'B9FX.IntimidatorMuzzelSmoke', Self );
  		Pawn( Owner ).AttachToBone( Flame, 'gunsmoke01bone' );
 		Flame.SetRotation( Pawn( Owner ).GetBoneRotation( 'gunsmoke01bone' ) );


		Flame = spawn( class'B9FX.IntimidatorMuzzelSmoke', Self );
  		Pawn( Owner ).AttachToBone( Flame, 'gunsmoke05bone' );
 		Flame.SetRotation( Pawn( Owner ).GetBoneRotation( 'gunsmoke05bone' ) );

		if( Flash != None )
		{
			FlashRot.Pitch = Rand(65535);
			Flash.SetRelativeRotation(FlashRot);
		
			FlashScale3D.X = 1 + (0.15 * (frand() - 0.5));
			FlashScale3D.Y = 1 + (0.15 * (frand() - 0.5));
			FlashScale3D.Z = 1;
			Flash.SetDrawScale3D(FlashScale3D);
			fWeaponClock = 0.0;
			Flash.bHidden = false;
		}

		//spawn(class'B9FX.proj_TracerRound_TypeTwo',Instigator,,Start,Rot);
		spawn(class'B9FX.proj_TracerRound_TypeOne',Instigator,,Start,rotator(HitLoc - Start));
	}
}
simulated function Tick( float DeltaTime )
{
	local Rotator FlashRot;
	local vector FlashScale3D;
	local Emitter Smoke;
	Super.Tick(DeltaTime);
	if(	 Flash != None )
	{
		if( Flash.bHidden == false )
		{
			// AdvanceClock
			FlashRot.Pitch = Rand(65535);
			Flash.SetRelativeRotation(FlashRot);
		
			FlashScale3D.X = 1 + (0.15 * (frand() - 0.5));
			FlashScale3D.Y = 1 + (0.15 * (frand() - 0.5));
			FlashScale3D.Z = 1;
			Flash.SetDrawScale3D(FlashScale3D);

			fWeaponClock = fWeaponClock + DeltaTime;
			if( fWeaponClock >= fMuzzleFlashDisplayTime )
			{
				Flash.bHidden = true;
				if ( Level.NetMode != NM_DedicatedServer )
				{
				
 					Smoke = spawn( class'B9FX.IntimidatorMuzzelSmoke', Self );
  					Pawn( Owner ).AttachToBone( Smoke, 'gunsmoke01bone' );
 					Smoke.SetRotation( Pawn( Owner ).GetBoneRotation( 'weaponbone' ) );

					Smoke = spawn( class'B9FX.IntimidatorMuzzelSmoke', Self );
  					Pawn( Owner ).AttachToBone( Smoke, 'gunsmoke05bone' );
 					Smoke.SetRotation( Pawn( Owner ).GetBoneRotation( 'weaponbone' ) );
        		}
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
	Start	= Location;
	Rot		= Instigator.GetViewRotation(); 

}

//////////////////////////////////
// Initialization
//


defaultproperties
{
	fMuzzleFlashDisplayTime=0.15
	FiringMode=MODE_Auto
	DrawType=8
}