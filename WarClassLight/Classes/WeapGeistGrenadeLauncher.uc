//===============================================================================
//  [Geist Grenade Launcher ]  COOL INOXX GeistHeavy Gun
//===============================================================================

class WeapGeistGrenadeLauncher extends WarfareWeapon;

#exec MESH  MODELIMPORT MESH=geistheavyMesh MODELFILE=..\WarClassContent\Models\geistGL.PSK LODSTYLE=0
#exec MESH  ORIGIN MESH=geistheavyMesh X=0 Y=0 Z=64 YAW=128 PITCH=00 ROLL=00
#exec ANIM  IMPORT ANIM=geistheavyAnims ANIMFILE=..\WarClassContent\Models\geistGL.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=geistheavyMesh X=.05 Y=.05 Z=.05
#exec MESH  DEFAULTANIM MESH=geistheavyMesh ANIM=geistheavyAnims

#exec ANIM SEQUENCE ANIM=geistheavyAnims SEQ=load GROUP=Select

#exec ANIM DIGEST ANIM=geistheavyAnims USERAWINFO VERBOSE

/*
 * Animation sequence load    0  Tracktime: 51.000000 rate: 25.000000 
	  First raw frame  0  total raw frames 51  group: [None]

 * Animation sequence shoot    1  Tracktime: 45.000000 rate: 25.000000 
	  First raw frame  51  total raw frames 45  group: [None]

 * Animation sequence holster    2  Tracktime: 16.000000 rate: 25.000000 
	  First raw frame  96  total raw frames 16  group: [None]

 * Animation sequence reload    3  Tracktime: 82.000000 rate: 25.000000 
	  First raw frame  112  total raw frames 82  group: [None]

*/

// pickup and 3rd person version

#exec MESH  MODELIMPORT MESH=GeistGL3 MODELFILE=..\WarClassContent\Models\GeistGL3.PSK LODSTYLE=0
#exec MESH  ORIGIN MESH=GeistGL3 X=0 Y=0 Z=64 YAW=128 PITCH=00 ROLL=00
#exec ANIM  IMPORT ANIM=GeistGL3Anims ANIMFILE=..\WarClassContent\Models\GeistGL3.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=GeistGL3 X=.03 Y=.03 Z=.03
#exec MESH  DEFAULTANIM MESH=GeistGL3 ANIM=GeistGL3Anims

#exec ANIM DIGEST ANIM=GeistGL3Anims USERAWINFO VERBOSE

var class<GrenadeAmmunition> InitialGrenadeType[8];
var int InitialGrenadeCount[8];
var GrenadeAmmunition AvailableGrenadeType[8];
var int SelectedAmmo;	// offset of selected ammo type

function float GetRating()
{
	local name tempname;

	return AvailableGrenadeType[SelectedAmmo].RateSelf(Instigator, TempName);
}

function float GetAIRating()
{
	local float BestRating, NewRating;
	local int BestAmmo, i;
	local name tempname;

	BestAmmo = -1;
	for ( i=0; i<ArrayCount(AvailableGrenadeType); i++ )
	{
		if ( AvailableGrenadeType[i] == None )
			break;
		else
		{
			NewRating = AvailableGrenadeType[i].RateSelf(Instigator, tempname);
			if ( NewRating == BestRating )
				NewRating = NewRating + 0.1 * (FRand() - 0.5);
			if ( (BestAmmo == -1) || (NewRating > BestRating) )
			{
				BestAmmo = i;
				BestRating = NewRating;
			}
		}
	}
	
	if ( BestAmmo >= 0 )
	{
		SelectedAmmo = BestAmmo;
		ChangeAmmo();
	}
	CurrentRating = BestRating;
	return BestRating;
}
 			
function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas,YL, YPos);

	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Projectile type "$AmmoType.ProjectileClass, false);
}

