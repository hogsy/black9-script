// GameSaveStorage.uc

class GameSaveStorage extends Object
	abstract
	noexport
	native;

var int Slot;
var int Internal1;

function string GetLabel();
function int GetStatus();
function int GetGameSaveCount();
function SavedGameInfo GetGameSaveInfo(int n);
function int GetMaximumCapacity();		// space available if device wase empty
function int GetAvailableCapacity();	// space available for new saves
function int GetGameSaveUsage();		// the space we are using for saves
function int ConvertAmountToPlatformUnits(int n);
function int ConvertAmountFromPlatformUnits(int n);
function string GetErrorMessage(int n);

function SaveGame(PlayerController Controller, SavedGameInfo overwriteGame);
