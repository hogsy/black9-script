class AnnounceAdrenaline extends Info;

var sound AnnounceSound;

function Timer()
{
	if ( PlayerController(Owner) != None )
		PlayerController(Owner).PlayAnnouncement(AnnounceSound,1);
	Destroy();
}

defaultproperties
{
	LifeSpan=30
}