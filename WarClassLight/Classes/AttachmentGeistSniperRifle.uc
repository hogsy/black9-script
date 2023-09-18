class AttachmentGeistSniperRifle extends WarfareWeaponAttachment;

var PclCOGAssaultRifleShells BulletFX;
var vector EffectOffset;
var vector FirstPersonOffset;

var bool bSnipe;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
		bSnipe;
}

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
	if ( Level.NetMode != NM_DedicatedServer )
	{
		// spawn 3rd person effects
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
		
	// have pawn play firing anim
	if ( Instigator != None )
		Instigator.PlayFiring(1.0, FiringMode);
}

defaultproperties
{
	EffectOffset=(X=20,Y=20,Z=10)
	FirstPersonOffset=(X=20,Y=20,Z=10)
	Mesh=VertMesh'RifleHand'
	RelativeLocation=(X=0,Y=1,Z=1.7)
	RelativeRotation=(Pitch=32768,Yaw=16384,Roll=0)
}