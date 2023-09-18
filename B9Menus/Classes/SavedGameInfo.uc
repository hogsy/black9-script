// SavedGameInfo.uc

class SavedGameInfo extends Object
	abstract
	noexport
	native;

var GameSaveStorage Storage;
var const string SaveTag;
var const string Label;
var const int TimeStamp;
var const string MapName;

var const string CharacterName;
var const int CharacterStrength;
var const int CharacterAgility;
var const int CharacterDexterity;
var const int CharacterConstitution;
var const int CharacterCurHealth;
var const int CharacterFullHealth;
var const int CharacterCurFocus;
var const int CharacterFullFocus;
var const int CharacterCash;
var const string MissionDescription;
var const string SaveDate;
var const Texture ScreenShot;

function SetLabel(string newLabel);
function LoadGame(PlayerController Controller);
