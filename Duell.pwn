#include <a_samp>
#include <ocmd>
#include <streamer>
#include <sscanf2>

forward DuellDialogAbbrechenTXDLaden(playerid);
forward DuellPunktestandTXDLaden(playerid);
forward StartduelAbfrage(playerid);
forward DuellTimer(playerid);
forward DuellMapPark();
forward DuellMapStadium();
forward DuellMapHaus();
forward DuellMapPlatz();
forward DuellMapLagerhalle();

#if !defined isnull
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#define DUELL 5 //Bei Dialog-Bugs pr�fen ob die DefineIDs mit DefineIDs aus dem Main-Script �bereinstimmen, falls ja anpassen.
#define DUELL2 6
#define DUELL3 7
#define DUELL4 8
#define DUELL5 9
#define DUELL6 10
#define DUELL7 11
#define HELLBLAU 0x00FFFFFF


enum EnumDuellInfo
{
	DuellErstellerPID,
	DuellBeitreterPID,
	DuellMap[20],
	DuellWetteinsatz[6],
	DuellWaffen[500],
	DuellErstellt,
	DuellName[128],
	DuellErstellerName[128],
	DuellBeitreterName[128],
	DuellGestartet,
	DuellTimerMinute,
	DuellTimerSekunde,
	DuellPunkteErsteller,
	DuellPunkteBeitreter
}

new PlayerText:DuellDialogAbbrechenTextdraw[MAX_PLAYERS][2];
new PlayerText:DuellPunktestandTextdraw[MAX_PLAYERS][17];
new DuellInfo[20][EnumDuellInfo];
new DuellID[MAX_PLAYERS] = -1; //DuellID vom Ersteller
new DuellIDVorschau[MAX_PLAYERS] = -2; //DuellID die gerade von einem Spieler angesehen wird
new StartduelEingegeben[MAX_PLAYERS] = 0;
new DuellIDGestartet[MAX_PLAYERS] = -3;
new DuellTimerID[20];
new DuellCountDownVar[20];
new DuellWaffenInfo[MAX_PLAYERS][13][2];
new Float:DuellPosInfo[MAX_PLAYERS][3];
new Float:DuellSpawns[][] =
{
	{-212.0751,49.7200,791.9637,180.3594}, //Lagerhalle Spawn 1
	{-211.6711,-13.3458,793.4451,0.2143}, //Lagerhalle Spawn 2
	{-4461.3296,162.7547,1473.5430,354.2375}, //Park Spawn 1
	{-4442.0557,325.1241,1473.5992,174.3824}, //Park Spawn 2
	{-169.8543,-1626.3909,795.7524,270.5767}, //Platz Spawn 1
	{-123.4336,-1627.6014,795.7536,89.8050}, //Platz Spawn 2
	{-2894.8416,-807.4859,779.0613,219.5496}, //Stadium Spawn 1
	{-2887.7341,-815.7706,779.0613,39.5496}, //Stadium Spawn 2
	{-630.4880,-536.6506,800.4752,90.3618}, //Haus Spawn 1
	{-692.0258,-571.0043,796.3333,339.4642} //Haus Spawn 2
};

