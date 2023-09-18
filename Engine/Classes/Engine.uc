//=============================================================================
// Engine: The base class of the global application object classes.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Engine extends Subsystem
	native
	noexport
	transient;

/////////////
// SB, Taldren, 3/28/03
// Added last-minute support for "demo matinee mode"
//
var bool					fInDemoMode;
var float					fLastInputTime;
var(Settings) config bool	UseTaldrenDemoMode;

//
// SB, end changes
//////////////////////

// Drivers.
var(Drivers) config class<AudioSubsystem> AudioDevice;
var(Drivers) config class<Interaction>    Console;				// The default system console
var(Drivers) config class<Interaction>	  DefaultMenu;			// The default system menu 
var(Drivers) config class<Interaction>	  DefaultPlayerMenu;	// The default player menu
var(Drivers) config class<NetDriver>      NetworkDevice;
var(Drivers) config class<Language>       Language;

// Variables.
var primitive Cylinder;
var const client Client;
var const audiosubsystem Audio;
var const renderdevice GRenDev;

// Stats.
var int bShowFrameRate;
var int bShowRenderStats;
var int bShowHardwareStats;
var int bShowGameStats;
var int bShowNetStats;
var int bShowAnimStats;		 // Show animation statistics.
var int bShowHistograph;
var int bShowXboxMemStats;
var int bShowMatineeStats;	// Show Matinee specific information
var int bShowAudioStats;
var int bShowLightStats;

var int TickCycles, GameCycles, ClientCycles;
var(Settings) config int CacheSizeMegs;
var(Settings) config bool UseSound;
var(Settings) config bool UseStaticMeshBatching;
var(Settings) float CurrentTickRate;

var int ActiveControllerId;	// The ID of the active controller
// Color preferences.
var(Colors) config color
	C_WorldBox,
	C_GroundPlane,
	C_GroundHighlight,
	C_BrushWire,
	C_Pivot,
	C_Select,
	C_Current,
	C_AddWire,
	C_SubtractWire,
	C_GreyWire,
	C_BrushVertex,
	C_BrushSnap,
	C_Invalid,
	C_ActorWire,
	C_ActorHiWire,
	C_Black,
	C_White,
	C_Mask,
	C_SemiSolidWire,
	C_NonSolidWire,
	C_WireBackground,
	C_WireGridAxis,
	C_ActorArrow,
	C_ScaleBox,
	C_ScaleBoxHi,
	C_ZoneWire,
	C_Mover,
	C_OrthoBackground,
	C_StaticMesh,
	C_VolumeBrush,
	C_ConstraintLine,
	C_AnimMesh,
	C_TerrainWire;

defaultproperties
{
	Console=Class'Console'
	CacheSizeMegs=2
	UseSound=true
	UseStaticMeshBatching=true
	C_WorldBox=(B=107,G=0,R=0,A=255)
	C_GroundPlane=(B=63,G=0,R=0,A=255)
	C_GroundHighlight=(B=127,G=0,R=0,A=255)
	C_BrushWire=(B=63,G=63,R=255,A=255)
	C_Pivot=(B=0,G=255,R=0,A=255)
	C_Select=(B=127,G=0,R=0,A=255)
	C_Current=(B=0,G=0,R=0,A=255)
	C_AddWire=(B=255,G=127,R=127,A=255)
	C_SubtractWire=(B=63,G=192,R=255,A=255)
	C_GreyWire=(B=163,G=163,R=163,A=255)
	C_BrushVertex=(B=0,G=0,R=0,A=255)
	C_BrushSnap=(B=0,G=0,R=0,A=255)
	C_Invalid=(B=163,G=163,R=163,A=255)
	C_ActorWire=(B=0,G=63,R=127,A=255)
	C_ActorHiWire=(B=0,G=127,R=255,A=255)
	C_Black=(B=0,G=0,R=0,A=255)
	C_White=(B=255,G=255,R=255,A=255)
	C_Mask=(B=0,G=0,R=0,A=255)
	C_SemiSolidWire=(B=0,G=255,R=127,A=255)
	C_NonSolidWire=(B=32,G=192,R=63,A=255)
	C_WireBackground=(B=0,G=0,R=0,A=255)
	C_WireGridAxis=(B=119,G=119,R=119,A=255)
	C_ActorArrow=(B=0,G=0,R=163,A=255)
	C_ScaleBox=(B=11,G=67,R=151,A=255)
	C_ScaleBoxHi=(B=157,G=149,R=223,A=255)
	C_ZoneWire=(B=0,G=0,R=0,A=255)
	C_Mover=(B=255,G=0,R=255,A=255)
	C_OrthoBackground=(B=163,G=163,R=163,A=255)
	C_StaticMesh=(B=255,G=255,R=0,A=255)
	C_VolumeBrush=(B=225,G=196,R=255,A=255)
	C_ConstraintLine=(B=0,G=255,R=0,A=255)
	C_AnimMesh=(B=28,G=221,R=221,A=255)
	C_TerrainWire=(B=255,G=255,R=255,A=255)
}