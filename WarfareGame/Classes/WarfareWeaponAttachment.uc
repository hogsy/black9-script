// ====================================================================
//  Class:  WarfareGame.WarfareWeaponAttachment
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarfareWeaponAttachment extends WeaponAttachment;

var MuzzleFlashAttachment MuzzleFlash;
var class<MuzzleFlashAttachment> MuzzleClass;
var vector MuzzleOffset;
var rotator MuzzleRotationOffset;

var vector HitLoc;						// Used to say where a trace hit occured
var vector EffectLocationOffset[2];		// Used for 1st person vs 3rd person Effects

replication
{
	// Things the server should send to the client.
	unreliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
		HitLoc,EffectLocationOffset;
		
	reliable if (bNetDirty && Role==ROLE_Authority)
		MuzzleFlash;
}

simulated function Adjust(int Person, vector Adjustment)
{
	EffectLocationOffset[Person] = EffectLocationOffset[Person]+Adjustment;

	if (Person==0)
		log("#### New 3rd Person Offset: "$EffectLocationOffset[Person]);
	else
		log("#### New 1st Person Offset: "$EffectLocationOffset[Person]); 
}

event PostBeginPlay()
{

	local name BoneName;
	local Pawn P;
	
	Super.PostBeginPlay();

	P = Pawn(Owner);
	
	if (P!=None && MuzzleClass!=None)
	{
		MuzzleFlash = spawn(MuzzleClass,Owner);
		BoneName = P.GetWeaponBoneFor(P.Weapon);
		if (BoneName == '')
		{
			MuzzleFlash.SetLocation(P.Location);
			MuzzleFlash.SetBase(P);
		}
		else
			P.AttachToBone(MuzzleFlash,BoneName);
		
		MuzzleFlash.SetRelativeRotation(MuzzleRotationOffset);
		MuzzleFlash.SetRelativeLocation(MuzzleOffset);
	}
}

event Destroyed()
{
	if (MuzzleFlash!=None)
	{
		MuzzleFlash.Destroy();
	}
	
	Super.Destroyed();
}

simulated function GetEffectStart(out vector Start, out rotator Rot)
{
	local PlayerController PC;
	local Pawn P;
	local vector x,y,z;
	local coords C;

	P  = Pawn(Owner);
	PC = PlayerController(P.Controller); 

	if (P.IsLocallyControlled() && PC!=None && (!PC.bBehindView) )
		Start = Instigator.Weapon.Location + EffectLocationOffset[1];
	else
	{
		C = Instigator.GetBoneCoords('weapon_bone');
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);
		Start = C.Origin + (X*EffectLocationOffset[0].X) + (Y*EffectLocationOffset[0].Y) + (Z*EffectLocationOffset[0].Z);

	}
	Rot = Instigator.GetViewRotation();
}	

simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();

	if (MuzzleFlash!=None)
		MuzzleFlash.Flash();
}


