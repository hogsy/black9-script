//=============================================================================
// B9MP_ClientManager_XBox.
//=============================================================================
class B9MP_ClientManager_XBox extends B9MP_ClientManager
	native
	transient;

native(2435) final function int BuildList();

native(2434) final function int GetClientCount();

native(2433) final function string GetClientName(int nNameIndex);

function PreBeginPlay()
{
	local int ClientCount;
	local int i;
	local B9MP_ClientDescription Desc;
	
	Super.PreBeginPlay();
	
	BuildList();
	
	ClientCount = GetClientCount();
	
	for( i = 0; i < ClientCount; i++ )
	{
		Desc = Spawn( class 'B9MP_ClientDescription' );
		Desc.fInfo.fName = GetClientName(i);
		Log( "Name[" $ i $ "]=" $ Desc.fInfo.fName );
		fClients.PushBack(Desc);	
	}
}

