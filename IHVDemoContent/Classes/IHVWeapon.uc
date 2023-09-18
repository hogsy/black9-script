class IHVWeapon extends InventoryAttachment;

#exec OBJ LOAD FILE=..\StaticMeshes\3pguns_meshes.usx PACKAGE=3pguns_meshes

defaultproperties
{
	DrawType=8
	StaticMesh=StaticMesh'3pguns_meshes.Cog_Guns.Grunt_Gun'
	RelativeLocation=(X=0,Y=1,Z=-0.3)
	RelativeRotation=(Pitch=0,Yaw=0,Roll=32768)
	DrawScale=0.1
}