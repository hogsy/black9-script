class VictimMessage extends LocalMessage;

var localized string YouWereKilledBy, KilledByTrailer;

static function float GetOffset(int Switch, float YL, float ClipY )
{
//	return (Default.YPos/768.0) * ClipY + 2*YL;
	return ClipY - (YL*2);

}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if (RelatedPRI_1 == None)
		return "";

	if (RelatedPRI_1.PlayerName != "")
		return Default.YouWereKilledBy@RelatedPRI_1.PlayerName$Default.KilledByTrailer;
}

defaultproperties
{
	YouWereKilledBy="You were killed by"
	KilledByTrailer="!"
	bIsUnique=true
	bFadeMessage=true
	bCenter=true
	Lifetime=6
	DrawColor=(B=0,G=0,R=255,A=255)
	FontSize=1
}