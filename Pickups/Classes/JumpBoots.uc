class JumpBoots extends Powerups;

#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\BOOTSA1.WAV" NAME="BootSnd" GROUP="Pickups"

#exec TEXTURE IMPORT NAME=I_Boots FILE=..\botpack\TEXTURES\HUD\i_Boots.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=jboot ANIVFILE=..\botpack\MODELS\boots_a.3D DATAFILE=..\botpack\MODELS\boots_d.3D
#exec MESH ORIGIN MESH=jboot X=0 Y=0 Z=-70 YAW=64
#exec MESH SEQUENCE MESH=jboot SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=jboot SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jlboot2 FILE=..\botpack\MODELS\boots.PCX GROUP=Skins LODSET=2
#exec MESHMAP SCALE MESHMAP=jboot X=0.045 Y=0.045 Z=0.09
#exec MESHMAP SETTEXTURE MESHMAP=jboot NUM=1 TEXTURE=Jlboot2

var int TimeCharge;

function PickupFunction(Pawn Other)
{
	if (bActivatable && Other.SelectedItem==None) 
		Other.SelectedItem=self;
	if (bActivatable && bAutoActivate && Other.bAutoActivate) 
		Activate();
	TimeCharge = 0;
	SetTimer(1.0, True);
}

function ResetOwner()
{
	local pawn P;

	P = Pawn(Owner);
	Level.Game.SetPlayerDefaults(P);
	P.bCountJumps = False;
}

function OwnerEvent(name EventName)
{
	if ( (EventName == 'Jumped') && !Pawn(Owner).bIsWalking )
	{
		TimeCharge=0;
		if ( Charge <= 0 ) 
		{
			if ( Owner != None )
			{
				Owner.PlaySound(DeActivateSound);
				ResetOwner();						
			}		
			UsedUp();
		}
		else
			Owner.PlaySound(sound'BootJmp');						
		Charge -= 1;
	}
	if( Inventory != None )
		Inventory.OwnerEvent(EventName);

}

function Timer()
{
	if ( Charge <= 0 ) 
	{
		if ( Owner != None )
		{
			if ( Owner.Physics == PHYS_Falling )
			{
				SetTimer(0.3, true);
				return;
			}
			Owner.PlaySound(DeActivateSound);
			ResetOwner();						
		}		
		UsedUp();
		return;
	}

	if ( !Pawn(Owner).bAutoActivate )
	{	
		TimeCharge++;
		if (TimeCharge>20)
		{
			OwnerEvent('Jumped');
			TimeCharge = 0;
		}
	}
}

state Activated
{
	function endstate()
	{
		ResetOwner();
		bActive = false;		
	}

	function beginstate()
	{
		Pawn(Owner).bCountJumps = True;
		Pawn(Owner).AirControl = 1.0;
		Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * 3;
		Owner.PlaySound(ActivateSound);	
	}	
}

state DeActivated
{
Begin:		
}

defaultproperties
{
	bAutoActivate=true
	bActivatable=true
	ExpireMessage="The AntiGrav Boots have drained."
	ActivateSound=Sound'Pickups.BootSnd'
	bDisplayableInv=true
	PickupClass=Class'UT_Jumpboots'
	Charge=3
	Icon=Texture'Icons.I_Boots'
	ItemName="AntiGrav Boots"
	MessageClass=Class'WarfareGame.ItemMessagePlus'
}