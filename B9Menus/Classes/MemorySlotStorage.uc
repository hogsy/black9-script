// MemorySlotStorage.uc

class MemorySlotStorage extends GameSaveStorage
	noexport
	native;
 
native(1100) final function Init( int slot );
native(1101) final function string IGetLabel();
native(1102) final function int IGetStatus();
native(1103) final function int IGetGameSaveCount();
native(1104) final function int IGetMaximumCapacity();
native(1105) final function int IGetAvailableCapacity();
native(1106) final function int IGetGameSaveUsage();
native(1107) final function int IConvertAmountToPlatformUnits(int n);
native(1108) final function int IConvertAmountFromPlatformUnits(int n);
native(1109) final function string IGetErrorMessage(int n);
native(1110) final function ISaveGame(PlayerController Controller, SavedGameInfo overwriteGame);

function string GetLabel()
{
	return IGetLabel();
}

function int GetStatus()
{
	return IGetStatus();
}

function int GetGameSaveCount()
{
	return IGetGameSaveCount();
}

function SavedGameInfo GetGameSaveInfo(int n)
{
	local MemorySlotSavedGameInfo info;
	
	if (n < 0 || n >= GetGameSaveCount())
		return None;

	info = new(None) class'MemorySlotSavedGameInfo';
	info.Storage = self;
	info.Init(n);
	return info;
}

function int GetMaximumCapacity()
{
	return IGetMaximumCapacity();
}

function int GetAvailableCapacity()
{
	return IGetAvailableCapacity();
}

function int GetGameSaveUsage()
{
	return IGetGameSaveUsage();
}

function int ConvertAmountToPlatformUnits(int n)
{
	return IConvertAmountToPlatformUnits(n);
}

function int ConvertAmountFromPlatformUnits(int n)
{
	return IConvertAmountFromPlatformUnits(n);
}

function string GetErrorMessage(int n)
{
	return IGetErrorMessage(n);
}

function SaveGame(PlayerController Controller, SavedGameInfo overwriteGame)
{
	ISaveGame(Controller, overwriteGame);
}
