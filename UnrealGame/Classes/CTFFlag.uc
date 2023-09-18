class CTFFlag extends CarriedObject;

var byte 			TeamNum;    	
var GameObjective   HomeBase;
var float           TakenTime;
var float           MaxDropTime;
var Controller FirstTouch;			// Who touched this objective first
var array<Controller> Assists;		// Who touches it after
var name 	AttachmentBone;
var UnrealTeamInfo 	Team;
var Pawn 		OldHolder;
var GameReplicationInfo GRI;

replication
{
	reliable if ( Role == ROLE_Authority )
		Team;
}

// Initialization
function PostBeginPlay()
{
    HomeBase = GameObjective(Owner);
    SetOwner(None);
    if ( Level.Game != None )
		SetGRI(Level.Game.GameReplicationInfo);

    Super.PostBeginPlay();
}
	
// State transitions
function SetHolder(Controller C)
{
	local int i;
	local CTFSquadAI S;
	
	// AI Related
	if ( Bot(C) != None )
		S = CTFSquadAI(Bot(C).Squad);
	else if ( PlayerController(C) != None )
		S = CTFSquadAI(UnrealTeamInfo(C.PlayerReplicationInfo.Team).AI.FindHumanSquad());
	if ( S != None )
		S.EnemyFlagTakenBy(C);

    LogTaken(c);
    Holder = UnrealPawn(C.Pawn);
    Holder.SpawnTime = -100000;
    HolderPRI = TeamPlayerReplicationInfo(Holder.PlayerReplicationInfo);
    C.PlayerReplicationInfo.SetFlag(self);

    GotoState('Held');

	// AI Related	
	C.MoveTimer = -1;
	Holder.MakeNoise(2.0);

	// Track First Touch
	
	if (FirstTouch == None)
		FirstTouch = C; 

	// Track Assists

	for (i=0;i<Assists.Length;i++)
		if (Assists[i] == C)
		  return;
	
	Assists.Length = Assists.Length+1;
  	Assists[Assists.Length-1] = C;
	
    C.SendMessage(None, 'OTHER', C.GetMessageIndex('GOTENEMYFLAG'), 10, 'TEAM');	
}

function Score()
{
    Disable('Touch');
    SetLocation(HomeBase.Location);
    SetRotation(HomeBase.Rotation);
    GotoState('Home');
}

function Drop(vector newVel)
{
    OldHolder = Holder;

	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));

    Velocity = (0.2 + FRand()) * (newVel + 400 * FRand() * VRand());
	if ( PhysicsVolume.bWaterVolume )
		Velocity *= 0.5;

	SetLocation(Holder.Location);
    LogDropped();
    Velocity = newVel;
    GotoState('Dropped');
}

function SendHome()
{
    local Controller c;

	// AI Related	
    for (c = Level.ControllerList; c!=None; c=c.nextController)
        if (c.MoveTarget == self)
            c.MoveTimer = -1.0;
			
	LogReturned();
				
	// Reset the assists and First Touch
			
	FirstTouch = None;
	
	while (Assists.Length!=0)
	  Assists.Remove(0,1);
    GotoState('Home');			
}

function ClearHolder()
{
	local int i;
	local GameReplicationInfo GRI;
	
    if (Holder == None)       
        return;

	if ( Holder.PlayerReplicationInfo == None )
	{
		GRI = Level.Game.GameReplicationInfo;
		for (i=0; i<GRI.PRIArray.Length; i++)
			if ( GRI.PRIArray[i].HasFlag == self )
				GRI.PRIArray[i].SetFlag(None);
	}
	else
		Holder.PlayerReplicationInfo.SetFlag(None);
    Holder = None;
    HolderPRI = None;
}

function Actor Position()
{
    if (bHeld)
        return Holder;

    if (bHome)
        return HomeBase;

    return self;
}

function bool IsHome()
{
    return false;
}

function bool ValidHolder(Actor Other)
{
    local Controller c;
    local Pawn p;

    p = Pawn(other);
    if (p == None || p.Health <= 0 || !p.IsPlayerPawn())
        return false;

    c = Pawn(Other).Controller;
	if (SameTeam(c))
	{
        SameTeamTouch(c);
        return false;
	}

    return true;
}

