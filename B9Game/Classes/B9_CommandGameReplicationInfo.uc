class B9_CommandGameReplicationInfo extends GameReplicationInfo;

var int fCountdown;

replication
{
	reliable if ( Role == ROLE_Authority )
		fCountdown;
}
