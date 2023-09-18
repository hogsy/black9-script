class CTFHUDMessage extends LocalMessage;

// CTF Messages
//
// Switch 0: You have the flag message.
//
// Switch 1: Enemy has the flag message.

var(Message) localized string YouHaveFlagString;
var(Message) localized string EnemyHasFlagString;
var(Message) color RedColor, YellowColor;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	if (Switch == 0)
		return Default.YellowColor;
	else
		return Default.RedColor;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == 0)
	    return Default.YouHaveFlagString;
    else
	    return Default.EnemyHasFlagString;
}

defaultproperties
{
	YouHaveFlagString="You have the flag, return to base!"
	EnemyHasFlagString="The enemy has your flag, recover it!"
	RedColor=(B=0,G=0,R=255,A=255)
	YellowColor=(B=0,G=255,R=255,A=255)
	bIsConsoleMessage=false
	bFadeMessage=true
	Lifetime=1
	DrawColor=(B=255,G=160,R=0,A=255)
	YPos=0.12
	FontSize=1
}