// Events
singular function Touch(Actor Other)
{
    if (!ValidHolder(Other))
        return;

    SetHolder(Pawn(Other).Controller);
}

event FellOutOfWorld(eKillZType KillType)
{
    SendHome();
}

event Landed(vector HitNormall)
{
	local Controller C;
	local rotator NewRot;

	NewRot = Rot(16384,0,0);
	NewRot.Yaw = Rotation.Yaw;
	SetRotation(NewRot);
	
    // tell nearby bots about this
    for (C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if ((C.Pawn != None) && (Bot(C) != None) 
            && (C.RouteGoal != self) && (C.Movetarget != self) 
            && (VSize(C.Pawn.Location - Location) < 1600)
            && C.LineOfSightTo(self) )
        {
			Bot(C).Squad.Retask(Bot(C));	
        }
    }
}

function SameTeamTouch(Controller c)
{
}

// Logging
function LogReturned()
{
	BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
}

function LogDropped()
{
	BroadcastLocalizedMessage( MessageClass, 2, Holder.PlayerReplicationInfo, None, Team );
	UnrealMPGameInfo(Level.Game).GameEvent("flag_dropped",""$Team.TeamIndex, Holder.PlayerReplicationInfo);
}

function LogTaken(Controller c);

function CheckPain(); 

simulated function UpdateForTeam()
{
	if ( (GRI != None) && (GRI.Teams[TeamNum] != None) && (GRI.Teams[TeamNum].TeamIcon != None) )
	    TexScaler(Combiner(Shader(FinalBlend(Skins[0]).Material).Diffuse).Material2).Material = GRI.Teams[TeamNum].TeamIcon;
}

simulated function SetGRI(GameReplicationInfo NewGRI)
{
	GRI = NewGRI;
	UpdateForTeam();
}	

// Helper funcs
function bool SameTeam(Controller c)
{
    if (c == None || c.PlayerReplicationInfo.Team != Team)
        return false;

    return true;
}
// States
auto state Home
{
    ignores SendHome, Score, Drop;

    function SameTeamTouch(Controller c)
    {
        local CTFFlag flag;

        if (C.PlayerReplicationInfo.HasFlag == None)
            return;

        // Score!
        flag = CTFFlag(C.PlayerReplicationInfo.HasFlag);
        CTFGame(Level.Game).ScoreFlag(C, flag);
        flag.Score();
		TriggerEvent(HomeBase.Event,HomeBase,C.Pawn);
        if (Bot(C) != None)
            Bot(C).Squad.SetAlternatePath(true);
    }
        
    function LogTaken(Controller c)
    {
        BroadcastLocalizedMessage( MessageClass, 6, C.PlayerReplicationInfo, None, Team );
        UnrealMPGameInfo(Level.Game).GameEvent("flag_taken",""$Team.TeamIndex,C.PlayerReplicationInfo);
    }

	function Timer()
	{
		if ( VSize(Location - HomeBase.Location) > 10 )
		{
			UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
			BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
            log(self$" Home.Timer: had to sendhome", 'Error');
			SendHome();
		}
	}
	
	function CheckTouching()
	{
		local int i;
		
		for ( i=0; i<Touching.Length; i++ )
			if ( ValidHolder(Touching[i]) )
			{
				SetHolder(Pawn(Touching[i]).Controller);
				return;
			}
	}	

    function bool IsHome()
    {
        return true;
    }

	function BeginState()
	{
        Disable('Touch');
        bHome = true;
        SetLocation(HomeBase.Location);
        SetRotation(HomeBase.Rotation);
        Enable('Touch');

        Level.Game.GameReplicationInfo.SetCarriedObjectState(TeamNum,'Home');
		bHidden = true;
		HomeBase.bHidden = false;
		HomeBase.Timer();
		SetTimer(1.0, true);
	}

	function EndState()
	{
        bHome = false;
        TakenTime = Level.TimeSeconds;
		bHidden = false;
		HomeBase.bHidden = true;
		HomeBase.PlayAlarm();
		SetTimer(0.0, false);
	}
    
Begin:
	// check if an enemy was standing on the base
	Sleep(0.05);
	CheckTouching();

}

