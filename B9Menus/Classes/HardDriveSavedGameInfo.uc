// HardDriveSavedGameInfo.uc

class HardDriveSavedGameInfo extends SavedGameInfo
	noexport
	native;

native(1400) final function Init( int n );
native(1401) final function ISetLabel(string newLabel);
native(1402) final function ILoadGame(PlayerController Controller);

function SetLabel(string newLabel)
{
	ISetLabel(newLabel);
}

function LoadGame(PlayerController Controller)
{
	ILoadGame(Controller);
}
