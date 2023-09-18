// ====================================================================
//  Class:  WarClassLight.AttachmentCOGPulse
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class AttachmentCOGPulse extends WarfareWeaponAttachment;

var byte Mode;	// 0 = Normal, 1 = AltFire
var float ShotCharge;

replication
{
	// Things the server should send to the client.
	unreliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
		Mode, ShotCharge;
}

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

simulated function SpawnPrimaryEffect(vector Start, vector End)
{
	local PclCOGP9Primary Effect;
	local int team;
	
	Team = Instigator.PlayerReplicationInfo.Team.TeamIndex; 
	
	Effect = Spawn(class 'PclCOGP9Primary',Instigator,,Start);	
	if (Effect!=None)
	{
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.X.Min=End.X;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.X.Max=End.X;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.Y.Min=End.Y;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.Y.Max=End.Y;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.Z.Min=End.Z;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.Z.Max=End.Z;
		
		Effect.Activate(Instigator.PlayerReplicationInfo.Team.TeamIndex);
		
	}
}	

simulated function ScaleColor(out Color C, float S,int Team)
{
	if (Team==0)	
		C.R = int ( float(C.R) * S);
		
	C.G = int ( float(C.G) * S);
	
	if (Team==1)
		C.B = int ( float(C.B) * S);
	
}

simulated function SpawnSecondaryEffect(vector Start, vector End)
{
	local PclCOGP9Secondary Effect;
	local float dist, Perc;
	local int team;
	
	
	Team = Instigator.PlayerReplicationInfo.Team.TeamIndex; 

	Effect = Spawn(class 'PclCOGP9Secondary',Instigator,,Start,Rotator(Start-End));	
	if (Effect!=None)
	{
		Dist=vsize(End-Start);

		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.X.Min=End.X;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.X.Max=End.X;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.Y.Min=End.Y;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.Y.Max=End.Y;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.Z.Min=End.Z;
		BeamEmitter(Effect.Emitters[Team]).BeamEndPoints[0].Offset.Z.Max=End.Z;
		
		Perc = fClamp(1-ShotCharge/100,0.1,1);
		
		ScaleColor(SpriteEmitter(Effect.Emitters[Team+2]).ColorScale[0].Color,Perc,Team);
		ScaleColor(SpriteEmitter(Effect.Emitters[Team+2]).ColorScale[1].Color,Perc,Team);
		ScaleColor(SpriteEmitter(Effect.Emitters[Team+4]).ColorScale[0].Color,Perc,Team);
		ScaleColor(SpriteEmitter(Effect.Emitters[Team+4]).ColorScale[1].Color,Perc,Team);
		
		Effect.Activate(Dist,Team);
		
	}
}	


simulated event ThirdPersonEffects()
{
	local rotator Rot;
	local vector Start, End;
	
	GetEffectStart(Start,Rot);
	End = HitLoc;
	
	if (Mode==0)						// Primary
		SpawnPrimaryEffect(Start,End);
	else								// Secondary
		SpawnSecondaryEffect(End,Start);

	
	Super.ThirdPersonEffects();	
}

defaultproperties
{
	MuzzleClass=Class'COGPulseMuzzleFlash'
	MuzzleOffset=(X=0,Y=-10,Z=-1.5)
	EffectLocationOffset[0]=(X=26,Y=0,Z=6)
	EffectLocationOffset[1]=(X=0,Y=1,Z=0)
	DrawType=8
	StaticMesh=StaticMesh'3pguns_meshes.Cog_Guns.C_PulseRifle3rd_M_SC'
	RelativeLocation=(X=0,Y=1,Z=-0.3)
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	DrawScale=0.1
}