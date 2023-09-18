//=============================================================================
// B9_MissionMapDisplay.uc.uc
//
//	
//
//=============================================================================



class B9_MissionMapDisplay extends Actor 
	abstract;


//////////////////////////////////
// Resource Imports
//
#exec OBJ LOAD FILE=..\StaticMeshes\Luna_hangar_mesh_EC.usx PACKAGE=Luna_hangar_mesh_EC


//////////////////////////////////
// Variables
//

var private bool			fNeedToInit;
var private B9_HQListener	fListener;
var private MaterialTrigger	fMaterialTrigger;
var private TimedTrigger	fTimedTrigger;
var private Shader			fSlideShow;
var private float			fFrameTime;

//////////////////////////////////
// Functions
//

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Init();
}

function Init()
{
	ForEach AllActors(class'B9_HQListener', fListener)
	{
		break;
	}

	CopyMaterialsToSkins();

	fMaterialTrigger			= Spawn( class'MaterialTrigger', self,, Location );
	fMaterialTrigger.Tag		= 'MissionDisplayTrigger';

	fTimedTrigger				= Spawn( class'TimedTrigger', self,, Location );
	fTimedTrigger.bRepeating	= true;
	fTimedTrigger.DelaySeconds	= fFrameTime;
	fTimedTrigger.Event			= 'MissionDisplayTrigger';
}

simulated function Tick( float Delta )
{
	if( fNeedToInit )	// Timing issue; PostBeingPlay() is too soon to find fListener's intermission
	{
		if( fListener.intermission != None )
		{
			fNeedToInit = false;
			
			fSlideShow = fListener.intermission.MissionMapSlideshow;
			fFrameTime = fListener.intermission.MissionMapSlideshowFrameTime;

			
			fMaterialTrigger.MaterialsToTrigger[0]	= fSlideShow;
			fTimedTrigger.DelaySeconds				= fFrameTime;

			if( Skins[0] != None )
			{
				Skins[0] = fSlideShow;
			}
		}
	}
}

event Destroyed()
{
	if( fMaterialTrigger != None )
	{
		fMaterialTrigger.Destroy();
		fMaterialTrigger = None;
	}

	if( fTimedTrigger != None )
	{
		fTimedTrigger.Destroy();
		fTimedTrigger = None;
	}
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fNeedToInit=true
	fFrameTime=1.5
	DrawType=8
	StaticMesh=StaticMesh'Luna_hangar_Mesh_EC.Conference_Room.BriefingTV'
	DrawScale=0.15
}