public OnFilterScriptInit()
{
	for(new DuellIni=0;DuellIni<20;DuellIni++)
	{
		DuellInfo[DuellIni][DuellErstellerPID] = -1;
		DuellInfo[DuellIni][DuellBeitreterPID] = -2;
		DuellInfo[DuellIni][DuellTimerMinute] = 9;
		DuellInfo[DuellIni][DuellTimerSekunde] = 60;
	}
	strini(DuellID,MAX_PLAYERS,-1);
 	strini(DuellIDVorschau,MAX_PLAYERS,-2);
 	strini(DuellIDGestartet,MAX_PLAYERS,-3);
	strini(DuellCountDownVar,20,4);
	//DuellMapPark
	CreateObject(11083,-4451.7002000,231.7000000,1475.6000000,0.0000000,0.0000000,175.2860000); //object(drivingschlgnd_sfs) (1)
	CreateObject(3899,-4474.0000000,120.6000000,1521.1000000,0.0000000,0.0000000,264.0290000); //object(lib_street04) (1)
	CreateObject(3906,-4357.6001000,163.3999900,1515.1000000,0.0000000,0.0000000,0.0000000); //object(lib_street01) (1)
	CreateObject(3906,-4496.7998000,159.7000000,1497.4000000,0.0000000,0.0000000,0.0000000); //object(lib_street01) (2)
	CreateObject(3911,-4360.3999000,266.7999900,1476.9000000,0.0000000,0.0000000,175.9180000); //object(lib_street13) (1)
	CreateObject(3911,-4352.6001000,315.7999900,1474.8000000,0.0000000,0.0000000,175.9130000); //object(lib_street13) (2)
	CreateObject(3911,-4412.7998000,376.2000100,1476.3000000,0.0000000,0.0000000,262.8390000); //object(lib_street13) (3)
	CreateObject(3911,-4460.1001000,381.1000100,1477.0000000,0.0000000,0.0000000,262.8370000); //object(lib_street13) (4)
	CreateObject(3911,-4539.2998000,318.7999900,1477.9000000,0.0000000,0.0000000,352.0900000); //object(lib_street13) (5)
	CreateObject(3911,-4544.0000000,260.7000100,1479.0000000,0.0000000,0.0000000,352.0900000); //object(lib_street13) (6)
	CreateObject(3924,-4448.2002000,264.6000100,1499.3000000,0.0000000,0.0000000,85.3720000); //object(playroom) (1)
	CreateObject(8229,-4481.8999000,155.8000000,1475.1000000,0.0000000,0.0000000,354.8240000); //object(vgsbikeschl02) (1)
	CreateObject(8229,-4459.7002000,153.7000000,1475.1000000,0.0000000,0.0000000,354.8200000); //object(vgsbikeschl02) (3)
	CreateObject(8229,-4459.7002000,153.7002000,1479.1000000,0.0000000,0.0000000,354.8200000); //object(vgsbikeschl02) (4)
	CreateObject(8229,-4481.7998000,156.0000000,1479.1000000,0.0000000,0.0000000,354.8200000); //object(vgsbikeschl02) (5)
	CreateObject(11677,-4410.2998000,214.3999900,1478.6000000,0.0000000,0.0000000,316.0200000); //object(xen2_countn) (1)
	CreateObject(11677,-4494.7998000,229.3000000,1478.6000000,0.0000000,0.0000000,316.0160000); //object(xen2_countn) (2)
	CreateObject(7301,-4445.3999000,287.7000100,1475.2000000,0.0000000,0.0000000,130.2730000); //object(vgsn_addboard03) (2)
	CreateObject(10757,-4446.1001000,191.8000000,1505.4000000,5.0000000,40.0000000,19.9180000); //object(airport_04_sfse) (1)
	CreateObject(1681,-4451.7002000,228.5996100,1503.8000000,3.9990000,334.9950000,190.4100000); //object(ap_learjet1_01) (2)
	CreateObject(1681,-4480.2002000,247.1000100,1503.8000000,3.9990000,334.9950000,198.1730000); //object(ap_learjet1_01) (4)
	CreateObject(1681,-4423.8999000,242.1000100,1503.8000000,3.9990000,334.9950000,185.2340000); //object(ap_learjet1_01) (5)
	CreateObject(7073,-4432.2998000,331.7000100,1497.0000000,0.0000000,0.0000000,87.9590000); //object(vegascowboy1) (1)
	CreateObject(7073,-4459.2002000,334.1000100,1497.2000000,0.0000000,0.0000000,87.9570000); //object(vegascowboy1) (2)
	CreateObject(7392,-4439.7998000,152.2000000,1487.0000000,0.0000000,0.0000000,266.8650000); //object(vegcandysign1) (1)
	CreateObject(7392,-4488.7002000,156.8000000,1487.7000000,0.0000000,0.0000000,266.8630000); //object(vegcandysign1) (2)
	CreateObject(11095,-4447.7002000,293.0000000,1477.9000000,0.0000000,0.0000000,84.3390000); //object(stadbridge_sfs) (1)
	CreateObject(11095,-4455.2998000,181.7000000,1477.9000000,0.0000000,0.0000000,265.5690000); //object(stadbridge_sfs) (2)
	CreateObject(1681,-4483.5000000,214.5000000,1503.8000000,3.9990000,334.9950000,211.1120000); //object(ap_learjet1_01) (6)
	CreateObject(3095,-4404.0000000,295.8999900,1483.0000000,0.0000000,90.0000000,354.8240000); //object(a51_jetdoor) (1)
	CreateObject(3095,-4404.5000000,287.5000000,1483.0000000,0.0000000,90.0000000,354.8200000); //object(a51_jetdoor) (2)
	CreateObject(3095,-4405.1001000,282.2000100,1483.0000000,0.0000000,90.0000000,354.8200000); //object(a51_jetdoor) (3)
	CreateObject(3095,-4413.2998000,187.3999900,1483.0000000,0.0000000,90.0000000,354.8200000); //object(a51_jetdoor) (4)
	CreateObject(3095,-4413.7998000,179.2000000,1483.0000000,0.0000000,90.0000000,354.8200000); //object(a51_jetdoor) (5)
	CreateObject(3095,-4414.6001000,172.1000100,1483.0000000,0.0000000,90.0000000,354.8200000); //object(a51_jetdoor) (6)
	CreateObject(3095,-4498.1001000,181.2000000,1483.0000000,0.0000000,90.0000000,175.5420000); //object(a51_jetdoor) (7)
	CreateObject(3095,-4497.7998000,189.0000000,1483.0000000,0.0000000,90.0000000,175.5400000); //object(a51_jetdoor) (8)
	CreateObject(3095,-4497.2002000,195.3000000,1483.0000000,0.0000000,90.0000000,175.5400000); //object(a51_jetdoor) (9)
	CreateObject(3095,-4489.2998000,288.2999900,1483.0000000,0.0000000,90.0000000,175.5400000); //object(a51_jetdoor) (10)
	CreateObject(3095,-4488.7002000,296.8999900,1483.0000000,0.0000000,90.0000000,175.5400000); //object(a51_jetdoor) (11)
	CreateObject(3095,-4488.0000000,305.0000000,1483.0000000,0.0000000,90.0000000,175.5400000); //object(a51_jetdoor) (12)
	CreateObject(8853,-4417.1001000,266.8999900,1472.8000000,0.0000000,0.0000000,355.0860000); //object(vgeplntr02_lvs) (1)
	CreateObject(8853,-4418.8999000,245.8999900,1472.8000000,0.0000000,0.0000000,355.0840000); //object(vgeplntr02_lvs) (2)
	CreateObject(8853,-4420.7998000,224.7000000,1472.8000000,0.0000000,0.0000000,355.0840000); //object(vgeplntr02_lvs) (3)
	CreateObject(8853,-4422.6001000,203.7000000,1472.8000000,0.0000000,0.0000000,355.0840000); //object(vgeplntr02_lvs) (4)
	CreateObject(8853,-4481.8999000,272.2000100,1472.8000000,0.0000000,0.0000000,355.0840000); //object(vgeplntr02_lvs) (5)
	CreateObject(8853,-4483.7002000,251.1000100,1472.8000000,0.0000000,0.0000000,355.0840000); //object(vgeplntr02_lvs) (6)
	CreateObject(8853,-4485.5000000,230.2000000,1472.8000000,0.0000000,0.0000000,355.0840000); //object(vgeplntr02_lvs) (7)
	CreateObject(8853,-4487.2998000,209.2000000,1472.8000000,0.0000000,0.0000000,355.0840000); //object(vgeplntr02_lvs) (8)
	CreateObject(8853,-4457.6001000,197.7000000,1472.8000000,0.0000000,0.0000000,264.7980000); //object(vgeplntr02_lvs) (9)
	CreateObject(8853,-4445.6001000,287.5000000,1472.8000000,0.0000000,0.0000000,264.7920000); //object(vgeplntr02_lvs) (10)
	CreateObject(718,-4416.2002000,278.6000100,1472.6000000,0.0000000,0.0000000,354.8240000); //object(vgs_palm04) (1)
	CreateObject(718,-4423.7998000,192.0000000,1472.6000000,0.0000000,0.0000000,354.8200000); //object(vgs_palm04) (2)
	CreateObject(718,-4446.0000000,196.7000000,1472.6000000,0.0000000,0.0000000,354.8200000); //object(vgs_palm04) (3)
	CreateObject(718,-4469.0000000,198.8000000,1472.6000000,0.0000000,0.0000000,354.8200000); //object(vgs_palm04) (4)
	CreateObject(718,-4488.1001000,197.5000000,1472.6000000,0.0000000,0.0000000,354.8200000); //object(vgs_palm04) (5)
	CreateObject(718,-4480.6001000,283.7999900,1472.6000000,0.0000000,0.0000000,354.8200000); //object(vgs_palm04) (6)
	CreateObject(718,-4457.2998000,288.5000000,1472.6000000,0.0000000,0.0000000,354.8200000); //object(vgs_palm04) (7)
	CreateObject(718,-4434.1001000,286.1000100,1472.6000000,0.0000000,0.0000000,354.8200000); //object(vgs_palm04) (8)
	CreateObject(673,-4423.2002000,197.7000000,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (1)
	CreateObject(673,-4422.3999000,206.8000000,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (2)
	CreateObject(673,-4421.1001000,219.3000000,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (3)
	CreateObject(673,-4420.6001000,229.8000000,1473.0000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (4)
	CreateObject(673,-4419.2998000,241.3000000,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (5)
	CreateObject(673,-4418.2002000,254.8000000,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (6)
	CreateObject(673,-4416.8999000,268.6000100,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (7)
	CreateObject(673,-4488.0000000,205.5000000,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (8)
	CreateObject(673,-4486.6001000,216.8999900,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (9)
	CreateObject(673,-4485.6001000,228.3000000,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (10)
	CreateObject(673,-4485.0000000,239.1000100,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (11)
	CreateObject(673,-4483.8999000,250.3999900,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (12)
	CreateObject(673,-4483.0000000,262.7000100,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (13)
	CreateObject(673,-4481.7002000,277.2999900,1472.8000000,0.0000000,0.0000000,0.0000000); //object(sm_bevhiltree) (14)
	CreateObject(2745,-4436.0000000,286.7999900,1474.0000000,0.0000000,0.0000000,0.0000000); //object(cj_stat_3) (1)
	CreateObject(2745,-4454.7998000,288.3999900,1474.0000000,0.0000000,0.0000000,0.0000000); //object(cj_stat_3) (2)
	CreateObject(2745,-4467.2998000,198.3999900,1474.0000000,0.0000000,0.0000000,176.3180000); //object(cj_stat_3) (3)
	CreateObject(2745,-4448.1001000,196.8000000,1474.0000000,0.0000000,0.0000000,176.3140000); //object(cj_stat_3) (4)
	CreateObject(7909,-4457.5000000,197.6000100,1476.1000000,0.0000000,0.0000000,175.5470000); //object(vgwestbillbrd10) (1)
	CreateObject(7909,-4457.5000000,197.7000000,1476.1000000,0.0000000,0.0000000,355.4840000); //object(vgwestbillbrd10) (2)
	CreateObject(7301,-4445.6001000,287.2999900,1475.2000000,0.0000000,0.0000000,310.3320000); //object(vgsn_addboard03) (4)
	CreateObject(7301,-4462.0996000,154.2998000,1483.7000000,0.0000000,0.0000000,312.1380000); //object(vgsn_addboard03) (5)
	CreateObject(3911,-4546.7998000,214.3999900,1479.0000000,0.0000000,0.0000000,352.0900000); //object(lib_street13) (7)
	CreateObject(3911,-4361.7998000,222.2000000,1476.9000000,0.0000000,0.0000000,175.1420000); //object(lib_street13) (8)
	CreateObject(3785,-4447.6001000,226.6000100,1500.5000000,0.0000000,0.0000000,298.4290000); //object(bulkheadlight) (1)
	CreateObject(3785,-4446.1001000,219.6000100,1500.9000000,0.0000000,0.0000000,298.4270000); //object(bulkheadlight) (2)
	CreateObject(3785,-4444.2998000,212.5000000,1501.4000000,0.0000000,0.0000000,298.4270000); //object(bulkheadlight) (3)
	CreateObject(3785,-4455.3999000,223.3999900,1505.5000000,0.0000000,0.0000000,298.4270000); //object(bulkheadlight) (4)
	CreateObject(3785,-4454.2002000,216.1000100,1505.4000000,0.0000000,0.0000000,298.4270000); //object(bulkheadlight) (5)
	CreateObject(3785,-4453.0000000,208.3999900,1505.5000000,0.0000000,0.0000000,298.4270000); //object(bulkheadlight) (6)

	//DuellMapStadium
    CreateObject(7983, -2907.80078, -829.58069, 800.96753,   0.00000, 0.00000, 0.00000);
	CreateObject(19913, -2963.01538, -805.55017, 782.96753,   0.00000, 0.00000, -105.00000);
	CreateObject(19913, -2940.93140, -767.03754, 782.89362,   0.00000, 0.00000, -135.00000);
	CreateObject(19913, -2901.96362, -750.60449, 782.39258,   0.00000, 0.00000, 0.00000);
	CreateObject(19913, -2857.93506, -763.35455, 783.34241,   0.00000, 0.00000, -33.00000);
	CreateObject(19913, -2828.87573, -795.35492, 783.34241,   0.00000, 0.00000, -62.00000);
	CreateObject(19913, -2826.41138, -836.95862, 783.36340,   0.00000, 0.00000, -112.00000);
	CreateObject(19913, -2849.11182, -872.88519, 783.61279,   0.00000, 0.00000, -135.00000);
	
	//DuellMapHaus
    CreateObject(14853, -662.99091, -559.53381, 800.47522,   0.00000, 0.00000, 0.00000);
	CreateObject(19913, -652.69873, -559.28381, 800.47522,   0.00000, 0.00000, 0.00000);
	CreateObject(19913, -699.88818, -579.62012, 795.32471,   0.00000, 0.00000, -90.00000);
	CreateObject(19913, -720.11310, -557.86426, 796.98834,   0.00000, 0.00000, 0.00000);
	CreateObject(19913, -689.28821, -589.41333, 795.32727,   0.00000, 0.00000, 0.00000);
	
	//DuellMapPlatz
    CreateObject(14795, -144.45987, -1626.40125, 800.03369,   0.00000, 0.00000, 0.00000);
	CreateObject(19913, -131.66495, -1601.44641, 800.15179,   0.00000, 0.00000, 0.00000);
	
	//DuellMapLagerhalle
    CreateObject(14784, -209.99466, 21.25798, 800.36298,   0.00000, 0.00000, 0.00000);
	CreateObject(19913, -235.25333, 54.88343, 794.50732,   0.00000, 0.00000, 0.00000);
	CreateObject(19913, -186.67715, 54.86528, 794.80341,   0.00000, 0.00000, 0.00000);
	return 1;
}

public DuellDialogAbbrechenTXDLaden(playerid)
{
	DuellDialogAbbrechenTextdraw[playerid][0] = CreatePlayerTextDraw(playerid, 409.000000, 126.533294, "X");
	PlayerTextDrawLetterSize(playerid, DuellDialogAbbrechenTextdraw[playerid][0], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, DuellDialogAbbrechenTextdraw[playerid][0], 1);
	PlayerTextDrawColor(playerid, DuellDialogAbbrechenTextdraw[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, DuellDialogAbbrechenTextdraw[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, DuellDialogAbbrechenTextdraw[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellDialogAbbrechenTextdraw[playerid][0], 255);
	PlayerTextDrawFont(playerid, DuellDialogAbbrechenTextdraw[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, DuellDialogAbbrechenTextdraw[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, DuellDialogAbbrechenTextdraw[playerid][0], 0);

	DuellDialogAbbrechenTextdraw[playerid][1] = CreatePlayerTextDraw(playerid, 409.500000, 129.022293, "box");
	PlayerTextDrawLetterSize(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 0.000000, 1.149999);
	PlayerTextDrawTextSize(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 418.000000, 10.000000);
	PlayerTextDrawAlignment(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 1);
	PlayerTextDrawColor(playerid, DuellDialogAbbrechenTextdraw[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 255);
	PlayerTextDrawSetShadow(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 255);
	PlayerTextDrawFont(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, DuellDialogAbbrechenTextdraw[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, DuellDialogAbbrechenTextdraw[playerid][1], true);
	return 1;
}

public DuellPunktestandTXDLaden(playerid)
{
	DuellPunktestandTextdraw[playerid][0] = CreatePlayerTextDraw(playerid, 215.299438, 31.955533, "box");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][0], 0.000000, -0.350000);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][0], 432.799438, 0.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][0], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, DuellPunktestandTextdraw[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, DuellPunktestandTextdraw[playerid][0], -1061109505);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][0], -1061109505);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][0], 0);

	DuellPunktestandTextdraw[playerid][1] = CreatePlayerTextDraw(playerid, 393.099456, -9.366673, "LD_OTB2:Ric2");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][1], 42.270458, 49.419929);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][1], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][1], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][1], 4);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][1], 0);

	DuellPunktestandTextdraw[playerid][2] = CreatePlayerTextDraw(playerid, 286.399536, 31.799995, "ld_grav:timer");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][2], 18.000000, 17.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][2], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][2], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][2], 4);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][2], 0);

	DuellPunktestandTextdraw[playerid][3] = CreatePlayerTextDraw(playerid, 215.099426, 2.088901, "box");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][3], 0.000000, 4.999998);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][3], 432.599426, 0.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][3], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, DuellPunktestandTextdraw[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, DuellPunktestandTextdraw[playerid][3], 136);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][3], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][3], 0);

	DuellPunktestandTextdraw[playerid][4] = CreatePlayerTextDraw(playerid, 213.099548, -9.888893, "LD_OTB2:Ric1");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][4], 43.000000, 50.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][4], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][4], -1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][4], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][4], 4);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][4], 0);

	DuellPunktestandTextdraw[playerid][5] = CreatePlayerTextDraw(playerid, 301.299713, 2.088874, "box");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][5], 0.000000, 2.792001);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][5], 301.161773, 0.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][5], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][5], -1);
	PlayerTextDrawUseBox(playerid, DuellPunktestandTextdraw[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, DuellPunktestandTextdraw[playerid][5], -928710456);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][5], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][5], 0);

	DuellPunktestandTextdraw[playerid][6] = CreatePlayerTextDraw(playerid, 347.302520, 2.088874, "box");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][6], 0.000000, 2.792001);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][6], 347.164581, 0.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][6], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][6], -1);
	PlayerTextDrawUseBox(playerid, DuellPunktestandTextdraw[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, DuellPunktestandTextdraw[playerid][6], -928710456);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][6], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][6], 0);

	DuellPunktestandTextdraw[playerid][7] = CreatePlayerTextDraw(playerid, 257.900695, 2.711116, "box");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][7], 0.000000, 2.737007);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][7], 256.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][7], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][7], -1);
	PlayerTextDrawUseBox(playerid, DuellPunktestandTextdraw[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, DuellPunktestandTextdraw[playerid][7], -1061109505);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][7], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][7], 0);

	DuellPunktestandTextdraw[playerid][8] = CreatePlayerTextDraw(playerid, 393.208953, 2.711116, "box");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][8], 0.000000, 2.737007);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][8], 391.308258, 0.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][8], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][8], -1);
	PlayerTextDrawUseBox(playerid, DuellPunktestandTextdraw[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, DuellPunktestandTextdraw[playerid][8], -1061109505);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][8], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][8], 0);

	DuellPunktestandTextdraw[playerid][9] = CreatePlayerTextDraw(playerid, 264.599822, 0.022226, "X");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][9], 1.207009, 3.373333);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][9], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][9], 842203080);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][9], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][9], 0);

	DuellPunktestandTextdraw[playerid][10] = CreatePlayerTextDraw(playerid, 356.205413, 0.022226, "X");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][10], 1.207009, 3.373333);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][10], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][10], -13487416);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][10], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][10], 0);

	DuellPunktestandTextdraw[playerid][11] = CreatePlayerTextDraw(playerid, 310.802581, 0.022226, "X");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][11], 1.207009, 3.373333);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][11], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][11], -13487416);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][11], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][11], 0);

	DuellPunktestandTextdraw[playerid][12] = CreatePlayerTextDraw(playerid, 310.502624, 0.644448, "X");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][12], 1.207009, 3.373333);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][12], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][12], 842203080);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][12], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][12], 0);

	DuellPunktestandTextdraw[playerid][13] = CreatePlayerTextDraw(playerid, 304.999877, 33.022186, "10:00");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][13], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][13], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][13], -1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][13], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][13], 0);

	DuellPunktestandTextdraw[playerid][14] = CreatePlayerTextDraw(playerid, 220.000000, 32.577774, "Spieler_1");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][14], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][14], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][14], -1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][14], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][14], 0);

	DuellPunktestandTextdraw[playerid][15] = CreatePlayerTextDraw(playerid, 429.000000, 31.955551, "Spieler_2");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][15], 0.400000, 1.600000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][15], 3);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][15], -1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][15], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][15], 0);

	DuellPunktestandTextdraw[playerid][16] = CreatePlayerTextDraw(playerid, 345.603088, 31.799995, "ld_grav:timer");
	PlayerTextDrawLetterSize(playerid, DuellPunktestandTextdraw[playerid][16], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, DuellPunktestandTextdraw[playerid][16], 18.000000, 17.000000);
	PlayerTextDrawAlignment(playerid, DuellPunktestandTextdraw[playerid][16], 1);
	PlayerTextDrawColor(playerid, DuellPunktestandTextdraw[playerid][16], -1);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, DuellPunktestandTextdraw[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, DuellPunktestandTextdraw[playerid][16], 255);
	PlayerTextDrawFont(playerid, DuellPunktestandTextdraw[playerid][16], 4);
	PlayerTextDrawSetProportional(playerid, DuellPunktestandTextdraw[playerid][16], 0);
	PlayerTextDrawSetShadow(playerid, DuellPunktestandTextdraw[playerid][16], 0);

	for(new t=0;t<17;t++)
	{
		if(t >=9 && t<=12)continue;
		PlayerTextDrawShow(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPunktestandTextdraw[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][t]);
		PlayerTextDrawShow(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPunktestandTextdraw[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][t]);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(DuellIDGestartet[playerid] != -3)
	{
		KillTimer(DuellTimerID[DuellIDGestartet[playerid]]);
		for(new i=0;i<13;i++)
		{
			ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]);
			ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]);
			GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][i][0],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][i][1]);
            GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][i][0],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][i][1]);
		}
		TogglePlayerControllable(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],1);
		TogglePlayerControllable(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],1);
		SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][0],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][1],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][2]);
		SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][0],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][1],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][2]);
		for(new t=0;t<17;t++)
		{
			PlayerTextDrawHide(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPunktestandTextdraw[playerid][t]);
			PlayerTextDrawHide(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPunktestandTextdraw[playerid][t]);
		}
		if(playerid == DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID])
		{
            new Geld = strval(DuellInfo[DuellIDGestartet[playerid]][DuellWetteinsatz]);
			GivePlayerMoney(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],2*Geld);
			SendClientMessage(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],HELLBLAU,"Der andere Spieler hat das Spiel verlassen, du hast gewonnen.");
		}
		if(playerid == DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID])
		{
            new Geld = strval(DuellInfo[DuellIDGestartet[playerid]][DuellWetteinsatz]);
			GivePlayerMoney(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],2*Geld);
            SendClientMessage(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],HELLBLAU,"Der andere Spieler hat das Spiel verlassen, du hast gewonnen.");
		}
		DuellInfo[DuellIDGestartet[playerid]][DuellErstellt] = 0;
		DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID] = -1;
		DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID] = -2;
		DuellInfo[DuellIDGestartet[playerid]][DuellGestartet] = 0;
		DuellInfo[DuellIDGestartet[playerid]][DuellPunkteErsteller] = 0;
		DuellInfo[DuellIDGestartet[playerid]][DuellPunkteBeitreter] = 0;
		DuellInfo[DuellIDGestartet[playerid]][DuellMap][0] = EOS; //String leeren (EOS = End Of String)
		DuellInfo[DuellIDGestartet[playerid]][DuellWetteinsatz][0] = EOS;
		DuellInfo[DuellIDGestartet[playerid]][DuellWaffen][0] = EOS;
		DuellInfo[DuellIDGestartet[playerid]][DuellName][0] = EOS;
		DuellInfo[DuellIDGestartet[playerid]][DuellErstellerName][0] = EOS;
		DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterName][0] = EOS;
		DuellIDGestartet[playerid] = -3;
		return 1;
	}
	DuellInfo[DuellID[playerid]][DuellErstellt] = 0;
	DuellInfo[DuellID[playerid]][DuellErstellerPID] = -1;
	DuellInfo[DuellID[playerid]][DuellBeitreterPID] = -2;
	DuellInfo[DuellID[playerid]][DuellGestartet] = 0;
	DuellInfo[DuellID[playerid]][DuellMap][0] = EOS; //String leeren (EOS = End Of String)
	DuellInfo[DuellID[playerid]][DuellWetteinsatz][0] = EOS;
	DuellInfo[DuellID[playerid]][DuellWaffen][0] = EOS;
	DuellInfo[DuellID[playerid]][DuellName][0] = EOS;
	DuellInfo[DuellID[playerid]][DuellErstellerName][0] = EOS;
	DuellInfo[DuellID[playerid]][DuellBeitreterName][0] = EOS;
	DuellID[playerid] = -1;
	DuellIDVorschau[playerid] = -2;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(DuellIDGestartet[playerid] != -3)
	{
		if(playerid == DuellInfo[DuellID[playerid]][DuellErstellerPID])
		{
			DuellInfo[DuellIDGestartet[playerid]][DuellPunkteErsteller]++;
			PlayerTextDrawShow(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPunktestandTextdraw[playerid][9]);
		}
		if(playerid == DuellInfo[DuellID[playerid]][DuellBeitreterPID])
		{
			DuellInfo[DuellIDGestartet[playerid]][DuellPunkteBeitreter]++;
			PlayerTextDrawShow(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPunktestandTextdraw[playerid][10]);
		}
		if(DuellInfo[DuellIDGestartet[playerid]][DuellPunkteErsteller] == 2 || DuellInfo[DuellIDGestartet[playerid]][DuellPunkteBeitreter] == 2)
		{
			new DuellSiegerPID, DuellSiegerName[128];
			if(DuellInfo[DuellIDGestartet[playerid]][DuellPunkteErsteller] == 2)DuellSiegerPID = DuellInfo[DuellIDGestartet[playerid]][DuellPunkteErsteller];
			if(DuellInfo[DuellIDGestartet[playerid]][DuellPunkteBeitreter] == 2)DuellSiegerPID = DuellInfo[DuellIDGestartet[playerid]][DuellPunkteBeitreter];
			new string[128];
			GetPlayerName(DuellSiegerPID,DuellSiegerName,128);
			format(string,sizeof(string),"%s hat das Duell gewonnen.",DuellSiegerName);
			SendClientMessage(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],HELLBLAU,string);
			SendClientMessage(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],HELLBLAU,string);
			KillTimer(DuellTimerID[DuellIDGestartet[playerid]]);
			for(new i=0;i<13;i++)
			{
				ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]);
				ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]);
				GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][i][0],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][i][1]);
	            GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][i][0],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][i][1]);
			}
			SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][0],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][1],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][2]);
			SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][0],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][1],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][2]);
			for(new t=0;t<17;t++)
			{
				PlayerTextDrawHide(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPunktestandTextdraw[playerid][t]);
				PlayerTextDrawHide(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPunktestandTextdraw[playerid][t]);
			}
            new Geld = strval(DuellInfo[DuellIDGestartet[playerid]][DuellWetteinsatz]);
			GivePlayerMoney(DuellSiegerPID,2*Geld);
			DuellInfo[DuellIDGestartet[playerid]][DuellErstellt] = 0;
			DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID] = -1;
			DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID] = -2;
			DuellInfo[DuellIDGestartet[playerid]][DuellGestartet] = 0;
			DuellInfo[DuellIDGestartet[playerid]][DuellPunkteErsteller] = 0;
			DuellInfo[DuellIDGestartet[playerid]][DuellPunkteBeitreter] = 0;
			DuellInfo[DuellIDGestartet[playerid]][DuellMap][0] = EOS; //String leeren (EOS = End Of String)
			DuellInfo[DuellIDGestartet[playerid]][DuellWetteinsatz][0] = EOS;
			DuellInfo[DuellIDGestartet[playerid]][DuellWaffen][0] = EOS;
			DuellInfo[DuellIDGestartet[playerid]][DuellName][0] = EOS;
			DuellInfo[DuellIDGestartet[playerid]][DuellErstellerName][0] = EOS;
			DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterName][0] = EOS;
			DuellIDGestartet[playerid] = -3;
			return 1;
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(DuellIDGestartet[playerid] != -3)
	{
		new DuellSpawnID;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Lagerhalle"))DuellSpawnID = 0;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Park"))DuellSpawnID = 2;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Platz"))DuellSpawnID = 4;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Stadium"))DuellSpawnID = 6;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Haus"))DuellSpawnID = 8;
		SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellSpawns[DuellSpawnID][0],DuellSpawns[DuellSpawnID][1],DuellSpawns[DuellSpawnID][2]);
		SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellSpawns[DuellSpawnID+1][0],DuellSpawns[DuellSpawnID+1][1],DuellSpawns[DuellSpawnID+1][2]);
		SetPlayerFacingAngle(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellSpawns[DuellSpawnID][3]);
		SetPlayerFacingAngle(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellSpawns[DuellSpawnID+1][3]);
		SetPlayerCameraLookAt(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellSpawns[DuellSpawnID+1][0],DuellSpawns[DuellSpawnID+1][1],DuellSpawns[DuellSpawnID+1][2]);
		SetPlayerCameraLookAt(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellSpawns[DuellSpawnID][0],DuellSpawns[DuellSpawnID][1],DuellSpawns[DuellSpawnID][2]);		SetPlayerVirtualWorld(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellIDGestartet[playerid]);
		SetPlayerVirtualWorld(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellIDGestartet[playerid]);
		SetPlayerVirtualWorld(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellIDGestartet[playerid]);
        new DuellWaffenID[][] =
		{
			{4,"Messer"}, // {WaffenID, "Waffe"}
			{5,"Baseballschl�ger"},
			{9,"Kettens�ge"},
			{8,"Katana"},
			{16,"Granaten"},
			{17,"Rauchgranaten"},
			{18,"Molotovs"},
			{22,"Pistolen"},
			{23,"Silenced Pistol"},
			{24,"Desert Eagle"},
			{25,"Schrotflinte"},
			{26,"Shawnoff Shotgun"},
			{27,"Combat Shotgun"},
			{28,"Uzi"},
			{29,"MP5"},
			{30,"AK47"},
			{31,"M4"},
			{32,"Tec9"},
			{33,"Gewehr"},
			{34,"Sniper"},
			{35,"Raketenwerfer"},
			{37,"Flammenwerfer"},
			{38,"Minigun"},
			{39,"C4"},
			{41,"Pfefferspray"},
			{42,"Feuerl�scher"}
		};
		new DuellGestartetWaffenID[26];
		new DuellMunition[26];
		strini(DuellGestartetWaffenID,26,-1);
		strini(DuellMunition,26,-2);
		for(new d=0;d<26;d++)
		{
			if(strfind(DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],DuellWaffenID[d][1]) != -1)
			{
			    DuellGestartetWaffenID[d] = DuellWaffenID[d][0];
			    new StringWaffenAnfang = strfind(DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],DuellWaffenID[d][1]);
                new StringAnfang = strfind(DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],"(",false,StringWaffenAnfang);
				new StringEnde = strfind(DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],")",false,StringAnfang);
				new StringMunition[128];
				strmid(StringMunition,DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],StringAnfang,StringEnde);
				DuellMunition[d] = strval(StringMunition);
			}
		}
		ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]);
		ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]);
		for(new w=0;w<26;w++)
		{
		    if(DuellGestartetWaffenID[w] != -1 && DuellMunition[w] != -2)
		    {
				GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellGestartetWaffenID[w],DuellMunition[w]);
				GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellGestartetWaffenID[w],DuellMunition[w]);
		    }
		}
		SetTimerEx("DuellCountDown",1000,false,"i",playerid);
		TogglePlayerControllable(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],0);
		TogglePlayerControllable(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],0);
	}
	return 1;
}

