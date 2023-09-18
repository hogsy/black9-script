class BulldogMessage extends LocalMessage;

var localized string	GetInMessage;
var localized string	GetOutMessage;
var localized string	TooManyCarsMessage;
var localized string	FlipCarMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	switch(Switch)
	{
	case 0:
		return Default.GetInMessage;
		break;

	case 1:
		return Default.GetOutMessage;
		break;

	case 2:
		return Default.TooManyCarsMessage;
		break;

	case 3:
		return Default.FlipCarMessage;
		break;
	}
}

defaultproperties
{
	GetInMessage="Press [Use] To Enter Vehicle."
	GetOutMessage="Press [Jump] To Exit Vehicle."
	TooManyCarsMessage="Too Many Cars Already!"
	FlipCarMessage="Press [Use] To Flip Vehicle."
	bIsUnique=true
	bFadeMessage=true
	bBeep=true
	Lifetime=6
	DrawColor=(B=255,G=128,R=128,A=255)
	YPos=0.12
}