event TravelPostAccept()
{
	local int i;

	if ( Pawn(Owner) == None )
		return;
	for ( i=0; i<ArrayCount(AvailableGrenadeType); i++ )
	{
		if ( AvailableGrenadeType[i] == None )
			break;
		else
		{
			AmmoType = Ammunition(Pawn(Owner).FindInventoryType(InitialGrenadeType[i]));
			if ( AmmoType == None )
			{		
				AmmoType = Spawn(InitialGrenadeType[i]);	// Create ammo type required		
				Pawn(Owner).AddInventory(AmmoType);		// and add to player's inventory
				AmmoType.AmmoAmount = InitialGrenadeCount[i]; 
				AmmoType.GotoState('');
			}
		}
	}

	Super.TravelPostAccept();
}

function GiveAmmo( Pawn Other )
{
	local int i;

	for ( i=0; i<ArrayCount(InitialGrenadeType); i++ )
	{
		if ( InitialGrenadeType[i] == None )
			return;
		else
		{
			AmmoName = InitialGrenadeType[i];
			PickupAmmoCount = InitialGrenadeCount[i];
			Super.GiveAmmo(Other);
			AvailableGrenadeType[i] = GrenadeAmmunition(AmmoType);
			SelectedAmmo = i;
			ChangeAmmo();
		}
	}
}	

function ChangeAmmo()
{
	AmmoName = AvailableGrenadeType[SelectedAmmo].Class;
	AmmoType = AvailableGrenadeType[SelectedAmmo];
}

/* FIXME
function bool HandlePickupQuery( Pickup Item )
- need to update all ammos
*/

simulated function bool ClientAltFire( float Value )
{
	return true;
}

/* 
Cycle through available ammo types
*/
function AltFire( float Value )
{
	SelectedAmmo++;
	if ( (SelectedAmmo > 7) || (AvailableGrenadeType[SelectedAmmo] == None) )
		SelectedAmmo = 0;
	ChangeAmmo();
	ClientWeaponEvent(AvailableGrenadeType[SelectedAmmo].EventName);
}

/* Check if picked up item should be added to available ammo
*/
function AddAmmoType( GrenadeAmmunition A )
{
	local int i;

	for ( i=0; i<ArrayCount(AvailableGrenadeType); i++ )
	{
		if ( AvailableGrenadeType[i].class == A.class )
			return;
		else if ( AvailableGrenadeType[i] == None )
		{
			AvailableGrenadeType[i] = A;
			return;
		}
	}
}

function ClientWeaponEvent(name EventType)
{
	Instigator.ClientMessage("Switched to "$EventType);
}

simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, 3.0);
	PlayAnim('Shoot',0.7 + 0.5 * FireAdjust, 0.05);
}

defaultproperties
{
	InitialGrenadeType[0]=Class'SeekingRocketAmmo'
	InitialGrenadeType[1]=Class'TossedGrenadeAmmunition'
	InitialGrenadeType[2]=Class'SeekingRocketAmmo'
	InitialGrenadeCount[0]=50
	InitialGrenadeCount[1]=50
	InitialGrenadeCount[2]=50
	ReloadCount=5
	AutoSwitchPriority=9
	FireOffset=(X=20,Y=4,Z=-5)
	ShakeMag=350
	shaketime=0.2
	ShakeVert=(X=0,Y=0,Z=7.5)
	AIRating=0.85
	FireSound=Sound'WarEffects.EightBall.Ignite'
	SelectSound=Sound'WarEffects.EightBall.Selecting'
	DisplayFOV=40
	InventoryGroup=9
	PickupClass=Class'PickupGeistGrenadeLauncher'
	PlayerViewOffset=(X=30,Y=14,Z=-10)
	BobDamping=0.975
	AttachmentClass=Class'AttachmentGeistGrenadeLauncher'
	ItemName="Grenade Launcher"
	Mesh=SkeletalMesh'geistheavyMesh'
	DrawScale=0.4
	Skins=/* Array type was not detected. */
}