forward DuellCountDown(playerid);
public DuellCountDown(playerid)
{
	DuellCountDownVar[DuellIDGestartet[playerid]]--;
	new str[128];
	if(DuellCountDownVar[DuellIDGestartet[playerid]] == 0)
	{
	    DuellCountDownVar[DuellIDGestartet[playerid]] = 4;
		TogglePlayerControllable(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],1);
		TogglePlayerControllable(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],1);
	}
	else
	{
	   format(str, sizeof(str), "Count Down: %d", DuellCountDownVar[DuellIDGestartet[playerid]]);
	   GameTextForPlayer(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],str, 1000, 3);
	   GameTextForPlayer(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],str, 1000, 3);
	}
	return 1;
}

ocmd:duel(playerid,params[])
{
	if(DuellIDGestartet[playerid] != -3)
	{
	    SendClientMessage(playerid,HELLBLAU,"Du bist schon einem Duell beigetreten.");
	    return 1;
	}
	new string[2000];
	for(new d=0;d<20;d++)
	{
		if(isnull(DuellInfo[d][DuellName]) || DuellInfo[d][DuellGestartet] == 1)continue;
		format(string,sizeof(string),"%s\n%s\n",string,DuellInfo[d][DuellName]);
	}
	if(isnull(string))format(string,128,"Kein Spiel ge�ffnet");
	ShowPlayerDialog(playerid,DUELL,DIALOG_STYLE_LIST,"Duelle",string,"Infos","Erstellen");
	CallLocalFunction("DuellDialogAbbrechenTXDLaden","i",playerid);
	PlayerTextDrawShow(playerid,DuellDialogAbbrechenTextdraw[playerid][0]);
	PlayerTextDrawShow(playerid,DuellDialogAbbrechenTextdraw[playerid][1]);
	SelectTextDraw(playerid, 0xFF4040AA);
	return 1;
}

