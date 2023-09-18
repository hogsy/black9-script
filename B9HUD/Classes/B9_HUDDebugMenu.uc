// B9_HUDDebugMenu
//
// 
//
// 
//=============================================================================

class B9_HUDDebugMenu extends Actor;

var int fCategory;
var int fSelected;

const kStartX = 0;
const kStartY = 50;
const kMaxCategories = 4;
const kRowHeight = 10;
const kMaxRows = 38;

var protected string fHeadings[kMaxCategories];
var protected int fScroll;

var protected int fColumns[kMaxCategories];

var protected Array<string> fMaps;
var protected Array<string> fWeapons;
var protected Array<string> fSkills;
var protected Array<string> fGear;

var public bool	fVisible;

function PreBeginPlay()
{
	fCategory = 0;
	fSelected = 0;
	
	fColumns[0] = 0;
	fColumns[1] = 80;
	fColumns[2] = 260;
	fColumns[3] = 410;
	
	fHeadings[0] = "Maps";
	fHeadings[1] = "Weapons";
	fHeadings[2] = "Nano Skills";
	fHeadings[3] = "Gear";
	
	// Initialize maps
	
	fMaps[0] = "M02A02.b9";
	fMaps[1] = "M02A03.b9";
	fMaps[2] = "M02A04.b9";
	fMaps[3] = "M02A05.b9";
	fMaps[4] = "M06A01.b9";
	fMaps[5] = "M06A02.b9";
	fMaps[6] = "M06A03.b9";
	fMaps[7] = "M06A04.b9";
	fMaps[8] = "M06A05.b9";
	fMaps[9] = "M06A06.b9";
	fMaps[10] = "M06A07.b9";
	fMaps[11] = "M06A08.b9";
	fMaps[12] = "M06A09.b9";
	fMaps[13] = "M06A10.b9";
	fMaps[14] = "M06A11.b9";
	fMaps[15] = "M06A12.b9";
	fMaps[16] = "M06A13.b9";
	fMaps[17] = "M06A14.b9";
	fMaps[18] = "M09A01.b9";
	fMaps[19] = "M09A02.b9";
	fMaps[20] = "M09A03.b9";
	fMaps[21] = "M09A04.b9";
	fMaps[22] = "M09a05.b9";
	fMaps[23] = "M11A03.b9";
	fMaps[24] = "M11A05.b9";
	fMaps[25] = "M11A07.b9";
	fMaps[26] = "M12A02.b9";
	fMaps[27] = "M12A03.b9";
	fMaps[28] = "M12A04.b9";
	fMaps[29] = "M12A06.b9";
	fMaps[30] = "M12A08.b9";
	fMaps[31] = "M13A01.b9";
	fMaps[32] = "M13A02.b9";
	fMaps[33] = "M13A03.b9";
	fMaps[34] = "M13A04.b9";
	fMaps[35] = "M14A01.b9";
	fMaps[36] = "M14A02.b9";
	fMaps[37] = "M14A03.b9";
	fMaps[38] = "M14A04.b9";
	fMaps[39] = "M14A05.b9";
	fMaps[40] = "M14A06.b9";
	fMaps[41] = "M14A07.b9";
	fMaps[42] = "M14A08.b9";
	fMaps[43] = "MPHQ.b9";
	
	// Initialize Weapons

	fWeapons[0] = "B9Weapons.AI_Intimidator_Gun";
	fWeapons[1] = "B9Weapons.ammo_9mmBullet";
	fWeapons[2] = "B9Weapons.ammo_AssaultRifle";
	fWeapons[3] = "B9Weapons.ammo_CrossbowBolt";
	fWeapons[4] = "B9Weapons.ammo_Flamethrower";
	fWeapons[5] = "B9Weapons.ammo_HeavyRocket";
	fWeapons[6] = "B9Weapons.ammo_HMGBullets";
	fWeapons[7] = "B9Weapons.ammo_LaunchedGrenade";
	fWeapons[8] = "B9Weapons.ammo_MagnumBullet";
	fWeapons[9] = "B9Weapons.ammo_RadFlux";
	fWeapons[10] = "B9Weapons.ammo_RailGun";
	fWeapons[11] = "B9Weapons.ammo_ShotgunShell";
	fWeapons[12] = "B9Weapons.ammo_SilencedPistol";
	fWeapons[13] = "B9Weapons.ammo_SMG";
	fWeapons[14] = "B9Weapons.ammo_SniperRifle";
	fWeapons[15] = "B9Weapons.Ammo_SwarmGun2";
	fWeapons[16] = "B9Weapons.ammo_Tazer";
	fWeapons[17] = "B9Weapons.B9_HandGrenade";
	fWeapons[18] = "B9Weapons.B9_TossedCan";
	fWeapons[19] = "B9Weapons.Tazer";
	fWeapons[20] = "B9Weapons.B9_TossedGrenade";
	fWeapons[21] = "B9Weapons.blackjack";
	fWeapons[22] = "B9Weapons.BlitDagger";
	fWeapons[23] = "B9Weapons.BlitSword";
	fWeapons[24] = "B9Weapons.Crossbow";
	fWeapons[25] = "B9Weapons.dagger";
	fWeapons[26] = "B9Weapons.Explosive_DetPack";
	fWeapons[27] = "B9Weapons.Explosive_Gren_Flare";
	fWeapons[28] = "B9Weapons.Explosive_Gren_Flashbang";
	fWeapons[29] = "B9Weapons.Explosive_Gren_Frag";
	fWeapons[30] = "B9Weapons.Explosive_Gren_MIRV";
	fWeapons[31] = "B9Weapons.Explosive_Mine_Pressure";
	fWeapons[32] = "B9Weapons.Explosive_Mine_Proximity";
	fWeapons[33] = "B9Weapons.Explosive_Mine_Trip";
	fWeapons[34] = "B9Weapons.Explosive_SatchelCharge";
	fWeapons[35] = "B9Weapons.GrapplingHook";
	fWeapons[36] = "B9Weapons.HandToHand";
	fWeapons[37] = "B9Weapons.heavy_FlameThrower";
	fWeapons[38] = "B9Weapons.heavy_GrenadeLauncher";
	fWeapons[39] = "B9Weapons.heavy_HeavyMachineGun";
	fWeapons[40] = "B9Weapons.heavy_RadFlux";
	fWeapons[41] = "B9Weapons.heavy_RailGun";
	fWeapons[42] = "B9Weapons.heavy_RocketLauncher";
	fWeapons[43] = "B9Weapons.katana";
	fWeapons[44] = "B9Weapons.pistol_9mm";
	fWeapons[45] = "B9Weapons.pistol_Magnum";
	fWeapons[46] = "B9Weapons.pistol_SawedOffShotgun";
	fWeapons[47] = "B9Weapons.pistol_Silenced";
	fWeapons[48] = "B9Weapons.pistol_SMG";
	fWeapons[49] = "B9Weapons.pistol_Tazer";
	fWeapons[50] = "B9Weapons.rifle_Assault";
	fWeapons[51] = "B9Weapons.rifle_DB_shotgun";
	fWeapons[52] = "B9Weapons.rifle_MarineAssault";
	fWeapons[53] = "B9Weapons.rifle_Shotgun";
	fWeapons[54] = "B9Weapons.rifle_sniper";
	fWeapons[55] = "B9Weapons.RocketExplosion";
	fWeapons[56] = "B9Weapons.SwarmGun";

	// Initialize Skills
	
	fSkills[0] = "B9NanoSkills.BaseAttackSkill";
	fSkills[1] = "B9NanoSkills.DummyMod";
	fSkills[2] = "B9NanoSkills.DummySkill";
	fSkills[3] = "B9NanoSkills.skill_BlinkSpeed";
	fSkills[4] = "B9NanoSkills.skill_CamJam";
	fSkills[5] = "B9NanoSkills.skill_Defocus";
	fSkills[6] = "B9NanoSkills.skill_ECM";
	fSkills[7] = "B9NanoSkills.skill_FireArmsTargeting";
	fSkills[8] = "B9NanoSkills.skill_Fireball";
	fSkills[9] = "B9NanoSkills.skill_Fireball_Projectile";
	fSkills[10] = "B9NanoSkills.skill_FireFist";
	fSkills[11] = "B9NanoSkills.skill_FireShield";
	fSkills[12] = "B9NanoSkills.skill_Hacking";
	fSkills[13] = "B9NanoSkills.skill_Healing";
	fSkills[14] = "B9NanoSkills.skill_HeavenBlast";
	fSkills[15] = "B9NanoSkills.skill_HeavyWeaponsTargeting";
	fSkills[16] = "B9NanoSkills.skill_HydroCloak";
	fSkills[17] = "B9NanoSkills.skill_HydroShock";
	fSkills[18] = "B9NanoSkills.skill_IceFist";
	fSkills[19] = "B9NanoSkills.skill_IceShards";
	fSkills[20] = "B9NanoSkills.skill_Jumping";
	fSkills[21] = "B9NanoSkills.skill_meleeCombat";
	fSkills[22] = "B9NanoSkills.skill_OpticCloak";
	fSkills[23] = "B9NanoSkills.skill_RockFist";
	fSkills[24] = "B9NanoSkills.skill_RockGrenade";
	fSkills[25] = "B9NanoSkills.skill_RockShards";
	fSkills[26] = "B9NanoSkills.skill_urbanTracking";
	fSkills[27] = "B9NanoSkills.skill_UVCloak";
	
	// Initialize Items
	
	fGear[0] = "B9Gear.biomed_MedKit";
	fGear[1] = "B9Gear.biomed_MedKit_holo";
	fGear[2] = "B9Gear.biomed_MedKit_pickup";
	fGear[3] = "B9Gear.DummyGear";
	fGear[4] = "B9Gear.DummyGear_Holo";
	fGear[5] = "B9Gear.DummyGear_Pickup";
	fGear[6] = "B9Gear.LogicBomb";
	fGear[7] = "B9Gear.LogicBomb_Pickup";
	fGear[8] = "B9Gear.MedKit_Gear";
	fGear[9] = "B9Gear.Medkit_Gear_Holo";
	fGear[10] = "B9Gear.Medkit_Gear_Pickup";
	fGear[11] = "B9Gear.NightScope";
	fGear[12] = "B9Gear.NightScope_Holo";
	fGear[13] = "B9Gear.NightScope_Pickup";
	fGear[14] = "B9Gear.PDA";

}

