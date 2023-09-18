// ====================================================================
//  Class:  WarClassLight.AttachmentCOGEngineerGun
//  Parent: WarfareGame.WarfareWeaponAttachment
//
//  <Enter a description here>
// ====================================================================

class AttachmentCOGEngineerGun extends WarfareWeaponAttachment;


#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax PACKAGE=WeaponSounds

simulated function SpawnEffect()
{
	local vector Start;
	local rotator Rot;
	local PclCOGEngineerRay Effect;

	GetEffectStart(Start,Rot);
	
	Effect = spawn(class'PclCOGEngineerRay',Instigator,,Start,Rot );
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.X.Min=HitLoc.X;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.X.Max=HitLoc.X;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Y.Min=HitLoc.Y;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Y.Max=HitLoc.Y;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Z.Min=HitLoc.Z;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Z.Max=HitLoc.Z;
			
	BeamEmitter(Effect.Emitters[1]).BeamEndPoints[0].Offset.X.Min=HitLoc.X;
	BeamEmitter(Effect.Emitters[1]).BeamEndPoints[0].Offset.X.Max=HitLoc.X;
	BeamEmitter(Effect.Emitters[1]).BeamEndPoints[0].Offset.Y.Min=HitLoc.Y;
	BeamEmitter(Effect.Emitters[1]).BeamEndPoints[0].Offset.Y.Max=HitLoc.Y;
	BeamEmitter(Effect.Emitters[1]).BeamEndPoints[0].Offset.Z.Min=HitLoc.Z;
	BeamEmitter(Effect.Emitters[1]).BeamEndPoints[0].Offset.Z.Max=HitLoc.Z;
	
	BeamEmitter(Effect.Emitters[0]).Disabled=false;
	BeamEmitter(Effect.Emitters[1]).Disabled=false;
	 
}

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}


simulated event ThirdPersonEffects()
{

	// If we are firing, turn on the effect

	if (bAutoFire)
	{

		SpawnEffect();			
		if (AmbientSound==None)
		{
			AmbientSound = sound'WeaponSounds.CogMedicGun.C_Medic_X_JW';
		}
	}
	else
	{
		AmbientSound = none;
	}

	Super.ThirdPersonEffects();

}


defaultproperties
{
	EffectLocationOffset[0]=(X=20,Y=1,Z=8)
	EffectLocationOffset[1]=(X=0,Y=0,Z=3)
	DrawType=8
	StaticMesh=StaticMesh'3pguns_meshes.Cog_Guns.C_MedGun3rd_M_SC'
	RelativeLocation=(X=0,Y=1,Z=-0.3)
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	DrawScale=0.1
}