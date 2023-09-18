//=============================================================================
// CTFBase.
//=============================================================================
class CTFBase extends GameObjective
	abstract;

var() Sound TakenSound;
var CTFFlag myFlag;
var class<CTFFlag> FlagType;

function BeginPlay()
{
	Super.BeginPlay();
	bHidden = false;

	myFlag = Spawn(FlagType, self);

	if (myFlag==None)
	{
		warn(Self$" could not spawn flag of type '"$FlagType$"' at "$location);
		return;
	}
	else
	{
		myFlag.HomeBase = self;
		myFlag.TeamNum = DefenderTeamIndex;
	}
}

function PlayAlarm()
{
	SetTimer(5.0, false);
	AmbientSound = TakenSound;
}

function Timer()
{
	AmbientSound = None;
}

defaultproperties
{
	DrawType=2
	bStatic=false
	bAlwaysRelevant=true
	NetUpdateFrequency=8
	DrawScale=1.3
	SoundRadius=255
	SoundVolume=255
	CollisionRadius=60
	CollisionHeight=60
	bCollideActors=true
}