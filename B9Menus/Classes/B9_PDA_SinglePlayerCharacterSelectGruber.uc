class B9_PDA_SinglePlayerCharacterSelectGruber extends B9_PDA_SinglePlayerCharacterSelect;


const kNumberOfClasses = 23;

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
	
	fPlayerInfo.fName = "Gruber";
	fPlayerInfo.fStr  = fStrength;
	fPlayerInfo.fAgil = fAgility;
	fPlayerInfo.fDex  = fDexterity;
	fPlayerInfo.fCon  = fConstitution;
	fPlayerInfo.fPawnType = class'B9Characters.B9_Player_mutant_male'; 
	
	for( i=0;i<kNumberOfClasses;i++)
	{
		fPlayerInfo.fDefaultItemClasses[i] = DefaultItemClasses[i];
	}	
}

function class<B9_MenuPDA_Menu> GetNextPlayerMenu()
{
	return class'B9_PDA_SinglePlayerCharacterSelectSahara';
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
	DefaultItemClasses[8]=Class'B9Weapons.heavy_FlameThrower'
	DefaultItemClasses[9]=Class'B9Weapons.ammo_Flamethrower'
	DefaultItemClasses[10]=Class'B9Weapons.ammo_Flamethrower'
	DefaultItemClasses[11]=Class'B9Weapons.ammo_Flamethrower'
	DefaultItemClasses[12]=Class'B9Weapons.ammo_Flamethrower'
	DefaultItemClasses[13]=Class'B9Weapons.ammo_Flamethrower'
	DefaultItemClasses[14]=Class'B9Weapons.rifle_Assault'
	DefaultItemClasses[15]=Class'B9Weapons.ammo_AssaultRifle'
	DefaultItemClasses[16]=Class'B9Weapons.ammo_AssaultRifle'
	DefaultItemClasses[17]=Class'B9Weapons.ammo_AssaultRifle'
	DefaultItemClasses[18]=Class'B9Weapons.ammo_AssaultRifle'
	DefaultItemClasses[22]=Class'B9Weapons.Explosive_SatchelCharge'
	fStrength=65
	fAgility=42
	fDexterity=46
	fConstitution=50
}