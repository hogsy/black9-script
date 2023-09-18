class WarfareCTFGame extends CTFGame;

#exec AUDIO IMPORT FILE="..\botpack\Sounds\CTF\RockOnDude.wav" NAME="CaptureSound" GROUP="CTF"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\CTF\ctf9.wav" NAME="CaptureSound2" GROUP="CTF"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\CTF\ctf10.wav" NAME="CaptureSound3" GROUP="CTF"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\CTF\returnf1.wav" NAME="ReturnSound" GROUP="CTF"

defaultproperties
{
	CaptureSound[0]=Sound'CTF.CaptureSound2'
	CaptureSound[1]=Sound'CTF.CaptureSound3'
	LevelRulesClass=Class'LevelGamePlay'
	ScoreBoardType="WarfareGame.CTFScoreboard"
	HUDType="WarfareGame.CTFHUD"
	MapListType="WarfareGame.CTFmaplist"
	DeathMessageClass=Class'WarfareDeathMessage'
	MutatorClass="WarfareGame.WarfareMutator"
}