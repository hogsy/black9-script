class B9_HQGameReplicationInfo extends GameReplicationInfo;

var int fCountdown;
var bool fCanCountDown;

replication
{
	reliable if ( Role == ROLE_Authority )
		fCountdown,fCanCountDown;
}
