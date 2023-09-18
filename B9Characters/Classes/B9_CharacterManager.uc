//=============================================================================
// B9_CharacterManager
//
// Manages the player's collection of characters.
//
// 
//=============================================================================

class B9_CharacterManager extends Controller
	native
	config(Characters);



// MUST MATCH ABOVE!
struct CharacterDefinition
{
	var String		fName;
	var String		fClassName;
	var String		fCharacter;
};


var config CharacterDefinition fCharacters[ 6 ];
var config int fCharacterCount;
var config int fMaxCharacters;

var int fCurrentSelection;


native(2120) static final function string StorePlayerToString( Pawn playerPawn );
native(2121) static final function RestorePlayerFromString( string storedString, Level currentLevel, Player currentPlayer, Pawn playerPawn );
native(2122) static final function string StorePlayerToEncodedString( Pawn playerPawn );
native(2123) static final function string RestorePlayerTravelStringFromEncodedString( String encodedString );


function Save()
{
	SaveConfig();
}


function bool AddCharacter( String playerName, Pawn playerPawn, class<Pawn> playerClass )
{
	if ( fCharacterCount >= fMaxCharacters )
	{
		log( self@ " No more room for character storage" );
		return false;
	}

	fCharacters[ fCharacterCount ].fName	  = playerName;
	fCharacters[ fCharacterCount ].fClassName = ""$playerClass;
	fCharacters[ fCharacterCount ].fCharacter = StorePlayerToString( playerPawn );
	fCharacterCount++;

	Save();

	return true;
}


function GetCharacter( int offset, Player currentPlayer )
{
	if ( offset >= fCharacterCount )
	{
		log( self@ " ERROR: asked for a character that does not exist" );
		return;
	}

	RestorePlayerFromString( fCharacters[ offset ].fCharacter, currentPlayer.Actor.XLevel, currentPlayer, currentPlayer.Actor.Pawn );
}


function DeleteCharacter( int offset )
{
	local int i;

	if ( offset < fCharacterCount )
	{
		for ( i = offset; i < fCharacterCount; i++ )
		{
			fCharacters[ i ].fName		= fCharacters[ i + 1 ].fName;
			fCharacters[ i ].fClassName = fCharacters[ i + 1 ].fClassName;
			fCharacters[ i ].fCharacter = fCharacters[ i + 1 ].fCharacter;
		}

		fCharacterCount--;

		fCharacters[ fCharacterCount ].fName	  = "";
		fCharacters[ fCharacterCount ].fClassName = "";
		fCharacters[ fCharacterCount ].fCharacter = "";

		Save();
	}
	else
	{
		log( self@ " Asked to delete a character not in storage" );
	}
}


function SetSelection( int selection )
{
	fCurrentSelection = selection;
}


function GetSelectedCharacter( Player currentPlayer )
{
	GetCharacter( fCurrentSelection, currentPlayer );
}


function string GetSelectedClass()
{
	return fCharacters[ fCurrentSelection ].fClassName;
}



