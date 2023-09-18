class TimerMessage extends CriticalEventPlus;

#exec OBJ LOAD File=AnnouncerMain.uax

var() Sound CountDownSounds[10];
var() localized string CountDownTrailer;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject 
    )
{
    return Switch$default.CountDownTrailer;
}

static function ClientReceive( 
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    if ( (Switch > 0) && (Switch < 11) && (P. GameReplicationInfo.Winner == None)
		&& ((P.GameReplicationInfo.RemainingTime > 10) || (P.GameReplicationInfo.RemainingTime == 0)) )
        P.PlayAnnouncement(default.CountDownSounds[Switch-1],1);
}

defaultproperties
{
	CountDownSounds[0]=Sound'AnnouncerMain.One'
	CountDownSounds[1]=Sound'AnnouncerMain.Two'
	CountDownSounds[2]=Sound'AnnouncerMain.Three'
	CountDownSounds[3]=Sound'AnnouncerMain.Four'
	CountDownSounds[4]=Sound'AnnouncerMain.Five'
	CountDownSounds[5]=Sound'AnnouncerMain.Six'
	CountDownSounds[6]=Sound'AnnouncerMain.Seven'
	CountDownSounds[7]=Sound'AnnouncerMain.Eight'
	CountDownSounds[8]=Sound'AnnouncerMain.Nine'
	CountDownSounds[9]=Sound'AnnouncerMain.Ten'
	CountDownTrailer="..."
	bIsConsoleMessage=false
	Lifetime=1
	DrawColor=(B=0,G=255,R=255,A=255)
	YPos=0.12
	FontSize=0
}