//=============================================================================
// B9MP_OnlineCore.
//
//	Primary parent class for Multiplayer classes.  Encapsulates the "definitions"
//	for the classes.
//
//
//=============================================================================
class B9MP_OnlineCore extends Actor
	native;


const kMaxCharacterLevel	= 3;
const kMaxCharactersInGame	= 64;
const kMaxSortFields		= 4;


enum eResult
{
	kSuccess,
	kFailure
};

enum eGameType
{
	kGameType_All,
	kGameType_CaptureHold,
	kGameType_IlluminatiDuel,
	kGameType_CoOp,
};

enum eSociety
{
	kSociety_Unknown,
	kSociety_Genesis,
	kSociety_TeaDrinkingSociety,
	kSociety_Zubrin,
};

enum eServerSort
{
	kServerSort_Name,
	kServerSort_MapName,
	kServerSort_GameType,
	kServerSort_Dedicated,
	kServerSort_Ranked,
	kServerSort_Private,
	kServerSort_CurrentPlayers,
	kServerSort_MinPlayers,
	kServerSort_MaxPlayers,
	kServerSort_MinCharacterLevel,
	kServerSort_MaxCharacterLevel,
	kServerSort_Ping,
	kServerSort_AveragePlayerSkill,
	kServerSort_WinningTeam,
	kServerSort_LosingTeam,
	kServerSort_NeedingPlayer,
};
