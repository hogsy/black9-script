class WarfareDeathMatch extends DeathMatch;

// Sounds
#exec OBJ LOAD FILE=..\Sounds\Announcer.uax

defaultproperties
{
	LevelRulesClass=Class'LevelGamePlay'
	DefaultEnemyRosterClass="WarClassMisc.WarDMRoster"
	MapListType="WarfareGame.DMMapList"
	GameName="Warfare DeathMatch"
	DeathMessageClass=Class'WarfareDeathMessage'
	MutatorClass="WarfareGame.WarfareMutator"
	GameReplicationInfoClass=Class'WarfareGameReplicationInfo'
}