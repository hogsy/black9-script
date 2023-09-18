class CriticalEventPlus extends LocalMessage;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY;
}

defaultproperties
{
	bIsUnique=true
	bFadeMessage=true
	DrawColor=(B=255,G=160,R=0,A=255)
	FontSize=1
}