/*********************************************************
*
* File: Rx_Defence_RocketEmplacement.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Defence_RocketEmplacement extends Rx_Defence_Emplacement
	placeable;
	
var int missleBayToggle;

//================================================
// COPIED from RxVehicle_MammothTank
// Attribute of a multi weapon vehicle, this code correctly identifies 
// the propper firing socket
//================================================
simulated function vector GetEffectLocation(int SeatIndex)
{
    local vector SocketLocation;
    local name FireTriggerTag;

    if ( Seats[SeatIndex].GunSocket.Length <= 0 )
        return Location;

    if(missleBayToggle == 1)
        missleBayToggle = 1;

    FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

    Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);

    return SocketLocation;
}

simulated function int GetBarrelIndex(int SeatIndex)
{
    local int OldBarrelIndex;
    
    OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
    if (Weapon == none)
        return OldBarrelIndex;

    return (Weapon.CurrentFireMode == 0 ? 0 : missleBayToggle);
}


defaultproperties
{
    MaxDesireability = 1.0 // todo: reactivate when flying AI is fixed
    
    missleBayToggle = 1;


	Health=400
	bLightArmor=true

	RespawnTime=90.0
	
	GroundSpeed=0
	AirSpeed=0
	MaxSpeed=0
	
	COMOffset=(x=0.0,y=0.0,z=0.0)
	
	AIPurpose=AIP_Defensive
	bTurnInPlace=True
	bFollowLookDir=True
	Physics=PHYS_None
    bIgnoreEncroachers=True
    bHardAttach=True
    bCollideWorld=False
	// bSeperatePawn = True
	bAttachDriver=true
	bDriverIsVisible=true
	
    bRotateCameraUnderVehicle=false
    CameraLag=0.2
    LookForwardDist=500.0
	DefaultFOV=55

	


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

	Begin Object name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'RX_DEF_GunEmplacement.Mesh.SK_DEF_RocketEmplacement'
		AnimTreeTemplate=AnimTree'RX_DEF_GunEmplacement.Anims.AT_DEF_RocketEmplacement'
		PhysicsAsset=PhysicsAsset'RX_DEF_GunEmplacement.Mesh.SK_DEF_RocketEmplacement_Physics'
		Translation=(X=0.0,Y=0.0,Z=-12.0)
	End Object

	DrawScale=1.0


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


	Seats(0)={( GunClass=class'Rx_Defence_RocketEmplacement_Weapon',
				GunSocket=("FireL","FireR"),
                TurretControls=(TurretPitch,TurretRotate),
                CameraTag=CamView3P,
                CameraBaseOffset=(X=0,Z=100),
                CameraOffset=-600,
                bSeatVisible=true,
                SeatBone=b_Driver,
                SeatSocket=DriverSocket,
                SeatOffset=(X=-10,Y=0,Z=10),
                SeatRotation=(Pitch=0,Yaw=0),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
				)}
				
	DrivingAnim=H_M_Seat_Apache


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


	BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_Humvee.Materials.MI_VH_Humvee_BO'
	BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_Humvee.Materials.MI_VH_Humvee_BO'

	DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_MediumTank.Materials.PhysMat_Medium_Driving'
	DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_MediumTank.Materials.PhysMat_Medium'

	VehicleEffects(0)=(EffectStartTag="FireR",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="FireL")
	VehicleEffects(1)=(EffectStartTag="FireL",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="FireR")
	VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)

	BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle')
    BigExplosionSocket=VH_Death
   	bTeamLocked = true
	
//========================================================\\
// *************** Vehicle Audio Properties ************* \\
//========================================================\\

}