defaultproperties
{
	fCharacters[0]=(FName="Sahara",fClassName="B9Characters.B9_player_norm_female",fCharacter="Class=B9Characters.B9_player_norm_female Name=B9_player_norm_female1	{	}	Class=B9NanoSkills.skill_Hacking Name=skill_Hacking0	{	}	Class=B9NanoSkills.skill_Jumping Name=skill_Jumping0	{	}	Class=B9NanoSkills.skill_meleeCombat Name=skill_meleeCombat0	{	}	Class=B9NanoSkills.skill_FireArmsTargeting Name=skill_FireArmsTargeting0	{	}	Class=B9NanoSkills.skill_HeavyWeaponsTargeting Name=skill_HeavyWeaponsTargeting0	{	}	Class=B9NanoSkills.skill_urbanTracking Name=skill_urbanTracking0	{	}	Class=B9Weapons.HandToHand Name=HandToHand0	{	}	Class=B9Weapons.HandToHand_Ammunition Name=HandToHand_Ammunition0	{	}	Class=B9Gear.PDA Name=PDA0	{	}	Class=B9Weapons.pistol_9mm Name=pistol_9mm0	{	}	Class=B9Weapons.ammo_9mmBullet Name=ammo_9mmBullet0	{	}	Class=B9Weapons.ammo_9mmBullet Name=ammo_9mmBullet1	{	}	")
	fCharacters[1]=(FName="Jake",fClassName="B9Characters.B9_player_norm_male",fCharacter="Class=B9Characters.B9_player_norm_male Name=B9_player_norm_male0	{	}	Class=B9NanoSkills.skill_Hacking Name=skill_Hacking0	{	}	Class=B9NanoSkills.skill_Jumping Name=skill_Jumping0	{	}	Class=B9NanoSkills.skill_meleeCombat Name=skill_meleeCombat0	{	}	Class=B9NanoSkills.skill_FireArmsTargeting Name=skill_FireArmsTargeting0	{	}	Class=B9NanoSkills.skill_HeavyWeaponsTargeting Name=skill_HeavyWeaponsTargeting0	{	}	Class=B9NanoSkills.skill_urbanTracking Name=skill_urbanTracking0	{	}	Class=B9Weapons.HandToHand Name=HandToHand0	{	}	Class=B9Weapons.HandToHand_Ammunition Name=HandToHand_Ammunition0	{	}	Class=B9Gear.PDA Name=PDA0	{	}	Class=B9Weapons.rifle_Assault Name=rifle_Assault0	{	}	Class=B9Weapons.ammo_AssaultRifle Name=ammo_AssaultRifle0	{	}	Class=B9Weapons.ammo_AssaultRifle Name=ammo_AssaultRifle1	{	}	")
	fCharacters[2]=(FName="Amanda",fClassName="B9Characters.B9_player_norm_female",fCharacter="Class=B9Characters.B9_player_norm_female Name=B9_player_norm_female1	{	}	Class=B9NanoSkills.skill_Hacking Name=skill_Hacking0	{	}	Class=B9NanoSkills.skill_Jumping Name=skill_Jumping0	{	}	Class=B9NanoSkills.skill_meleeCombat Name=skill_meleeCombat0	{	}	Class=B9NanoSkills.skill_FireArmsTargeting Name=skill_FireArmsTargeting0	{	}	Class=B9NanoSkills.skill_HeavyWeaponsTargeting Name=skill_HeavyWeaponsTargeting0	{	}	Class=B9NanoSkills.skill_urbanTracking Name=skill_urbanTracking0	{	}	Class=B9Weapons.HandToHand Name=HandToHand0	{	}	Class=B9Weapons.HandToHand_Ammunition Name=HandToHand_Ammunition0	{	}	Class=B9Gear.PDA Name=PDA0	{	}	Class=B9Weapons.heavy_FlameThrower Name=heavy_FlameThrower0	{	}	Class=B9Weapons.ammo_Flamethrower Name=ammo_Flamethrower0	{	}	Class=B9Weapons.ammo_Flamethrower Name=ammo_Flamethrower1	{	}	")
	fCharacters[3]=(FName="Buck",fClassName="B9Characters.B9_player_norm_male",fCharacter="Class=B9Characters.B9_player_norm_male Name=B9_player_norm_male0	{	}	Class=B9NanoSkills.skill_Hacking Name=skill_Hacking0	{	}	Class=B9NanoSkills.skill_Jumping Name=skill_Jumping0	{	}	Class=B9NanoSkills.skill_meleeCombat Name=skill_meleeCombat0	{	}	Class=B9NanoSkills.skill_FireArmsTargeting Name=skill_FireArmsTargeting0	{	}	Class=B9NanoSkills.skill_HeavyWeaponsTargeting Name=skill_HeavyWeaponsTargeting0	{	}	Class=B9NanoSkills.skill_urbanTracking Name=skill_urbanTracking0	{	}	Class=B9Weapons.HandToHand Name=HandToHand0	{	}	Class=B9Weapons.HandToHand_Ammunition Name=HandToHand_Ammunition0	{	}	Class=B9Gear.PDA Name=PDA0	{	}	Class=B9Weapons.rifle_Shotgun Name=rifle_Shotgun0	{	}	Class=B9Weapons.ammo_ShotgunShell Name=ammo_ShotgunShell0	{	}	Class=B9Weapons.ammo_ShotgunShell Name=ammo_ShotgunShell1	{	}	")
	fCharacters[4]=(FName="Clare",fClassName="B9Characters.B9_player_norm_female",fCharacter="Class=B9Characters.B9_player_norm_female Name=B9_player_norm_female1	{	}	Class=B9NanoSkills.skill_Hacking Name=skill_Hacking0	{	}	Class=B9NanoSkills.skill_Jumping Name=skill_Jumping0	{	}	Class=B9NanoSkills.skill_meleeCombat Name=skill_meleeCombat0	{	}	Class=B9NanoSkills.skill_FireArmsTargeting Name=skill_FireArmsTargeting0	{	}	Class=B9NanoSkills.skill_HeavyWeaponsTargeting Name=skill_HeavyWeaponsTargeting0	{	}	Class=B9NanoSkills.skill_urbanTracking Name=skill_urbanTracking0	{	}	Class=B9Weapons.HandToHand Name=HandToHand0	{	}	Class=B9Weapons.HandToHand_Ammunition Name=HandToHand_Ammunition0	{	}	Class=B9Gear.PDA Name=PDA0	{	}	Class=B9Weapons.pistol_Magnum Name=pistol_Magnum0	{	}	Class=B9Weapons.ammo_MagnumBullet Name=ammo_MagnumBullet0	{	}	Class=B9Weapons.ammo_MagnumBullet Name=ammo_MagnumBullet1	{	}	")
	fCharacters[5]=(FName="Slate",fClassName="B9Characters.B9_player_norm_male",fCharacter="Class=B9Characters.B9_player_norm_male Name=B9_player_norm_male0	{	}	Class=B9NanoSkills.skill_Hacking Name=skill_Hacking0	{	}	Class=B9NanoSkills.skill_Jumping Name=skill_Jumping0	{	}	Class=B9NanoSkills.skill_meleeCombat Name=skill_meleeCombat0	{	}	Class=B9NanoSkills.skill_FireArmsTargeting Name=skill_FireArmsTargeting0	{	}	Class=B9NanoSkills.skill_HeavyWeaponsTargeting Name=skill_HeavyWeaponsTargeting0	{	}	Class=B9NanoSkills.skill_urbanTracking Name=skill_urbanTracking0	{	}	Class=B9Weapons.HandToHand Name=HandToHand0	{	}	Class=B9Weapons.HandToHand_Ammunition Name=HandToHand_Ammunition0	{	}	Class=B9Gear.PDA Name=PDA0	{	}	Class=B9Weapons.pistol_9mm Name=pistol_9mm0	{	}	Class=B9Weapons.ammo_9mmBullet Name=ammo_9mmBullet0	{	}	Class=B9Weapons.ammo_9mmBullet Name=ammo_9mmBullet1	{	}	")
	fCharacterCount=6
	fMaxCharacters=6
}