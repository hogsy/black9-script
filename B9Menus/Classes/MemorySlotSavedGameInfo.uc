// MemorySlotSavedGameInfo.uc

class MemorySlotSavedGameInfo extends SavedGameInfo
	noexport
	native;

native(1300) final function Init( int n );
native(1301) final function ISetLabel(string newLabel);
native(1302) final function ILoadGame(PlayerController Controller);

function SetLabel(string newLabel)
{
	ISetLabel(newLabel);
}

function LoadGame(PlayerController Controller)
{
	ILoadGame(Controller);
}
