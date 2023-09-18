class B9_Beer_TeamRoster extends B9_UnrealTeamInfo;

// What does this do? No time to check - MFH  
#exec TEXTURE IMPORT NAME=I_TeamB FILE=..\botpack\TEXTURES\HUD\TabBluTm.PCX GROUP="Icons" MIPS=OFF MASKED=1
function bool AddToTeam( Controller Other )
{
	local bool bResult;

	bResult = Super.AddToTeam(Other);

	return bResult;
}
function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	local int i;
	log("Belongs On Team"$PawnClass);
	for ( i=0; i<ArrayCount(AllowedTeamMembers); i++ )
	{
		log("Comparing"$AllowedTeamMembers[i]);
		if ( PawnClass == AllowedTeamMembers[i] )
		{
			log("Found Match");
			return true;
		}
	}
	log("Could not Find Match");
	return false;
}
defaultproperties
{
	AllowedTeamMembers[0]=Class'B9Characters.assassin'
	AllowedTeamMembers[1]=Class'B9Characters.B9_player_norm_male'
	AllowedTeamMembers[2]=Class'B9Characters.B9_player_norm_female'
	TeamAlliance=1
	HudTeamColor=(B=64,G=64,R=255,A=255)
	TeamName="BEE"
	TeamColor=(B=255,G=0,R=255,A=255)
	DefaultPlayerClass=Class'B9Characters.B9_player_norm_female'
	TeamIcon=Texture'Icons.I_TeamB'
}