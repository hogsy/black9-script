class GeistTeamRoster extends UnrealTeamInfo;

#exec TEXTURE IMPORT NAME=I_TeamR FILE=..\botpack\TEXTURES\HUD\TabRedTm.PCX GROUP="Icons" MIPS=OFF MASKED=1

defaultproperties
{
	begin object name=GeistRosterEntryDefault class=RosterEntry
	// Object Offset:0x0005AC51
	PawnClass=Class'WarClassLight.WarGeistSoldier'
	PlayerName="Grugle"
	Orders=1
object end
// Reference: RosterEntry'GeistTeamRoster.GeistRosterEntryDefault'
DefaultRosterEntry=GeistRosterEntryDefault
	Roster=/* Array type was not detected. */
	AllowedTeamMembers[0]=Class'WarClassLight.WarGeistSoldier'
	AllowedTeamMembers[1]=Class'WarClassLight.WarGeistMedic'
	AllowedTeamMembers[2]=Class'WarClassLight.WarGeistEngineer'
	AllowedTeamMembers[3]=Class'WarClassLight.WarGeistSniper'
	AllowedTeamMembers[4]=Class'WarClassHeavy.WarGeistHeavy'
	TeamAlliance=1
	HudTeamColor=(B=0,G=0,R=255,A=255)
	TeamName="Geist"
	DefaultPlayerClass=Class'WarClassLight.WarGeistSoldier'
	TeamIcon=Texture'Icons.I_TeamR'
}