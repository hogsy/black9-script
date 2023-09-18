// StorageEnvironment.uc

class StorageEnvironment extends Object
	noexport
	native;

var globalconfig INT EmulateConsole;

native(1000) static final function int HardDriveCount( );
native(1001) static final function int MemorySlotCount( );

function MemorySlotStorage GetMemorySlotStorage(int slot)
{
	local MemorySlotStorage mss;

	if (slot < 0 || slot >= MemorySlotCount())
		return None;

	mss = new(None) class'MemorySlotStorage';
	mss.Init(slot);
	return mss;
}

function HardDriveStorage GetHardDriveStorage(int slot)
{
	local HardDriveStorage hds;

	if (slot < 0 || slot >= HardDriveCount())
		return None;

	hds = new(None) class'HardDriveStorage';
	hds.Init(slot);
	return hds;
}
