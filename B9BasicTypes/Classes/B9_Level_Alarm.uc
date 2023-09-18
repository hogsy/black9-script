class B9_Level_Alarm extends actor
	placeable;


var	bool					fAlarmOn;
var float					fCountDownTimer;
var (Alarm) float			fAlarmDuration;
var (Alarm) int				fAlarmNumber;

var (Alarm) material		fAlarmOffMaterial;
var (Alarm) material		fAlarmOnMaterial;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (!bHidden)
	{
		CopyMaterialsToSkins();
		if (fAlarmOn)
			Skins[0] = fAlarmOnMaterial;
		else
			Skins[0] = fAlarmOffMaterial;
	}
}

function Tick(float DeltaTime)
{
	if( fAlarmOn == true )
	{
		fCountDownTimer -= DeltaTime;
		if( fCountDownTimer <= 0 )
		{
			TurnAlarmOff( None );
		}
	}
}

function TurnAlarmOn( pawn Target )
{
	Log("TurnAlarmOn!");
	fCountDownTimer = fAlarmDuration;
	if(fAlarmOn == false)
	{
		fAlarmOn = true;
		if (Event != '')
			TriggerEvent(Event, self, Target);
		if (!bHidden)
			Skins[0] = fAlarmOnMaterial;
	}
}

function TurnAlarmOff( pawn Target )
{
	Log("TurnAlarmOff!");
	fCountDownTimer = 0.0;
	if( fAlarmOn == true )
	{
		fAlarmOn = false;
		if (Event != '')
			TriggerEvent(Event, self, Target);
		if (!bHidden)
			Skins[0] = fAlarmOffMaterial;
	}
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	local B9_Level_Alarm otherAlarm;
	local bool newAlarmOn;

	newAlarmOn = !fAlarmOn;
	otherAlarm = B9_Level_Alarm(Other);
	if (otherAlarm != None)
		newAlarmOn = otherAlarm.fAlarmOn;

	if (newAlarmOn)
		TurnAlarmOn( EventInstigator );
	else
		TurnAlarmOff( EventInstigator );
}

defaultproperties
{
	fAlarmDuration=60
	fAlarmNumber=1
	fAlarmOffMaterial=Texture'luna_hangar_tex_TC.electronics.gen_alarm_bttn_T'
	fAlarmOnMaterial=Shader'luna_hangar_tex_TC.electronics.gen_alarm_bttn'
	DrawType=8
	StaticMesh=StaticMesh'Luna_Hangar_Mesh_TC.props.gen_alarm_button'
	bHidden=true
}