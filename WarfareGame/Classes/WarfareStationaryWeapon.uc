// ====================================================================
//  Class:  WarfareGame.WarfareStationaryWeapon
//  Parent: Engine.StationaryWeapons
//
//  <Enter a description here>
// ====================================================================

class WarfareStationaryWeapon extends StationaryWeapons;

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax PACKAGE=WeaponSounds

var()	int   Health;			// This weapons health
var()	int   Cost;				// How much energy does this item cost
var()	float WarmUpTime;		// How long for this item to warm up
var()   Sound PlaceSound;		// Sound that get's played when this item is placed
var()	Sound RemoveSound;		// Sound that get's played when this item is removed
var()	Sound OnlineSound;		// Sound that plays when this item goes online
var()	Sound OfflineSound;		// Sound that plays when this item goes offline

var    	bool bRespawnOnRestart;	// Does this item reset and respawn itself on map start
var	  	RepairBeacon MyBeacon;	// Used to display this item is broken

replication
{
	unreliable if (ROLE==ROLE_Authority)
		Health;
}


function Reset()	// Tripmines should all go away on reset
{
	Super.Reset();

	if (bRespawnOnRestart)
	{
		bHidden = false;
		SetCollision(True,True,false);	
	}
	else
		Destroy();
}


function Remove()
{
	local WarfarePlayer WPlay;
	local WarfarePawn WPawn;
	
	WPlay = WarfarePlayer(Owner);
	if ( (WPlay != None) && (Cost>0) )
	{
		WPawn = WarfarePawn(WPlay.Pawn);
		if (WPawn!=None)
			WPawn.Energy += Cost;		
	}

	PlaySound(RemoveSound,,1.0);
	
	if (bRespawnOnRestart)
	{
		SetCollision(false,false,false);
		bHidden = true;
	}
	else
		destroy();
}

function Repair(int Add)
{
	Health = clamp(Health+Add,0,default.Health);
}

function Explode(vector HitLocation, vector HitNormal)
{
	Remove();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class <DamageType> DamageType)
{
	local float r;

	if ( (EventInstigator!=None) && (EventInstigator.PlayerReplicationInfo.Team.TeamIndex == TeamIndex)  )
		return;
		
	r = ReduceDamage(Damage, DamageType);
	Health -= R; 
	if (Health<=0)
		GotoState('Broken');
}


function float ReduceDamage(int Damage, class <DamageType> DamageType)
{
	if (DamageType.static.IsOfType(16) || DamageType.static.IsOfType(64) ) // DAMAGE_Explosive || Damage_ArmorKiller
		return Damage*2;
	else if (DamageType.static.IsOfType(32) ) // DAMAGE_Energy
		return Damage * 1.5;
	else 
		return Damage;
} 

function Activate()
{
	PlaySound(OnlineSound,,1.0);
	Super.Activate();
}
		 
function DeActivate()
{
	PlaySound(OfflineSound,,1.0);
	Super.DeActivate();
}

function SpawnBrokenEffect()
{
	Spawn(class 'PclSparks',,,location,rotation);
}

auto state Warmup
{

	function Timer()
	{
		GotoState('Online');
	}
	
	function BeginState()
	{
		SetTimer(WarmupTime,false);
		PlaySound(PlaceSound,,1.0);
	}
}

state Online
{
	function BeginState()
	{
		Activate();
	}	
}


state Broken
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class <DamageType> DamageType)
	{
		return;
	}

	function BeginState()
	{
	
		if (MyBeacon==None)
		{
			MyBeacon = Spawn(class'RepairBeacon',self,,location+vect(0,0,32),rotation);
			MyBeacon.Team = Instigator.PlayerReplicationInfo.Team.TeamIndex;
		}
	
		SpawnBrokenEffect();
		SetTimer(frand()*2,false);
		Health = 0;
		DeActivate();
	}

	function EndState()
	{
		if (MyBeacon!=None)
			MyBeacon.Destroy();
	}
	
	function Timer()
	{
		SpawnBrokenEffect();
		SetTimer(frand()*2,false);
	}		
	
	function Repair(int Add)
	{
		Health = clamp(Health+Add,0,default.Health);
		GotoState('Online');
	}
}

defaultproperties
{
	WarmUpTime=5
	PlaceSound=Sound'WeaponSounds.TripMines.tripmine_place_X_JW'
	RemoveSound=Sound'WeaponSounds.TripMines.tripmine_place_X_JW'
	OnlineSound=Sound'WeaponSounds.TripMines.Tripmines_Activate_X_JW'
	OfflineSound=Sound'WeaponSounds.TripMines.Tripmines_Activate_X_JW'
}