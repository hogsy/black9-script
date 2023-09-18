class KillerMessagePlus extends LocalMessage;

var localized string YouKilled;
var localized string ScoreString;
var localized string YouKilledTrailer;


static function float GetOffset(int Switch, float YL, float ClipY )
{
//	return (Default.YPos/768.0) * ClipY - YL;
	return ClipY - (YL*3);
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
	if (RelatedPRI_2 == None)
		return "";

	if (RelatedPRI_2.PlayerName != "")
		return Default.YouKilled@RelatedPRI_2.PlayerName@Default.YouKilledTrailer;
}

defaultproperties
{
	YouKilled="You killed"
	ScoreString="Your Score:"
	bIsUnique=true
	bFadeMessage=true
	bCenter=true
	Lifetime=6
	DrawColor=(B=255,G=128,R=0,A=255)
	FontSize=1
}