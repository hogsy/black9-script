//
// OptionalObject is an Inventory
//
class PickupMessagePlus extends LocalMessage;


static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - YL - (64.0/768)*ClipY;
}

defaultproperties
{
	bIsUnique=true
	bFadeMessage=true
	bCenter=true
	FontSize=1
}