function AcquireInventory( string ClassName )
{
	local class<actor> NewClass;
	local Inventory item;
	local B9_HUD myHUD;

	log( "Fabricate " $ ClassName );
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		item = Inventory( Spawn( NewClass ) );
	}
	
	myHUD		= B9_HUD( Owner );	
	if ( myHUD != None )
	{
		if ( myHUD.PlayerOwner != None )
		{
			if ( myHUD.PlayerOwner.Pawn != None )
			{
				myHUD.PlayerOwner.Pawn.AddInventory(item);
			}
		}
	}
}

function Select( )
{
	local B9_HUD			myHUD;
	
	switch ( fCategory )
	{
	case 0:
		myHUD		= B9_HUD( Owner );
	
		if ( myHUD != None )
		{
			if ( myHUD.PlayerOwner != None )
			{
				myHUD.PlayerOwner.ClientTravel( fMaps[fSelected], TRAVEL_Absolute, true );
			}
		}
		break;
	case 1:
		AcquireInventory( fWeapons[fSelected] );		
		break;
	case 2:
		log( "No Body Mods" );
		break;
	case 3:
		AcquireInventory( fSkills[fSelected] );
		break;
	case 4:
		AcquireInventory( fGear[fSelected] );
		break;
	}
}

function NextCategory()
{
	local int length;
	
	fCategory++;
	if ( fCategory >= kMaxCategories )
	{
		fCategory = 0;
	}

	switch ( fCategory )
	{
	case 0:
		length = fMaps.Length;
		break;
	case 1:
		length = fWeapons.Length;
		break;
	case 2:
		length = fSkills.Length;
		break;
	case 3:
		length = fGear.Length;
		break;
	}
	
	if ( fSelected >= length )
	{
		fSelected = 0;
	}
	
	if ( fSelected > fScroll + kMaxRows - 1 )
	{
		fScroll = fSelected - kMaxRows;
	}
	else if ( fSelected < fScroll )
	{
		fScroll = fSelected;
	}
}

