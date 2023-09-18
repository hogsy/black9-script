class COGTeamRoster extends UnrealTeamInfo;

#exec TEXTURE IMPORT NAME=I_TeamB FILE=..\botpack\TEXTURES\HUD\TabBluTm.PCX GROUP="Icons" MIPS=OFF MASKED=1

defaultproperties
{
	Roster=/* Array type was not detected. */
	AllowedTeamMembers[0]=Class'WarClassLight.WarCOGSoldier'
	AllowedTeamMembers[1]=Class'WarClassLight.WarCOGMedic'
	AllowedTeamMembers[2]=Class'WarClassLight.WarCOGEngineer'
	AllowedTeamMembers[3]=Class'WarClassLight.WarCOGSniper'
	AllowedTeamMembers[4]=Class'WarClassHeavy.WarCOGHeavy'
	HudTeamColor=(B=255,G=64,R=64,A=255)
	TeamName="COG"
	TeamColor=(B=255,G=0,R=0,A=255)
	AltTeamColor=(B=200,G=0,R=0,A=255)
	DefaultPlayerClass=Class'WarClassLight.WarCOGSoldier'
	TeamIcon=Texture'Icons.I_TeamB'
}