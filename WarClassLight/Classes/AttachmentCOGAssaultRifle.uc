class AttachmentCOGAssaultRifle extends WarfareWeaponAttachment;

var PclCOGAssaultRifleShells BulletFX;
var vector EffectOffset;
var vector FirstPersonOffset;
var vector TracerOffset;
var bool bSnipe;
var vector HitLoc;

replication
{
	// Things the server should send to the client.
	unreliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
		bSnipe, HitLoc;
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
	local vector x,y,z,Start;
	local coords C;

	// spawn 3rd person effects
	if ( (Level.NetMode != NM_DedicatedServer) && (FiringMode != 'MODE_Grenade') )
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
		
		if (ROLE!=Role_Authority)
		{ 

			// Spawn the Tracer
			if (FlashCount % 3 == 0)
			{
	
				C = Instigator.GetBoneCoords('weapon_bone');
				GetAxes(Instigator.GetViewRotation(),X,Y,Z);
				Start = C.Origin + (X*TracerOffset.X) + (Y*TracerOffset.Y) + (Z*TracerOffset.Z);
//				spawn(class 'PclCOGTracer',Instigator,,Start,rotator(HitLoc-Start));
			}
		}
		
	}

	Super.ThirdPersonEffects();

}

defaultproperties
{
	EffectOffset=(X=20,Y=20,Z=10)
	FirstPersonOffset=(X=20,Y=20,Z=10)
	TracerOffset=(X=100,Y=0,Z=10)
	MuzzleClass=Class'COGAssaultMuzzleFlash'
	MuzzleOffset=(X=0,Y=-8,Z=-1.5)
	DrawType=8
	StaticMesh=StaticMesh'3pguns_meshes.Cog_Guns.Grunt_Gun'
	RelativeLocation=(X=0,Y=1,Z=-0.3)
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	DrawScale=0.1
}