ocmd:startduel(playerid,params[])
{
	for(new d=0;d<20;d++)
	{
	    if((DuellInfo[d][DuellErstellerPID] == playerid || DuellInfo[d][DuellBeitreterPID] == playerid) && DuellInfo[d][DuellBeitreterPID] != -2 )
	    {
			DuellIDGestartet[playerid] = d;
			SendClientMessage(playerid,HELLBLAU,"Falls der andere Spieler auch /startduel eingibt wird das Spiel gestartet.");
	    }
	}
	if(DuellIDGestartet[playerid] == -3)
	{
	    if(DuellID[playerid] == -1)SendClientMessage(playerid,HELLBLAU,"Du musst erst einem Duell beitreten oder eins erstellen.");
		else SendClientMessage(playerid,HELLBLAU,"Jemand muss erst deinem Duell beitreten.");
		return 1;
	}
	StartduelEingegeben[playerid] = 1;
	if(DuellInfo[DuellIDGestartet[playerid]][DuellGestartet] == 1)return 1;
	if(StartduelEingegeben[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]] == 1 && StartduelEingegeben[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]] == 1)
	{
		StartduelEingegeben[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]] = 0;
		StartduelEingegeben[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]] = 0;
		for (new i=0;i<13;i++)
		{
		    GetPlayerWeaponData(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],i,DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][i][0],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][i][1]);
            GetPlayerWeaponData(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],i,DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][i][0],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][i][1]);
		}
		GetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][0],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][1],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][2]);
		GetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][0],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][1],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][2]);
        new Geld = strval(DuellInfo[DuellIDGestartet[playerid]][DuellWetteinsatz]);
		GivePlayerMoney(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],-Geld);
		GivePlayerMoney(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],-Geld);
		new DuellSpawnID;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Lagerhalle"))DuellSpawnID = 0;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Park"))DuellSpawnID = 2;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Platz"))DuellSpawnID = 4;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Stadium"))DuellSpawnID = 6;
		if(!strcmp(DuellInfo[DuellIDGestartet[playerid]][DuellMap],"Haus"))DuellSpawnID = 8;
		SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellSpawns[DuellSpawnID][0],DuellSpawns[DuellSpawnID][1],DuellSpawns[DuellSpawnID][2]);
		SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellSpawns[DuellSpawnID+1][0],DuellSpawns[DuellSpawnID+1][1],DuellSpawns[DuellSpawnID+1][2]);
		SetPlayerFacingAngle(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellSpawns[DuellSpawnID][3]);
		SetPlayerFacingAngle(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellSpawns[DuellSpawnID+1][3]);
		SetPlayerCameraLookAt(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellSpawns[DuellSpawnID+1][0],DuellSpawns[DuellSpawnID+1][1],DuellSpawns[DuellSpawnID+1][2]);
		SetPlayerCameraLookAt(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellSpawns[DuellSpawnID][0],DuellSpawns[DuellSpawnID][1],DuellSpawns[DuellSpawnID][2]);		SetPlayerVirtualWorld(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellIDGestartet[playerid]);
		SetPlayerVirtualWorld(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellIDGestartet[playerid]);
		CallLocalFunction("DuellPunktestandTXDLaden","i",playerid);
		new DuellWaffenID[][] =
		{
			{4,"Messer"}, // {WaffenID, "Waffe"}
			{5,"Baseballschl�ger"},
			{9,"Kettens�ge"},
			{8,"Katana"},
			{16,"Granaten"},
			{17,"Rauchgranaten"},
			{18,"Molotovs"},
			{22,"Pistolen"},
			{23,"Silenced Pistol"},
			{24,"Desert Eagle"},
			{25,"Schrotflinte"},
			{26,"Shawnoff Shotgun"},
			{27,"Combat Shotgun"},
			{28,"Uzi"},
			{29,"MP5"},
			{30,"AK47"},
			{31,"M4"},
			{32,"Tec9"},
			{33,"Gewehr"},
			{34,"Sniper"},
			{35,"Raketenwerfer"},
			{37,"Flammenwerfer"},
			{38,"Minigun"},
			{39,"C4"},
			{41,"Pfefferspray"},
			{42,"Feuerl�scher"}
		};
		new DuellGestartetWaffenID[26];
		new DuellMunition[26];
		strini(DuellGestartetWaffenID,26,-1);
		strini(DuellMunition,26,-2);
		for(new d=0;d<26;d++)
		{
			if(strfind(DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],DuellWaffenID[d][1]) != -1)
			{
			    DuellGestartetWaffenID[d] = DuellWaffenID[d][0];
			    new StringWaffenAnfang = strfind(DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],DuellWaffenID[d][1]);
                new StringAnfang = strfind(DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],"(",false,StringWaffenAnfang);
				new StringEnde = strfind(DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],")",false,StringAnfang);
				new StringMunition[128];
				strmid(StringMunition,DuellInfo[DuellIDGestartet[playerid]][DuellWaffen],StringAnfang,StringEnde);
				DuellMunition[d] = strval(StringMunition);
			}
		}
		ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]);
		ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]);
		for(new w=0;w<26;w++)
		{
		    if(DuellGestartetWaffenID[w] != -1 && DuellMunition[w] != -2)
		    {
				GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellGestartetWaffenID[w],DuellMunition[w]);
				GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellGestartetWaffenID[w],DuellMunition[w]);
		    }
		}
		SetTimerEx("DuellCountDown",1000,false,"i",playerid);
		TogglePlayerControllable(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],0);
		TogglePlayerControllable(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],0);
	}
	SetTimerEx("StartduelAbfrage",20000,false,"i",playerid);
	return 1;
}