function PreviousCategory()
{
	local int length;
	
	if ( kMaxCategories < 1 )
	{
		return;
	}
	
	fCategory--;
	if ( fCategory < 0 )
	{
		fCategory = kMaxCategories - 1;
	}

	switch ( fCategory )
	{
	case 0:
		length = fMaps.Length;
		break;
	case 1:
		length = fWeapons.Length;
		break;
	case 2:
		length = fSkills.Length;
		break;
	case 3:
		length = fGear.Length;
		break;
	}
	
	if ( fSelected >= length )
	{
		fSelected = 0;
	}
	
	if ( fSelected > fScroll + kMaxRows - 1 )
	{
		fScroll = fSelected - kMaxRows;
	}
	else if ( fSelected < fScroll )
	{
		fScroll = fSelected;
	}
}

function NextItem()
{
	local int length;
	fSelected++;
	switch ( fCategory )
	{
	case 0:
		length = fMaps.Length;
		break;
	case 1:
		length = fWeapons.Length;
		break;
	case 2:
		length = fSkills.Length;
		break;
	case 3:
		length = fGear.Length;
		break;
	}
	
	if ( fSelected >= length )
	{
		fSelected = 0;
	}
	
	if ( fSelected > fScroll + kMaxRows - 1 )
	{
		fScroll = fSelected - kMaxRows;
	}
	else if ( fSelected < fScroll )
	{
		fScroll = fSelected;
	}
}

