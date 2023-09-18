class PlayerNameMessage extends LocalMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return RelatedPRI_1.PlayerName;
}

defaultproperties
{
	bIsUnique=true
	bIsConsoleMessage=false
	bFadeMessage=true
	Lifetime=2
	DrawColor=(B=0,G=255,R=0,A=255)
	YPos=0.55
}