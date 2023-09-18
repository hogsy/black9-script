//=============================================================================
// heavy_FlameThrower_Attachment.uc
//
// Attachment for Heavy Machinegun weapon
//
// 
//=============================================================================


class heavy_FlameThrower_Attachment extends B9_WeaponAttachment;

//#exec OBJ LOAD FILE=..\Sounds\WarfareAmbient.uax PACKAGE=WarfareAmbient


var float				fFireTimer;

//////////////////////////////////
// Functions
//


function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

simulated function SpawnLocalEffect()
{
	local vector Start;
	local rotator Rot;

	if( Role < ROLE_Authority || Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
	{
		GetEffectStart(Start,Rot);
		spawn( class'FlamethrowerEmitter', Owner, , Start, Rot );
		spawn( class'FlamethrowerStreamEmitter', Owner, , Start, Rot );
	}
}

simulated function SpawnEffect()
{
	local vector Start;
	local rotator Rot;
	
	Super.SpawnEffect();


	if( Role == ROLE_Authority )
	{
		GetEffectStart(Start,Rot);
		
		// Server always spawns the projectile
		spawn( class'proj_Flamethrower', Owner, , Start, Rot );
		
		// Server spawns own FX
		if( Instigator.IsLocallyControlled() )
		{
			spawn( class'FlamethrowerEmitter', Owner, , Start, Rot );
			spawn( class'FlamethrowerStreamEmitter', Owner, , Start, Rot );
		}
	}
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();

	SpawnEffect();
}



simulated function Tick( float Delta )
{
	if( bAutoFire )
	{
		fFireTimer += Delta;
		if( fFireTimer >= 0.05 )
		{
			SpawnLocalEffect();
			fFireTimer=0.0;
		}
	}
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fMuzzleOffset=(X=40,Y=-3,Z=9)
	fFiringAmbientSound=Sound'B9Weapons_sounds.HeavyWeapons.flamethrower_loop'
	fFiringAmbientSoundRadius=400
	fFiringAmbientSoundVolume=200
	fLightFXClass=Class'B9FX.LightFX_Flamethrower'
	FiringMode=MODE_Auto
	fAnimKind=3
	Mesh=SkeletalMesh'B9Weapons_models.flamethrower_mesh'
}