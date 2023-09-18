class AttachmentCOGMinigun extends WarfareWeaponAttachment;

var PclCOGAssaultRifleShells BulletFX;
var vector EffectOffset;
var vector FirstPersonOffset;

simulated function Destroyed()
{
	if ( BulletFX != None )
		BulletFX.Destroy();
	Super.Destroyed();
}

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

/* 
ThirdPersonEffects called by Pawn's C++ tick if FlashCount incremented
OR called locally for local player
*/
simulated event ThirdPersonEffects()
{

	// spawn 3rd person effects
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( BulletFX == None )
			BulletFX = Spawn(class'PclCOGAssaultRifleShells',self);

		if ( (Instigator != None) && (Instigator.Weapon != None) )
		{
			if (  BulletFX.Owner != Instigator.Weapon )
			{
				BulletFX.SetOwner(Instigator.Weapon);
				BulletFX.Emitters[0].StartLocationOffset = FirstPersonOffset;
			}
		}
		else if ( BulletFX.Owner != self )
		{
			BulletFX.SetOwner(self);
			BulletFX.Emitters[0].StartLocationOffset = EffectOffset;
		}

		BulletFX.TriggerParticle();
	}

	Super.ThirdPersonEffects();
	

}

defaultproperties
{
	EffectOffset=(X=20,Y=20,Z=10)
	FirstPersonOffset=(X=20,Y=20,Z=10)
	MuzzleClass=Class'WarClassLight.COGAssaultMuzzleFlash'
	MuzzleOffset=(X=0,Y=-10,Z=-0.5)
	DrawType=8
	StaticMesh=StaticMesh'GunMeshes.warcoggunner.chaingun'
	RelativeLocation=(X=-2.5,Y=0,Z=0)
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	DrawScale=9
}