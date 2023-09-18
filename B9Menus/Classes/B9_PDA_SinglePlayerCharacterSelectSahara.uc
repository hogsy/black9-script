class B9_PDA_SinglePlayerCharacterSelectSahara extends B9_PDA_SinglePlayerCharacterSelect;

const kNumberOfClasses = 22;

var protected class<Inventory> DefaultItemClasses[kNumberOfClasses];

var protected int fStrength;
var protected int fAgility;
var protected int fDexterity;
var protected int fConstitution;

function Setup( B9_PDABase pdaBase )
{	
	Super.Setup( pdaBase );
}

function SetupPlayerInfo()
{
	local int i;
	
	fPlayerInfo.fName = "Sahara";
	fPlayerInfo.fStr  = fStrength;
	fPlayerInfo.fAgil = fAgility;
	fPlayerInfo.fDex  = fDexterity;
	fPlayerInfo.fCon  = fConstitution;
	
	fPlayerInfo.fPawnType = class'B9Characters.B9_Player_norm_female';
	
	for( i=0;i<kNumberOfClasses;i++)
	{
		fPlayerInfo.fDefaultItemClasses[i] = DefaultItemClasses[i];
	}	
}

function class<B9_MenuPDA_Menu> GetNextPlayerMenu()
{
	return class'B9_PDA_SinglePlayerCharacterSelectJake';
}

defaultproperties
{
	DefaultItemClasses[0]=Class'B9NanoSkills.skill_Hacking'
	DefaultItemClasses[1]=Class'B9Weapons.HandToHand'
	DefaultItemClasses[2]=Class'B9Gear.PDA'
	DefaultItemClasses[3]=Class'B9NanoSkills.skill_Jumping'
	DefaultItemClasses[4]=Class'B9NanoSkills.skill_meleeCombat'
	DefaultItemClasses[5]=Class'B9NanoSkills.skill_FireArmsTargeting'
	DefaultItemClasses[6]=Class'B9NanoSkills.skill_HeavyWeaponsTargeting'
	DefaultItemClasses[7]=Class'B9NanoSkills.skill_urbanTracking'
	DefaultItemClasses[8]=Class'B9Weapons.pistol_9mm'
	DefaultItemClasses[9]=Class'B9Weapons.ammo_9mmBullet'
	DefaultItemClasses[10]=Class'B9Weapons.ammo_9mmBullet'
	DefaultItemClasses[11]=Class'B9Weapons.ammo_9mmBullet'
	DefaultItemClasses[12]=Class'B9Weapons.ammo_9mmBullet'
	DefaultItemClasses[13]=Class'B9Weapons.ammo_9mmBullet'
	DefaultItemClasses[14]=Class'B9Weapons.rifle_Assault'
	DefaultItemClasses[15]=Class'B9Weapons.ammo_AssaultRifle'
	DefaultItemClasses[16]=Class'B9Weapons.ammo_AssaultRifle'
	DefaultItemClasses[17]=Class'B9Weapons.ammo_AssaultRifle'
	DefaultItemClasses[18]=Class'B9Weapons.ammo_AssaultRifle'
	DefaultItemClasses[19]=Class'B9Weapons.Explosive_Mine_Trip'
	DefaultItemClasses[20]=Class'B9Weapons.Explosive_Mine_Trip'
	DefaultItemClasses[21]=Class'B9Weapons.Explosive_Mine_Trip'
	fStrength=40
	fAgility=65
	fDexterity=48
	fConstitution=42
}