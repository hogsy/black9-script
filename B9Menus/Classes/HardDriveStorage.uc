// HardDriveStorage.uc

class HardDriveStorage extends GameSaveStorage
	noexport
	native;

native(1200) final function Init( int slot );
native(1201) final function string IGetLabel();
native(1202) final function int IGetStatus();
native(1203) final function int IGetGameSaveCount();
native(1204) final function int IGetMaximumCapacity();
native(1205) final function int IGetAvailableCapacity();
native(1206) final function int IGetGameSaveUsage();
native(1207) final function int IConvertAmountToPlatformUnits(int n);
native(1208) final function int IConvertAmountFromPlatformUnits(int n);
native(1209) final function string IGetErrorMessage(int n);
native(1210) final function ISaveGame(PlayerController Controller, SavedGameInfo overwriteGame);

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
	local HardDriveSavedGameInfo info;
	
	if (n < 0 || n >= GetGameSaveCount())
		return None;

	info = new(None) class'HardDriveSavedGameInfo';
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