public StartduelAbfrage(playerid)
{
	if(StartduelEingegeben[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]] == 0 || StartduelEingegeben[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]] == 0)
	{
		StartduelEingegeben[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]] = 0;
		StartduelEingegeben[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]] = 0;
		if(playerid == DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID])DuellIDGestartet[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]] = -3;
	    if(playerid == DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID])DuellIDGestartet[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]] = -3;
		DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID] = -2;
		DuellIDGestartet[playerid] = -3;
	}
	return 1;
}

public DuellTimer(playerid)
{
	if(DuellInfo[DuellIDGestartet[playerid]][DuellTimerMinute] == 0)
	{
	    SendClientMessage(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],HELLBLAU,"Die Zeit ist abgelaufen, beide Spieler bekommen ihren Wetteinsatz wieder");
	    SendClientMessage(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],HELLBLAU,"Die Zeit ist abgelaufen, beide Spieler bekommen ihren Wetteinsatz wieder");
		KillTimer(DuellTimerID[DuellIDGestartet[playerid]]);
		for(new i=0;i<13;i++)
		{
			ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]);
			ResetPlayerWeapons(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]);
			GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][i][0],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][i][1]);
            GivePlayerWeapon(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][i][0],DuellWaffenInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][i][1]);
		}
		SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][0],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][1],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID]][2]);
		SetPlayerPos(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][0],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][1],DuellPosInfo[DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID]][2]);
		for(new t=0;t<17;t++)
		{
			PlayerTextDrawHide(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPunktestandTextdraw[playerid][t]);
			PlayerTextDrawHide(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPunktestandTextdraw[playerid][t]);
		}
        new Geld = strval(DuellInfo[DuellIDGestartet[playerid]][DuellWetteinsatz]);
		GivePlayerMoney(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],Geld);
		GivePlayerMoney(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],Geld);
		DuellInfo[DuellIDGestartet[playerid]][DuellErstellt] = 0;
		DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID] = -1;
		DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID] = -2;
		DuellInfo[DuellIDGestartet[playerid]][DuellGestartet] = 0;
		DuellInfo[DuellIDGestartet[playerid]][DuellPunkteErsteller] = 0;
		DuellInfo[DuellIDGestartet[playerid]][DuellPunkteBeitreter] = 0;
		DuellInfo[DuellIDGestartet[playerid]][DuellMap][0] = EOS; //String leeren (EOS = End Of String)
		DuellInfo[DuellIDGestartet[playerid]][DuellWetteinsatz][0] = EOS;
		DuellInfo[DuellIDGestartet[playerid]][DuellWaffen][0] = EOS;
		DuellInfo[DuellIDGestartet[playerid]][DuellName][0] = EOS;
		DuellInfo[DuellIDGestartet[playerid]][DuellErstellerName][0] = EOS;
		DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterName][0] = EOS;
		DuellIDGestartet[playerid] = -3;
		return 1;
	}
	if(DuellInfo[DuellIDGestartet[playerid]][DuellTimerSekunde] == 0)DuellInfo[DuellIDGestartet[playerid]][DuellTimerMinute]--;
	DuellInfo[DuellIDGestartet[playerid]][DuellTimerSekunde]--;
	new string[6];
	format(string,sizeof(string),"%i:%i",DuellInfo[DuellIDGestartet[playerid]][DuellTimerMinute],DuellInfo[DuellIDGestartet[playerid]][DuellTimerSekunde]);
	PlayerTextDrawSetString(DuellInfo[DuellIDGestartet[playerid]][DuellErstellerPID],DuellPunktestandTextdraw[playerid][13],string);
	PlayerTextDrawSetString(DuellInfo[DuellIDGestartet[playerid]][DuellBeitreterPID],DuellPunktestandTextdraw[playerid][13],string);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DUELL)
	{
		if(response == 1)
		{
        	printf("listitem = %i",listitem);
			for(new d=0;d<20;d++)
			{
				printf("DuellInfo = %i",DuellInfo[d][DuellErstellt]);
				if(listitem == d && DuellInfo[d][DuellErstellt] == 1)
			    {
                    DuellIDVorschau[playerid] = d;
					new string[500];
					format(string,sizeof(string),"Map: %s\nWetteinsatz: %s\nWaffen: %s",DuellInfo[DuellID[playerid]][DuellMap],DuellInfo[DuellID[playerid]][DuellWetteinsatz],DuellInfo[DuellID[playerid]][DuellWaffen]);
					if(DuellID[playerid] == d)
					{
						ShowPlayerDialog(playerid,DUELL6,DIALOG_STYLE_LIST,"Duell Infos",string,"L�schen","Zur�ck");
						return 1;
					}
					ShowPlayerDialog(playerid,DUELL6,DIALOG_STYLE_LIST,"Duell Infos",string,"Beitreten","Zur�ck");
				}
			}
			if(listitem == 0 && DuellInfo[0][DuellErstellt] == 0) //Keine Spiele offen
			{
				PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][0]);
				PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][1]);
	            CancelSelectTextDraw(playerid);
			}
		}
		if(response == 0)
		{
			for(new d=0;d<20;d++)
			{
				if(DuellInfo[d][DuellErstellt] == 0)
				{
					DuellID[playerid] = d;
					DuellInfo[d][DuellErstellt] = 1;
					DuellInfo[d][DuellErstellerPID] = playerid;
					break;
				}
			}
			new string[600];
			if(isnull(DuellInfo[DuellID[playerid]][DuellMap]))format(DuellInfo[DuellID[playerid]][DuellMap],20,"Stadium");
   			if(isnull(DuellInfo[DuellID[playerid]][DuellWetteinsatz]))format(DuellInfo[DuellID[playerid]][DuellWetteinsatz],5,"100$");
			format(string,sizeof(string),"Map: %s\nWetteinsatz: %s\nWaffen: %s",DuellInfo[DuellID[playerid]][DuellMap],DuellInfo[DuellID[playerid]][DuellWetteinsatz],DuellInfo[DuellID[playerid]][DuellWaffen]);
			ShowPlayerDialog(playerid,DUELL2,DIALOG_STYLE_LIST,"Duell erstellen",string,"�ndern","Erstellen");
		}
		return 1;
	}
	if(dialogid == DUELL2)
	{
		if(response == 0)
		{
			for(new d=0;d<20;d++)
			{
			    if(DuellInfo[d][DuellErstellerPID] == playerid && d != DuellID[playerid])
			    {
						format(DuellInfo[d][DuellMap],20,"%s",DuellInfo[DuellID[playerid]][DuellMap]);
						format(DuellInfo[d][DuellWetteinsatz],6,"%s",DuellInfo[DuellID[playerid]][DuellWetteinsatz]);
						format(DuellInfo[d][DuellWaffen],300,"%s",DuellInfo[DuellID[playerid]][DuellWaffen]);
		    			DuellInfo[DuellID[playerid]][DuellErstellt] = 0;
						DuellInfo[DuellID[playerid]][DuellErstellerPID] = -1;
						DuellInfo[DuellID[playerid]][DuellBeitreterPID] = -2;
						DuellInfo[DuellID[playerid]][DuellMap][0] = EOS; //String leeren (EOS = End Of String)
						DuellInfo[DuellID[playerid]][DuellWetteinsatz][0] = EOS;
						DuellInfo[DuellID[playerid]][DuellWaffen][0] = EOS;
						DuellInfo[DuellID[playerid]][DuellName][0] = EOS;
						DuellInfo[DuellID[playerid]][DuellErstellerName][0] = EOS;
						DuellInfo[DuellID[playerid]][DuellBeitreterName][0] = EOS;
						DuellID[playerid] = d;
						break;
			    }
			}
			DuellInfo[DuellID[playerid]][DuellErstellt] = 1;
			DuellInfo[DuellID[playerid]][DuellErstellerPID] = playerid;
			GetPlayerName(playerid,DuellInfo[DuellID[playerid]][DuellErstellerName],128);
			format(DuellInfo[DuellID[playerid]][DuellName],128,"Duell von %s (Map: %s, Einsatz: %s)",DuellInfo[DuellID[playerid]][DuellErstellerName],DuellInfo[DuellID[playerid]][DuellMap],DuellInfo[DuellID[playerid]][DuellWetteinsatz]);
            SendClientMessage(playerid,HELLBLAU,"Duell erfolgreich erstellt.");
            PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][0]);
			PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][1]);
            CancelSelectTextDraw(playerid);
   			return 1;
		}
	    if(listitem == 0)
	    {
	        ShowPlayerDialog(playerid,DUELL3,DIALOG_STYLE_LIST,"Map Auswahl","Stadium\nHaus\nPlatz\nLagerhalle\nPark","Best�tigen","Abbrechen");
  		}
	    if(listitem == 1)
	    {
	        ShowPlayerDialog(playerid,DUELL4,DIALOG_STYLE_LIST,"Wetteinsatz Auswahl","Kein Wetteinsatz\n100$\n200$\n300$\n400$\n500$\n1000$","Best�tigen","Abbrechen");
	    }
	    if(listitem == 2)
	    {
	        ShowPlayerDialog(playerid,DUELL5,DIALOG_STYLE_LIST,"Waffen Auswahl","Messer\nBaseballschl�ger\nKettens�ge\nKatana\nGranaten\nRauchgranaten\nMolotovs\nPistolen\nSilenced Pistol\nDesert Eagle\nSchrotflinte\nShawnoff Shotgun\nCombat Shotgun\nUzi\nMP5\nAK47\nM4\nTec9\nGewehr\nSniper\nRaketenwerfer\nFlammenwerfer\nMinigun\nC4\nPfefferspray\nFeuerl�scher","Best�tigen","Abbrechen");
	    }
        return 1;
	}
	if(dialogid == DUELL3)
	{
		if(response == 0)
		{
			return 1;
		}
		new DuellMapID[][] =
		{
			{"Stadium"},
			{"Haus"},
			{"Platz"},
			{"Lagerhalle"},
			{"Park"}
		};
		for(new d=0;d<26;d++)
		{
		    if(listitem == d)
		    {
				format(DuellInfo[DuellID[playerid]][DuellMap],20,"%s",DuellMapID[d]);
		        new string[600];
				format(string,sizeof(string),"Map: %s\nWetteinsatz: %s\nWaffen: %s",DuellInfo[DuellID[playerid]][DuellMap],DuellInfo[DuellID[playerid]][DuellWetteinsatz],DuellInfo[DuellID[playerid]][DuellWaffen]);
				ShowPlayerDialog(playerid,DUELL2,DIALOG_STYLE_LIST,"Duell erstellen",string,"�ndern","Erstellen");
			}
  		}
        return 1;
	}
	if(dialogid == DUELL4)
	{
		if(response == 0)
		{
			return 1;
		}
		new DuellWetteinsatzID[][] =
		{
			{"0$"},
			{"100$"},
			{"200$"},
			{"300$"},
			{"400$"},
			{"500$"},
			{"1000$"}
		};
		for(new d=0;d<26;d++)
		{
		    if(listitem == d)
		    {
				format(DuellInfo[DuellID[playerid]][DuellWetteinsatz],6,"%s",DuellWetteinsatzID[d]);
		        new string[600];
				format(string,sizeof(string),"Map: %s\nWetteinsatz: %s\nWaffen: %s",DuellInfo[DuellID[playerid]][DuellMap],DuellInfo[DuellID[playerid]][DuellWetteinsatz],DuellInfo[DuellID[playerid]][DuellWaffen]);
				ShowPlayerDialog(playerid,DUELL2,DIALOG_STYLE_LIST,"Duell erstellen",string,"�ndern","Erstellen");
			}
  		}
        return 1;
	}
	if(dialogid == DUELL5)
	{
		if(response == 0)
		{
			return 1;
		}
		new DuellWaffenID[][] = //[listitem][1] => [0] = WaffenSlot und [1] = "Waffe"
		{
			{1,"Messer"}, // {WaffenSlotID, "Waffe"}
			{1,"Baseballschl�ger"},
			{1,"Kettens�ge"},
			{1,"Katana"},
			{8,"Granaten"},
			{8,"Rauchgranaten"},
			{8,"Molotovs"},
			{2,"Pistolen"},
			{2,"Silenced Pistol"},
			{2,"Desert Eagle"},
			{3,"Schrotflinte"},
			{3,"Shawnoff Shotgun"},
			{3,"Combat Shotgun"},
			{4,"Uzi"},
			{4,"MP5"},
			{5,"AK47"},
			{5,"M4"},
			{4,"Tec9"},
			{6,"Gewehr"},
			{6,"Sniper"},
			{7,"Raketenwerfer"},
			{7,"Flammenwerfer"},
			{7,"Minigun"},
			{8,"C4"},
			{9,"Pfefferspray"},
			{9,"Feuerl�scher"}
		};
		for(new d=0;d<26;d++)
		{
		    if(listitem == d)
		    {
				for(new i=0;i<26;i++)
				{
				    if(DuellWaffenID[d][0] == DuellWaffenID[i][0])
				    {
                        new StringAnfang = strfind(DuellInfo[DuellID[playerid]][DuellWaffen],DuellWaffenID[i][1]);
                        new StringEnde = strfind(DuellInfo[DuellID[playerid]][DuellWaffen],")",false,StringAnfang);
						if(StringAnfang == -1 || d == i)continue;
	                    if(StringEnde+1 == strlen(DuellInfo[DuellID[playerid]][DuellWaffen]) && StringAnfang-2 > 0)strdel(DuellInfo[DuellID[playerid]][DuellWaffen],StringAnfang-2,StringEnde+2); //Komma entfernen, falls Waffe am Ende steht
	                    if(StringEnde+1 == strlen(DuellInfo[DuellID[playerid]][DuellWaffen]) && StringAnfang-2 < 0)strdel(DuellInfo[DuellID[playerid]][DuellWaffen],StringAnfang,StringEnde+2); //Komma entfernen, falls Waffe am Ende steht
						if(StringEnde+1 != strlen(DuellInfo[DuellID[playerid]][DuellWaffen])) strdel(DuellInfo[DuellID[playerid]][DuellWaffen],StringAnfang,StringEnde+3);
					}
				}
				if(strfind(DuellInfo[DuellID[playerid]][DuellWaffen],DuellWaffenID[d][1]) != -1)
				{
                    new StringAnfang = strfind(DuellInfo[DuellID[playerid]][DuellWaffen],DuellWaffenID[d][1]);
					new StringEnde = strfind(DuellInfo[DuellID[playerid]][DuellWaffen],")",false,StringAnfang);
					if(StringEnde+1 == strlen(DuellInfo[DuellID[playerid]][DuellWaffen]))strdel(DuellInfo[DuellID[playerid]][DuellWaffen],StringAnfang-2,StringEnde+2); //Komma entfernen, falls Waffe am Ende steht
					else strdel(DuellInfo[DuellID[playerid]][DuellWaffen],StringAnfang,StringEnde+3);
				}
    			if(strfind(DuellInfo[DuellID[playerid]][DuellWaffen],DuellWaffenID[d][1]) == -1)
				{
					if(!isnull(DuellInfo[DuellID[playerid]][DuellWaffen]))format(DuellInfo[DuellID[playerid]][DuellWaffen],300,"%s, %s",DuellInfo[DuellID[playerid]][DuellWaffen],DuellWaffenID[d][1]);
					else format(DuellInfo[DuellID[playerid]][DuellWaffen],500,"%s",DuellWaffenID[d][1]);
				}
				ShowPlayerDialog(playerid,DUELL7,DIALOG_STYLE_INPUT,"Duell erstellen","Bitte gebe die gew�nschte Munitionsanzahl ein.","Best�tigen","Zur�ck");
			}
  		}
        return 1;
	}
	if(dialogid == DUELL6)
	{
		if(response == 1)
		{
			if(playerid == DuellInfo[DuellIDVorschau[playerid]][DuellErstellerPID])
			{
    			DuellInfo[DuellID[playerid]][DuellErstellt] = 0;
				DuellInfo[DuellID[playerid]][DuellErstellerPID] = -1;
				DuellInfo[DuellID[playerid]][DuellBeitreterPID] = -2;
				DuellInfo[DuellID[playerid]][DuellMap][0] = EOS; //String leeren (EOS = End Of String)
				DuellInfo[DuellID[playerid]][DuellWetteinsatz][0] = EOS;
				DuellInfo[DuellID[playerid]][DuellWaffen][0] = EOS;
				DuellInfo[DuellID[playerid]][DuellName][0] = EOS;
				DuellInfo[DuellID[playerid]][DuellErstellerName][0] = EOS;
				DuellID[playerid] = -1;
       			PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][0]);
				PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][1]);
	            CancelSelectTextDraw(playerid);
	            DuellIDVorschau[playerid] = -2;
	            SendClientMessage(playerid,HELLBLAU,"Duell erfolgreich gel�scht.");
				return 1;
			}
			if(DuellInfo[DuellIDVorschau[playerid]][DuellBeitreterPID] != -2)
			{
			    SendClientMessage(playerid,HELLBLAU,"Diesem Duell ist soeben schon jemand beigetreten.");
			    return 1;
			}
			SendClientMessage(playerid,HELLBLAU,"Gebe /startduel ein, um das Duell zu starten.");
			SendClientMessage(DuellInfo[DuellIDVorschau[playerid]][DuellErstellerPID],HELLBLAU,"Gebe /startduel ein, um das Duell zu starten.");
            GetPlayerName(playerid,DuellInfo[DuellID[playerid]][DuellBeitreterName],128);
			DuellInfo[DuellIDVorschau[playerid]][DuellBeitreterPID] = playerid;
   			PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][0]);
			PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][1]);
			CancelSelectTextDraw(playerid);
			DuellIDVorschau[playerid] = -2;
		}
		if(response == 0)
		{
			new string[2000];
			for(new d=0;d<20;d++)
			{
				if(isnull(DuellInfo[d][DuellName]))continue;
				format(string,sizeof(string),"%s\n%s\n",string,DuellInfo[d][DuellName]);
			}
			if(isnull(string))format(string,128,"Kein Spiel ge�ffnet");
			ShowPlayerDialog(playerid,DUELL,DIALOG_STYLE_LIST,"Duelle",string,"Infos","Erstellen");
			DuellIDVorschau[playerid] = -2;
		}
        return 1;
	}
	if(dialogid == DUELL7)
	{
		if(response == 1 && !isnull(inputtext) && strval(inputtext) != '0' && strval(inputtext) != 0)
		{
			new WaffenMunition = strval(inputtext);
			if(WaffenMunition > 9999)WaffenMunition = 9999;
			format(DuellInfo[DuellID[playerid]][DuellWaffen],500,"%s(%i)",DuellInfo[DuellID[playerid]][DuellWaffen],WaffenMunition);
		}
		if(response == 0 || (response == 1 && (isnull(inputtext) || strval(inputtext) == '0' || strval(inputtext) == 0)))
		{
			new LetztesKomma;
			for(new k=20;k>0;k--)
			{
				if(strfind(DuellInfo[DuellID[playerid]][DuellWaffen],",",false,strlen(DuellInfo[DuellID[playerid]][DuellWaffen])-k) == -1)continue;
				LetztesKomma = strfind(DuellInfo[DuellID[playerid]][DuellWaffen],",",false,strlen(DuellInfo[DuellID[playerid]][DuellWaffen])-k);
			}
			strdel(DuellInfo[DuellID[playerid]][DuellWaffen],LetztesKomma,strlen(DuellInfo[DuellID[playerid]][DuellWaffen]));
		}
		new string[600];
		format(string,sizeof(string),"Map: %s\nWetteinsatz: %s\nWaffen: %s",DuellInfo[DuellID[playerid]][DuellMap],DuellInfo[DuellID[playerid]][DuellWetteinsatz],DuellInfo[DuellID[playerid]][DuellWaffen]);
		ShowPlayerDialog(playerid,DUELL2,DIALOG_STYLE_LIST,"Duell erstellen",string,"�ndern","Erstellen");
        return 1;
	}
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid == PlayerText:DuellDialogAbbrechenTextdraw[playerid][1])
    {
		ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", " ");
		PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][0]);
		PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][1]);
  		CancelSelectTextDraw(playerid);
		for(new d=0;d<20;d++)
		{
			if(DuellInfo[d][DuellErstellerPID] == playerid && d != DuellID[playerid])
			{
					DuellInfo[DuellID[playerid]][DuellErstellt] = 0;
					DuellInfo[DuellID[playerid]][DuellErstellerPID] = -1;
					DuellInfo[DuellID[playerid]][DuellBeitreterPID] = -2;
					DuellInfo[DuellID[playerid]][DuellMap][0] = EOS; //String leeren (EOS = End Of String)
					DuellInfo[DuellID[playerid]][DuellWetteinsatz][0] = EOS;
					DuellInfo[DuellID[playerid]][DuellWaffen][0] = EOS;
					DuellInfo[DuellID[playerid]][DuellName][0] = EOS;
					DuellInfo[DuellID[playerid]][DuellErstellerName][0] = EOS;
					DuellID[playerid] = d;
					break;
			}
		}
		DuellIDVorschau[playerid] = -2;
		return 1;
	}
    return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", " ");
	PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][0]);
	PlayerTextDrawHide(playerid,DuellDialogAbbrechenTextdraw[playerid][1]);
	for(new d=0;d<20;d++)
	{
		if(DuellInfo[d][DuellErstellerPID] == playerid && d != DuellID[playerid])
		{
				DuellInfo[DuellID[playerid]][DuellErstellt] = 0;
				DuellInfo[DuellID[playerid]][DuellErstellerPID] = -1;
				DuellInfo[DuellID[playerid]][DuellBeitreterPID] = -2;
				DuellInfo[DuellID[playerid]][DuellMap][0] = EOS; //String leeren (EOS = End Of String)
				DuellInfo[DuellID[playerid]][DuellWetteinsatz][0] = EOS;
				DuellInfo[DuellID[playerid]][DuellWaffen][0] = EOS;
				DuellInfo[DuellID[playerid]][DuellName][0] = EOS;
				DuellInfo[DuellID[playerid]][DuellErstellerName][0] = EOS;
				DuellID[playerid] = d;
				break;
		}
	}
	DuellIDVorschau[playerid] = -2;
	return 0;
}

stock strini(string[],endpos,input)
{
	for(new s=0;s<endpos;s++)
	{
	    string[s] = input;
	}
	return string;
}

public OnFilterScriptExit()
{

	return 1;
}