state Held
{
    ignores SetHolder, SendHome;

	function Timer()
	{
		if (Holder == None)
        {
            log(self$" Held.Timer: had to sendhome", 'Error');
			UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
			BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
			SendHome();
        }
	}

	function BeginState()
	{
        Level.Game.GameReplicationInfo.SetCarriedObjectState(TeamNum,'HeldEnemy');
        bOnlyDrawIfAttached = true;
        bHeld = true;
        bCollideWorld = false;
        SetCollision(false, false, false);
        SetLocation(Holder.Location);
        Holder.HoldCarriedObject(self,AttachmentBone);
		SetTimer(10.0, true);
	}

    function EndState()
    {
        //log(self$" held.endstate", 'GameObject');
        bOnlyDrawIfAttached = false;
        ClearHolder();
        bHeld = false;
        bCollideWorld = true;
        SetCollision(true, false, false);
        SetBase(None);
        SetRelativeLocation(vect(0,0,0));
        SetRelativeRotation(rot(0,0,0));
    }
}

state Dropped
{
   ignores Drop;

   function SameTeamTouch(Controller c)
	{
		// returned flag
		CTFGame(Level.Game).ScoreFlag(C, self);
		SendHome();
	}

    function LogTaken(Controller c)
    {
        UnrealMPGameInfo(Level.Game).GameEvent("flag_pickup",""$Team.TeamIndex,C.PlayerReplicationInfo);
        BroadcastLocalizedMessage( MessageClass, 4, C.PlayerReplicationInfo, None, Team );
    }

    function CheckFit()
    {
	    local vector X,Y,Z;

	    GetAxes(OldHolder.Rotation, X,Y,Z);
	    SetRotation(rotator(-1 * X));
	    if ( !SetLocation(OldHolder.Location - 2 * OldHolder.CollisionRadius * X + OldHolder.CollisionHeight * vect(0,0,0.5)) 
		    && !SetLocation(OldHolder.Location) )
	    {
		    SetCollisionSize(0.8 * OldHolder.CollisionRadius, FMin(CollisionHeight, 0.8 * OldHolder.CollisionHeight));
		    if ( !SetLocation(OldHolder.Location) )
		    {
                //log(self$" Drop sent flag home", 'Error');
				UnrealMPGameInfo(Level.Game).GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
				BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
			    SendHome();
			    return;
		    }
	    }
    }

    function CheckPain()
    {
        if (IsInPain())
            timer();
    }

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
	{
        CheckPain();
	}

	singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		Super.PhysicsVolumeChange(NewVolume);
        CheckPain();
	}
	
	function Timer()
	{
		if (Level.Game.GameStats != None)
			Level.Game.GameStats.GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);
	
		SendHome();
	}

	function BeginState()
	{
        Level.Game.GameReplicationInfo.SetCarriedObjectState(TeamNum,'Down');
        SetPhysics(PHYS_Falling);
	    bCollideWorld = true;
	    SetCollisionSize(0.5 * default.CollisionRadius, CollisionHeight);
        CheckFit();
        CheckPain();
		SetTimer(MaxDropTime, false);
	}
    
    function EndState()
    {
        SetPhysics(PHYS_None);
		bCollideWorld = false;
		SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
    }
}

defaultproperties
{
	MaxDropTime=25
	AttachmentBone=FlagHand
	bHome=true
	LightType=1
	LightEffect=20
	LightBrightness=128
	LightRadius=6
	LightSaturation=128
	bHidden=true
	bDynamicLight=true
	NetPriority=3
	DrawScale=0.6
	PrePivot=(X=2,Y=0,Z=0.5)
	Style=2
	bUnlit=true
	CollisionRadius=48
	CollisionHeight=30
	bCollideActors=true
	bCollideWorld=true
	bFixedRotationDir=true
	Mass=30
	Buoyancy=20
	RotationRate=(Pitch=30000,Yaw=0,Roll=30000)
	MessageClass=Class'CTFMessage'
}