function PreviousItem()
{
	local int length;
	fSelected--;
	switch ( fCategory )
	{
	case 0:
		length = fMaps.Length;
		break;
	case 1:
		length = fWeapons.Length;
		break;
	case 2:
		length = fSkills.Length;
		break;
	case 3:
		length = fGear.Length;
		break;
	}
	
	if ( fSelected < 0 )
	{
		fSelected = length - 1;
	}

	if ( fSelected > fScroll + kMaxRows - 1 )
	{
		fScroll = fSelected - kMaxRows;
	}
	else if ( fSelected < fScroll )
	{
		fScroll = fSelected;
	}
}

function Draw( Canvas canvas )
{
	local int i, r, c;
	
	if ( !fVisible )
	{
		return;
	}
	
	Canvas.Style = ERenderStyle.STY_Alpha;
	
	for ( c = 0; c < kMaxCategories; c++ )
	{		
		Canvas.SetDrawColor( 255, 128, 128 );
		canvas.SetPos( kStartX + fColumns[c], kStartY );
		Canvas.DrawText( fHeadings[c] );		
		switch ( c )
		{
		case 0:
			r = 0;
			for ( i = fScroll; i < fMaps.Length && r < kMaxRows; i++ )
			{
				if ( c == fCategory && i == fSelected )
				{
					Canvas.SetDrawColor( 128, 128, 128 );
				}
				else
				{
					Canvas.SetDrawColor( 255, 255, 255 );
				}
				Canvas.SetPos( kStartX + fColumns[c], kStartY + ( r + 1 ) * kRowHeight );
				Canvas.DrawText( fMaps[i] );
				r++;
			}
			break;
		case 1:
			r = 0;
			for ( i = fScroll; i < fWeapons.Length && r < kMaxRows; i++ )
			{
				if ( c == fCategory && i == fSelected )
				{
					Canvas.SetDrawColor( 128, 128, 128 );
				}
				else
				{
					Canvas.SetDrawColor( 255, 255, 255 );
				}
				Canvas.SetPos( kStartX + fColumns[c], kStartY + ( r + 1 ) * kRowHeight );
				Canvas.DrawText( fWeapons[i] );
				r++;
			}
			break;
		case 2:
			r = 0;
			for ( i = fScroll; i < fSkills.Length && r < kMaxRows; i++ )
			{
				if ( c == fCategory && i == fSelected )
				{
					Canvas.SetDrawColor( 128, 128, 128 );
				}
				else
				{
					Canvas.SetDrawColor( 255, 255, 255 );
				}
				Canvas.SetPos( kStartX + fColumns[c], kStartY + ( r + 1 ) * kRowHeight );
				Canvas.DrawText( fSkills[i] );
				r++;
			}
			break;
		case 3:
			r = 0;
			for ( i = fScroll; i < fGear.Length && r < kMaxRows; i++ )
			{
				if ( c == fCategory && i == fSelected )
				{
					Canvas.SetDrawColor( 128, 128, 128 );
				}
				else
				{
					Canvas.SetDrawColor( 255, 255, 255 );
				}
				Canvas.SetPos( kStartX + fColumns[c], kStartY + ( r + 1 ) * kRowHeight );
				Canvas.DrawText( fGear[i] );
				r++;
			}
			break;
		}
	}
}

defaultproperties
{
	bHidden=true
}