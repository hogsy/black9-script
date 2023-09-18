// ====================================================================
//  Class:  WarClassHeavy.AttachmentGeistMinigun
//  Parent: WarClassHeavy.AttachmentCOGMinigun
//
//  <Enter a description here>
// ====================================================================

class AttachmentGeistMinigun extends AttachmentCOGMinigun;

var AttachmentCogMiniGun Next;

#exec OBJ LOAD FILE=..\animations\GeistGunner_chaingun.ukx PACKAGE=GeistGunner_chaingun

replication
{
	reliable if (ROLE==Role_Authority)
		Next;
}

event PostBeginPlay()
{
}

function SetFlashBone(name BoneName, bool InvertOffsets)
{
	local Pawn P;
	
	P = Pawn(Owner);
	
	if (InvertOffsets)
	{
		MuzzleRotationOffset *= -1;
		MuzzleOffset *= -1;
	}
	
	if (P!=None && MuzzleClass!=None)
	{
		MuzzleFlash = spawn(MuzzleClass,Owner);
		P.AttachToBone(MuzzleFlash,BoneName);
		MuzzleFlash.SetRelativeRotation(MuzzleRotationOffset);
		MuzzleFlash.SetRelativeLocation(MuzzleOffset);
		
		// spawn 3rd person effects
		if ( Level.NetMode != NM_DedicatedServer )
		{
			BulletFX = Spawn(class'PclCOGAssaultRifleShells',Instigator);
			P.AttachToBone(BulletFX,BoneName);
			
			if (!InvertOffsets)
			{
				BulletFX.Emitters[0].StartVelocityRange.Y.Min *= -1;
				BulletFX.Emitters[0].StartVelocityRange.Y.Max *= -1;
				BulletFX.SetRelativeLocation(vect(0,-3,0));
			}
			
			
		}	
	}
}

simulated event ThirdPersonEffects()
{

	// spawn 3rd person effects
	if ( Level.NetMode != NM_DedicatedServer )
	{
		BulletFX.TriggerParticle();
		BulletFX.TriggerParticle();
	}

	PlayAnim('Shoot');
	
	if (Next!=None)
		Next.ThirdPersonEffects();
	
	
	Super(WarfareWeaponAttachment).ThirdPersonEffects();
	

}

/*
simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();

}

*/

defaultproperties
{
	MuzzleOffset=(X=8,Y=0,Z=0)
	MuzzleRotationOffset=(Pitch=0,Yaw=16384,Roll=0)
	DrawType=2
	Mesh=SkeletalMesh'GeistGunner_chaingun.chaingun'
	DrawScale=1
}