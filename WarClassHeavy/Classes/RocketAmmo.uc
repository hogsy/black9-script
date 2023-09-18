//=============================================================================
// RocketPack.
//=============================================================================
class RocketAmmo extends WarfareAmmo;

var AttachmentRocketAmmoSlot Slots[12];		// Holds info about each rocket
var float NextPossibleLock;					// When is the next possible lock
var vector MissleOffset;
var WeapCOGMiniGun MyWeapon;


replication
{
	reliable if (role<Role_Authority)
		ServerClearLocks;
		
	reliable if (role==ROLE_Authority)
		Slots;

}

// Spawn the AmmoSlots 

event PostBeginPlay()
{
	local int Slot;

	for (Slot=0;Slot<12;Slot++)
	{
		Slots[Slot] = spawn(class 'AttachmentRocketAmmoSlot',self);
		if (Slots[Slot]==None)
			log("Critical Error: Could not Spawn Rocket Ammo Slot #"$Slot);
	}

	Super.PostBeginPlay();
	
}

// Clean up

event Destroyed()
{
	local int Slot;
	
	for (Slot=0;Slot<12;Slot++)
	{
		if (Slots[Slot]!=None)
			Slots[Slot].Destroy();
	}
	
	Super.Destroyed();
}

// Allow the player to bind a key to clear all locks.

simulated exec function ClearLocks()
{
	ServerClearLocks();
}

function ServerClearLocks()
{
	local int Slot;
	for (Slot=0;Slot<12;Slot++)
		Slots[Slot].Clear();
}	

function int FindNextAvailable()
{
	local int Slot;
	for (Slot=0;Slot<12;Slot++)
		if (Slots[Slot].Status==0)
			return Slot;
	
	return -1;
}

function int FindNextLock()
{
	local int Slot;
	for (Slot=0;Slot<12;Slot++)
		if (Slots[Slot].Status==1)
			return Slot;
		
	return -1;
}

function LockOn(Pawn NewTarget)
{
	local int Slot;
	
	if (Level.TimeSeconds < NextPossibleLock)	// Don't allow locks within a given time
		return;

	Slot = FindNextAvailable();
	if (Slot>=0)
	{
		Slots[Slot].LockOn(NewTarget);
		// Play Accquiring Lock sound
	}

	NextPossibleLock = Level.TimeSeconds + 0.5;
		
	// Add sound for can't lock		
}

// Returns the number of Missles locked on

function int NoLocks()
{
	local int Slot,Cnt;
	
	for (Slot=0;Slot<12;Slot++)
		if (Slots[Slot].Status==1)
			Cnt++;
	
	return Cnt;
	
} 

function bool AnyAvailable()
{
	if ( FindNextAvailable()<0 )
		return false;
	else
		return true;
}	
		
function LaunchRocket()	// Handle launching a rocket
{
	local int Slot;
	
	for (Slot=0;Slot<12;Slot++)
	{
		if (Slots[Slot].Status==0)
		{
			SpawnRocket(Slot);
			return;
		}
	}

	return;
}

function SpawnRocket(int Slot)
{
	local ProjCOGHeavyRocket R;
	local vector SpawnPoint;
	local Rotator SpawnRot;
	
	if (Slot<0)
		Slot = FindNextAvailable();
	
	SpawnPoint = MyWeapon.GetSpawnLocation(Slot) + MissleOffset;
	SpawnRot = MyWeapon.GetSpawnRotation();
	
	R = Spawn(class 'ProjCOGHeavyRocket', Owner.Instigator,,SpawnPoint, SpawnRot);
	
	R.SeekTarget = Slots[Slot].Target;
	R.MisslePosition = Slot;
	Slots[Slot].GotoState('Reload');
}

function bool AddAmmo(int AmmoToAdd)
{
	local int Slot;
	Super.AddAmmo(AmmoToAdd);
	
	// If any Rockets need ammo.. give it to them.

	for (Slot=0;Slot<12;Slot++)
		if ( (Slots[Slot].Status==3) && (AmmoAmount>0) )
		{	
			AmmoAmount--;
			Slots[Slot].GotoState('');
			Slots[Slot].Status=0;
		}
					
	return true;
}



function float RateSelf(Pawn Shooter, out name RecommendedFiringMode)
{
	local float dist;

	if ( AmmoAmount <= 0 )
		return 0;

	if ( (Shooter == None)
		|| (Shooter.Controller == None)
		|| (Shooter.Controller.Enemy == None) )
		return 0.1;

	dist = VSize(Shooter.Location - Shooter.Controller.Enemy.Location);
	if ( dist > 2700 )
		return 0.2;
	if ( dist < 400 )
		return 0.1;
	return 0.8;
}

defaultproperties
{
	MissleOffset=(X=20,Y=0,Z=0)
	MaxAmmo=120
	AmmoAmount=48
	bRecommendSplashDamage=true
	bTrySplash=true
	ProjectileClass=Class'ProjCOGHeavyRocket'
	PickupClass=Class'WarClassLight.RocketPack'
}