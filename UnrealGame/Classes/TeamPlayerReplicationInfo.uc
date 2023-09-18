//=============================================================================
// TeamPlayerReplicationInfo.
//=============================================================================
class TeamPlayerReplicationInfo extends PlayerReplicationInfo;

var class<Scoreboard> LocalStatsScreenClass;
var SquadAI Squad;
var bool bHolding;

// following properties are used for server-side local stats gathering and not replicated (except through replicated functions)

var bool bFirstBlood;

struct WeaponStats
{
	var class<Weapon> WeaponClass;
	var int kills;
	var int deaths;
	var int deathsholding;
};

var array<WeaponStats> WeaponStatsArray;
var int FlagTouches, FlagReturns;
var byte Spree[6];
var byte MultiKills[7];
var int Suicides;
var int flakcount,combocount,headcount;
var byte Combos[5];

replication
{
	reliable if ( bNetInitial && (Role == ROLE_Authority) )
		LocalStatsScreenClass;
	reliable if ( Role == ROLE_Authority )
		Squad, bHolding;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if ( UnrealMPGameInfo(Level.Game) != None )
		LocalStatsScreenClass = UnrealMPGameInfo(Level.Game).LocalStatsScreenClass;
}

simulated function UpdateWeaponStats(TeamPlayerReplicationInfo PRI, class<Weapon> W, int newKills, int newDeaths, int newDeathsHolding)
{
	local int i;
	local WeaponStats NewWeaponStats;

	for ( i=0; i<WeaponStatsArray.Length; i++ )
	{
		if ( WeaponStatsArray[i].WeaponClass == W )
		{
			WeaponStatsArray[i].Kills = newKills;
			WeaponStatsArray[i].Deaths = newDeaths;
			WeaponStatsArray[i].DeathsHolding = newDeathsHolding;
			return;
		}
	}
	
	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Kills = newKills;
	NewWeaponStats.Deaths = newDeaths;
	NewWeaponStats.DeathsHolding = newDeathsHolding;
	WeaponStatsArray[WeaponStatsArray.Length] = NewWeaponStats;
}
		
function AddWeaponKill(class<DamageType> D)
{
	local class<Weapon> W;
	local int i;
	local WeaponStats NewWeaponStats;
	
	if ( class<WeaponDamageType>(D) == None )
		return;
		
	W = class<WeaponDamageType>(D).default.WeaponClass;
	
	for ( i=0; i<WeaponStatsArray.Length; i++ )
	{
		if ( WeaponStatsArray[i].WeaponClass == W )
		{
			WeaponStatsArray[i].Kills++;
			return;
		}
	}
	
	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Kills = 1;
	WeaponStatsArray[WeaponStatsArray.Length] = NewWeaponStats;
}

function AddWeaponDeath(class<DamageType> D)
{
	local class<Weapon> W, LastWeapon;
	local int i;
	local WeaponStats NewWeaponStats;

	LastWeapon = Controller(Owner).GetLastWeapon();
	
	if ( LastWeapon != None )
		AddWeaponDeathHolding(LastWeapon);
	
	if ( class<WeaponDamageType>(D) == None )
		return;
		
	W = class<WeaponDamageType>(D).default.WeaponClass;
	
	for ( i=0; i<WeaponStatsArray.Length; i++ )
	{
		if ( WeaponStatsArray[i].WeaponClass == W )
		{
			WeaponStatsArray[i].Deaths++;
			return;
		}
	}
	
	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Deaths = 1;
	WeaponStatsArray[WeaponStatsArray.Length] = NewWeaponStats;
}
		
function AddWeaponDeathHolding(class<Weapon> W)
{
	local int i;
	local WeaponStats NewWeaponStats;
	
	for ( i=0; i<WeaponStatsArray.Length; i++ )
	{
		if ( WeaponStatsArray[i].WeaponClass == W )
		{
			WeaponStatsArray[i].DeathsHolding++;
			return;
		}
	}
	
	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.DeathsHolding = 1;
	WeaponStatsArray[WeaponStatsArray.Length] = NewWeaponStats;
}
