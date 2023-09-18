//=============================================================================
// NightScope.uc
//
// Night vision goggles
//
//=============================================================================



class NightScope extends B9_Powerups;

var private bool fActive;

function Activate()
{
	local B9_PlayerController pc;

	pc = B9_PlayerController( Pawn(Owner).Controller );
	if( pc != None )
	{
		if( !fActive )
		{
			pc.SetNewVisionMode( VM_NightScope );
			fActive = true;
			bHidden=false;
			Pawn(Owner).AttachToBone( self, 'GoggleBone' );

		}
		else
		{
			pc.SetNewVisionMode( VM_Normal );
            fActive = false;
			bHidden=true;
		}
	}
}

// Just turn it off without setting VM_Normal.
// This will only be called by B9_PlayerController when
// a vision mode is turned on while a previous vision mode
// (other than VM_NORMAL) is already on.
//
function Deactivate()
{
	fActive = false;
	GotoState( '' );
}






defaultproperties
{
	fUniqueID=15
	bActivatable=true
	bDisplayableInv=true
	PickupClass=Class'NightScope_Pickup'
	Icon=Texture'B9HUD_textures.Browser_items.gen_belt_bricon'
	ItemName="Night Scope"
	DrawType=2
	RemoteRole=0
	Mesh=SkeletalMesh'B9Items_models.NVgoggles_mesh'
}