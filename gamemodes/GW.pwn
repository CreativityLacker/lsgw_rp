#include <a_samp>
#include <colweap>
#include <zcmd>
#include <sscanf2>

#define SUCCESS 1
#define FAIL    2

#define SERVER_SAMP_VERSION 	"0.3x"
#define SERVER_NAME             "Los Santos: GangWars"
#define SERVER_VERSION 			"BETA"
#define SERVER_WEBSITE 			"www.exp-gaming.net"
#define SERVER_IRC              "www.irc.exp-gaming.net"

#define SERVER_SCRIPTER 		"CreativityLacker"
#define SERVER_MAPPER 			"Pokerface"

#define SERVER_MAP              "Build One"
#define SERVER_GAMEMODE         "TDM"

#define SERVER_MAX_TEAMS 		7
#define SERVER_MAX_HOUSES       25

#define GROVE 					0
#define BALLA 					1
#define VAGOS 					2
#define AZTECAS 				3
#define DANANG 					4
#define POLICE 					5
#define CIVIL 					6

#define HOUSE_BIG 				0
#define HOUSE_SMALL 			1
#define HOUSE_MEDIUM            2
#define HOUSE_HUGE              3

enum serverinfo
{
	Float:Spawn_armour[SERVER_MAX_TEAMS],
	Float:Spawn_health[SERVER_MAX_TEAMS],
	Text:Selection,
	Text:Teamnames[SERVER_MAX_TEAMS],
	Text:Teamclasses[2],
	Text:Teaminfo[SERVER_MAX_TEAMS],
	DB:Server,
	house_count = 0,
	T_Kills[SERVER_MAX_TEAMS],
	T_Deaths[SERVER_MAX_TEAMS],
	T_Caps[SERVER_MAX_TEAMS],
	Teamzones[SERVER_MAX_TEAMS],
	Base[SERVER_MAX_TEAMS]
}

enum houseinfo
{
	Name[80],
	Owner[24],
	Float:Entry[3],
	Type,
	Text3D:Info,
	Value,
	Pickup,
	Locked,
	MoneyInside
}

new sInfo[serverinfo],
	H[SERVER_MAX_HOUSES][houseinfo],
	SOS[256];

new Float:GroveSpawns[5][3]={
	{2522.0703,-1678.8501,15.4970},
	{2495.2847,-1689.5275,14.4868},
	{2458.8450,-1690.2054,13.5538},
	{2498.2366,-1643.3777,13.7826},
	{2522.8569,-1659.9718,15.4935}
};

new Float:PoliceSpawns[5][3]={
	{1531.1875,-1671.5803,6.2188},
	{1551.2788,-1707.8013,6.2188},
	{1583.7372,-1690.8741,6.2188},
	{1573.9907,-1619.7551,13.5469},
	{1559.7788,-1653.7152,28.3956}
};

new Float:BallaSpawns[5][3]={
	{2027.5750,-1309.8291,25.2261},
	{1987.7460,-1304.7889,20.8406},
	{1994.9789,-1312.8757,21.5129},
	{2025.9509,-1285.9187,20.9518},
	{2035.3350,-1305.0863,20.9064}
};

new Float:AztecasSpawns[5][3]={
	{1775.1569,-1940.2769,13.5628},
	{1742.5276,-1918.0549,30.5774},
	{1782.4791,-1886.6887,13.3911},
	{1691.1598,-1972.8926,8.8254},
	{1714.7469,-1912.1060,13.5666}
};

new Float:VagosSpawns[5][3]={
	{2350.1455,-1194.9313,27.9766},
	{2349.0588,-1211.2386,36.3047},
	{2330.3579,-1242.3008,36.3001},
	{2335.5513,-1281.9181,35.0900},
	{2319.9614,-1281.3781,32.2474}
};

new Float:DanangSpawns[5][3]={
	{2182.4504,-2258.7964,13.3798},
	{2188.5232,-2312.1831,13.5469},
	{2264.1321,-2254.3494,13.5469},
	{2201.6133,-2198.1318,13.5547},
	{2176.7769,-2218.8677,16.1072}
};

main()
{
	print("\n----------------------------------");
	printf("[%s]%s [%s] ", SERVER_SAMP_VERSION, SERVER_NAME, SERVER_VERSION);
	printf("Scripted by %s and mapped by %s", SERVER_SCRIPTER, SERVER_MAPPER);
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	DisableInteriorEnterExits();
	SetGameModeText(SERVER_GAMEMODE);
	
	AddPlayerClass(105, 2520.0933,-1678.5757,14.9402, 80.5144, 0, 0, 0, 0, 0, 0);

	AddPlayerClass( 102, 2031.4376,-1323.0194,23.0904,0.3906, 0,0,0,0,0,0);

	AddPlayerClass( 108, 2352.1040,-1169.8201,28.0336, 356.1051, 0, 0, 0, 0, 0,0);

	AddPlayerClass( 114, 1779.2999,-1950.5261,14.1096,305.0695, 0,0,0,0,0,0);

	AddPlayerClass( 121,2218.1245,-2217.1433,13.5469,272.9801,0,0,0,0,0,0);

	AddPlayerClass( 281, 1545.8322,-1676.0773,13.5611,89.1661, 0,0,0,0,0,0);
	
	AddPlayerClass(1, 918.1738,-1251.8074,16.2109,89.3938, 0, 0, 0, 0, 0, 0);
	
	
	sInfo[Base][GROVE]  = GangZoneCreate(2435.546875,-1732.421875,2546.875,-1634.765625);
	sInfo[Base][VAGOS]  = GangZoneCreate(2300.78125,-1300.78125,2363.28125,-1156.25);
	sInfo[Base][POLICE] = GangZoneCreate(1519.53125,-1732.421875,1679.6875,-1599.609375);
	sInfo[Base][AZTECAS]= GangZoneCreate(1687.5,-2011.71875,1806.640625,-1861.328125);
	sInfo[Base][BALLA]  = GangZoneCreate(1861.328125,-1339.84375,2052.734375,-1281.25);
	sInfo[Base][DANANG] = GangZoneCreate(2095.703125,-2373.046875,2279.296875,-2183.59375);
	sInfo[Base][CIVIL] = GangZoneCreate(802.734375,-1316.40625,929.6875,-1166.015625);

	sInfo[Server] = db_open("Server.db");
	db_query(sInfo[Server],
	"CREATE TABLE IF NOT EXISTS `TEAMSINFO` (`NAME`, `SPAWN_ARMOUR`, `SPAWN_HEALTH`, `KILLS`, `DEATHS`, `CAPTURES`)"
	);
	
	db_query(sInfo[Server],
	"CREATE TABLE IF NOT EXISTS `HOUSEINFO` (`HOUSEID`, `NAME`, `OWNER`, `ENX`, `ENY`, `ENZ`, `TYPE`, `VALUE`, `LOCKED`, `MONEYINSIDE`)"
	);


	new DBResult:result, rs[80];
	for(new y =0; y < SERVER_MAX_TEAMS; y++)
	{
	    format(SOS, 120, "SELECT * FROM `TEAMSINFO` WHERE `NAME` = '%s' COLLATE NOCASE", GetTeamName(y) );
		result = db_query(sInfo[Server], SOS);
		if(db_num_rows(result))
		{
		    db_get_field_assoc(result, "SPAWN_ARMOUR", rs, 30);
		    sInfo[Spawn_armour][y] = floatstr(rs);
		    db_get_field_assoc(result, "SPAWN_HEALTH", rs, 30);
		    sInfo[Spawn_health][y] = floatstr(rs);
		    db_get_field_assoc(result, "KILLS", rs, 30);
		    sInfo[T_Kills][y] = strval(rs);
		    db_get_field_assoc(result, "DEATHS", rs, 30);
		    sInfo[T_Deaths][y] = strval(rs);
		    db_get_field_assoc(result, "CAPTURES", rs, 30);
		    sInfo[T_Caps][y] = strval(rs);
		}
		else
		{
		    sInfo[Spawn_armour][y] = 60.0;
		    sInfo[Spawn_health][y] = 80.0;
		    sInfo[T_Kills][y] = 0;
		    sInfo[T_Deaths][y] = 0;
		    sInfo[T_Caps][y] = 0;
		    format(SOS, 300,
		    "INSERT INTO `TEAMSINFO` (`NAME`, `SPAWN_ARMOUR`, `SPAWN_HEALTH`, `KILLS`, `DEATHS`, `CAPTURES`) \
			VALUES('%s','60.0','80.0', '0', '0', '0')", DB_Escape(GetTeamName(y)) );
		    db_query(sInfo[Server], SOS);
		}
		db_free_result(result);
	}
	
	sInfo[Selection] = TextDrawCreate(492.000000, 157.000000, "Team selection");
	TextDrawBackgroundColor(sInfo[Selection], 255);
	TextDrawFont(sInfo[Selection], 2);
	TextDrawLetterSize(sInfo[Selection], 0.529999, 2.100000);
	TextDrawAlignment(sInfo[Selection], 2);
	TextDrawColor(sInfo[Selection], 16777215);
	TextDrawSetOutline(sInfo[Selection], 0);
	TextDrawSetProportional(sInfo[Selection], 1);
	TextDrawSetShadow(sInfo[Selection], 1);
	TextDrawSetSelectable(sInfo[Selection], 0);
	
	for(new x=0; x < SERVER_MAX_TEAMS; x++)
	{
		format(SOS, 80, "%s", GetTeamName(x) );
		sInfo[Teamnames][x] = TextDrawCreate(492.000000, 185.000000, SOS); //427.000000
		TextDrawAlignment(sInfo[Teamnames][x], 2);
		TextDrawBackgroundColor(sInfo[Teamnames][x], 255);
		TextDrawFont(sInfo[Teamnames][x], 3);
		TextDrawLetterSize(sInfo[Teamnames][x], 0.480000, 1.800000);
		TextDrawColor(sInfo[Teamnames][x], GetTeamColor(x));
		TextDrawSetOutline(sInfo[Teamnames][x], 1);
		TextDrawSetProportional(sInfo[Teamnames][x], 1);
		TextDrawSetSelectable(sInfo[Teamnames][x], 0);

		format(SOS, 80, "Bonus: ~n~ ~n~Health:%.2f ~n~Armour:%.2f", sInfo[Spawn_health][x], sInfo[Spawn_armour][x]);
		sInfo[Teaminfo][x] = TextDrawCreate(492.000000, 206.000000, SOS);
		TextDrawAlignment(sInfo[Teaminfo][x], 2);
		TextDrawBackgroundColor(sInfo[Teaminfo][x], 255);
		TextDrawFont(sInfo[Teaminfo][x], 2);
		TextDrawLetterSize(sInfo[Teaminfo][x], 0.300000, 1.200000);
		TextDrawColor(sInfo[Teaminfo][x], -1);
		TextDrawSetOutline(sInfo[Teaminfo][x], 1);
		TextDrawSetProportional(sInfo[Teaminfo][x], 1);
		TextDrawUseBox(sInfo[Teaminfo][x], 1);
		TextDrawBoxColor(sInfo[Teaminfo][x], GetTeamColor(x));
		TextDrawTextSize(sInfo[Teaminfo][x], 6.000000, -101.000000);
		TextDrawSetSelectable(sInfo[Teaminfo][x], 0);
	}
	
	CreateHouse(2068.2625,-1731.5593,13.8762, HOUSE_SMALL, 25000);
	CreateHouse(2066.5073,-1717.0869,13.8058, HOUSE_SMALL, 25000);
	CreateHouse(2065.4268,-1703.4553,14.1484, HOUSE_MEDIUM, 50000);
	CreateHouse(2067.1587,-1656.5444,13.9589, HOUSE_SMALL, 25000);
	CreateHouse(2067.7664,-1643.5833,13.8058, HOUSE_SMALL, 25000);
	CreateHouse(2068.1360,-1628.8394,13.8762, HOUSE_SMALL, 25000);
	CreateHouse(1379.7271,-1753.0488,14.1406, HOUSE_BIG, 80000);
	CreateHouse(1324.1490,-1797.4565,13.5547, HOUSE_MEDIUM, 40000);
	CreateHouse(2373.9138,-1139.2847,29.0588, HOUSE_SMALL, 15000);
	CreateHouse(2394.9009,-1134.3591,30.7188, HOUSE_SMALL, 25000);
	CreateHouse(2427.4497,-1136.1935,34.7109, HOUSE_SMALL, 20000);
	CreateHouse(2488.0627,-1135.8300,39.3030, HOUSE_SMALL, 20000);
	CreateHouse(2510.4207,-1132.7985,41.6207, HOUSE_SMALL, 15000);
	CreateHouse(1909.9825,-1598.1222,14.3062, HOUSE_MEDIUM, 50000);
	CreateHouse(1863.8293,-1598.8917,14.1816, HOUSE_MEDIUM, 50000);
	CreateHouse(1310.3228,-1368.6378,13.5520, HOUSE_MEDIUM, 50000);
	CreateHouse(1285.6708,-1308.4432,13.5427, HOUSE_HUGE, 250000);
	CreateHouse(1285.8115,-1329.3546,13.5505, HOUSE_HUGE, 250000);
	CreateHouse(1285.6985,-1350.0198,13.5672, HOUSE_HUGE, 250000);
	CreateHouse(1333.7159,-1308.2612,13.5469, HOUSE_HUGE, 250000);
	CreateHouse(1334.0120,-1329.2740,13.5391, HOUSE_HUGE, 250000);
	CreateHouse(1333.5516,-1349.7274,13.5469, HOUSE_HUGE, 250000);
	CreateHouse(692.8372,-1601.8656,15.0469, HOUSE_BIG, 75000);
	CreateHouse(726.1960,-1276.0868,13.6484, HOUSE_HUGE, 1000000);
	CreateHouse(315.9068,-1771.3765,4.6855, HOUSE_HUGE, 500000);
	CreateHouse(1298.2510,-799.2789,84.1406, HOUSE_HUGE, 2500000);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	TextDrawShowForPlayer(playerid, sInfo[Selection]);
	SetPlayerPos(playerid,2033.6949,1540.8488,10.8203);
	SetPlayerCameraPos(playerid, 2041.6227,1535.5052,10.6719);
	SetPlayerCameraLookAt(playerid, 2033.6949,1540.8488,10.8203, CAMERA_MOVE);
	SetPlayerTeam(playerid, classid);
	for(new x= 0; x < SERVER_MAX_TEAMS; x++)
	{
		TextDrawHideForPlayer(playerid, sInfo[Teamnames][x]);
		TextDrawHideForPlayer(playerid, sInfo[Teaminfo][x]);
	}
	TextDrawShowForPlayer(playerid, sInfo[Teamnames][classid]);
	TextDrawShowForPlayer(playerid, sInfo[Teaminfo][classid]);
	return 1;
}

public OnPlayerConnect(playerid)
{
    GangZoneShowForPlayer(playerid, sInfo[Base][GROVE]  , GetTeamColor(GROVE));
    GangZoneShowForPlayer(playerid, sInfo[Base][VAGOS]  , GetTeamColor(VAGOS));
    GangZoneShowForPlayer(playerid, sInfo[Base][POLICE] , GetTeamColor(POLICE));
    GangZoneShowForPlayer(playerid, sInfo[Base][AZTECAS], GetTeamColor(AZTECAS) );
    GangZoneShowForPlayer(playerid, sInfo[Base][BALLA]  , GetTeamColor(BALLA) );
    GangZoneShowForPlayer(playerid, sInfo[Base][DANANG] , GetTeamColor(DANANG) );
    GangZoneShowForPlayer(playerid, sInfo[Base][CIVIL], GetTeamColor(CIVIL));
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	new t = GetPlayerTeam(playerid), r = random(5);
	switch(t)
	{
	    case GROVE: 	SetPlayerPos(playerid, GroveSpawns[r][0], GroveSpawns[r][1], GroveSpawns[r][2]);
	    case BALLA: 	SetPlayerPos(playerid, BallaSpawns[r][0], BallaSpawns[r][1], BallaSpawns[r][2]);
		case VAGOS: 	SetPlayerPos(playerid, VagosSpawns[r][0], VagosSpawns[r][1], VagosSpawns[r][2]);
		case AZTECAS:   SetPlayerPos(playerid, AztecasSpawns[r][0], AztecasSpawns[r][1], AztecasSpawns[r][2]);
		case DANANG:    SetPlayerPos(playerid, DanangSpawns[r][0], DanangSpawns[r][1], DanangSpawns[r][2]);
		case POLICE:    SetPlayerPos(playerid, PoliceSpawns[r][0], PoliceSpawns[r][1], PoliceSpawns[r][2]);
	}

	SetPlayerHealth(playerid, sInfo[Spawn_health][t]);
	SetPlayerArmour(playerid, sInfo[Spawn_armour][t]);
	
	for(new x=0;x < SERVER_MAX_TEAMS; x++)
	{
	    TextDrawHideForPlayer(playerid, sInfo[Teaminfo][x]);
	    TextDrawHideForPlayer(playerid, sInfo[Teamnames][x]);
	}
	TextDrawHideForPlayer(playerid, sInfo[Selection]);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

stock GetTeamColor(teamid)
{
	switch(teamid)
	{
	    case DANANG: return 0xD60740E1;
	    case GROVE:  return 0x1AC426E1;
	    case BALLA:  return 0x740FCEE1;
	    case VAGOS:  return 0xCFCA0EE1;
	    case POLICE: return 0x095AD5E1;
	    case AZTECAS:return 0x11CCB9E1;
	    case CIVIL:  return 0xDEDADCE1;
	}
	return 1;
}
stock GetTeamName(teamid)
{
	new name[60];
	switch(teamid)
	{
	    case GROVE: name = "Grove St. Families";
	    case BALLA: name = "ELS Ballas";
	    case VAGOS: name = "Los Santos Vagos";
	    case AZTECAS: name = "Varios Los Aztecas";
	    case POLICE: name = "Los Santos Police";
	    case DANANG: name = "DaNang boys";
	    case CIVIL: name = "Civillians";
	}
	return name;
}

stock GetTeamIDFromName(const name[])
{
	for(new x=0; x < SERVER_MAX_TEAMS; x++)
	{
	    if(strfind(name, GetTeamName(x)) == 0)
	    {
			break;
			return x;
		}
	}
	return 1;
}

stock IsPlayerAdminEx(playerid, lvl)
{
	if(IsPlayerAdmin(playerid)) return 1;
	return 0;
}

stock DB_Escape(text[])
{
    new
        ret[80 * 2],
        ch,
        i,
        j;
    while ((ch = text[i++]) && j < sizeof (ret))
    {
        if (ch == '\'')
        {
            if (j < sizeof (ret) - 2)
            {
                ret[j++] = '\'';
                ret[j++] = '\'';
            }
        }
        else if (j < sizeof (ret))
        {
            ret[j++] = ch;
        }
        else
        {
            j++;
        }
    }
    ret[sizeof (ret) - 1] = '\0';
    return ret;
}


stock GetHouseInterior(houseid)
{
	new type = H[houseid][Type];
	switch(type)
	{
	    case HOUSE_SMALL: 		return 15;
	    case HOUSE_MEDIUM: 		return 2;
	    case HOUSE_BIG: 		return 3;
	    case HOUSE_HUGE: 		return 5;
	}
	return 0;
}

stock GetHouseExitPos(houseid, &Float:X, &Float:Y, &Float:Z)
{
	new type = H[houseid][Type];
	switch(type)
	{
	    case HOUSE_SMALL:
	    {
	        X = 295.138977;
			Y = 1474.469971;
			Z = 1080.519897;
		}
		case HOUSE_MEDIUM:
		{
		    X = 225.756989;
		    Y = 1240.000000;
		    Z = 1082.149902;
		}
		case HOUSE_BIG:
		{
		    X = 235.508994;
		    Y = 1189.169897;
		    Z = 1080.339966;
		}
		case HOUSE_HUGE:
		{
		    X = 1299.14;
		    Y = -794.77;
		    Z = 1084.00;
		}
	}
	return 0;
}

stock GetHousePickupModel(houseid)
{
	if(isnull(H[houseid][Owner])) return 1273;
	else
	{
	    if(strcmp(H[houseid][Owner], "Unowned", false) == 0) return 1273;
	    else return 1272;
	}
}

stock UpdateHouseVisual(houseid)
{
	Delete3DTextLabel(H[houseid][Info]);
	format(SOS, 256, "House ID %d\n%s[$%d]\nOwned by %s", houseid, H[houseid][Value], H[houseid][Name], H[houseid][Owner]);
	H[houseid][Info] = Create3DTextLabel(SOS, LIGHTBLUE, H[houseid][Entry][0], H[houseid][Entry][1], H[houseid][Entry][2], 25.0, 0, 0);
	DestroyPickup(H[houseid][Pickup]);
	H[houseid][Pickup] = CreatePickup(GetHousePickupModel(houseid), 1, H[houseid][Entry][0], H[houseid][Entry][1], H[houseid][Entry][2], -1);
	return 1;
}

stock CreateHouse(Float:Ex, Float:Ey, Float:Ez, house_type, value)
{
	new houseid = sInfo[house_count];
	format(SOS, 256, "SELECT * FROM `HOUSEINFO` WHERE `HOUSEID` = '%d'", houseid);
	new DBResult:res = db_query(sInfo[Server], SOS);
	if(!db_num_rows(res))
	{
	    format(H[houseid][Owner], 24, "Unowned");
	    format(H[houseid][Name],  80, "For sale");
	    H[houseid][Entry][0] = Ex;
	    H[houseid][Entry][1] = Ey;
	    H[houseid][Entry][2] = Ez;
	    H[houseid][Value] = value;
	    H[houseid][Type] = house_type;
	    UpdateHouseVisual(houseid);
	    format(SOS, 500, "INSERT INTO `HOUSEINFO`(`HOUSEID`, `NAME`, `OWNER`, `ENX`, `ENY`, `ENZ`, `TYPE`, `VALUE`, `LOCKED`, `MONEYINSIDE`) \
	    VALUES ('%d', '%s', '%s', '%f', '%f', '%f', '%d', '%d', '%d', '%d')",
	    houseid, DB_Escape(H[houseid][Name]), DB_Escape(H[houseid][Owner]), H[houseid][Entry][0], H[houseid][Entry][1], H[houseid][Entry][2], H[houseid][Type], H[houseid][Value], H[houseid][Locked], H[houseid][MoneyInside]);
		db_query(sInfo[Server], SOS);
		sInfo[house_count]++;
	}
	else
	{
	    new str[20];
		db_get_field_assoc(res, "NAME", H[houseid][Name], 80);
		db_get_field_assoc(res, "OWNER", H[houseid][Owner], 24);
		db_get_field_assoc(res, "ENX", str, 20);
		H[houseid][Entry][0] = floatstr(str);
		db_get_field_assoc(res, "ENY", str, 20);
		H[houseid][Entry][1] = floatstr(str);
		db_get_field_assoc(res, "ENZ", str, 20);
		H[houseid][Entry][2] = floatstr(str);
		db_get_field_assoc(res, "TYPE", str, 20);
		H[houseid][Type] = strval(str);
		db_get_field_assoc(res, "LOCKED", str, 5);
		H[houseid][Locked] = strval(str);
		db_get_field_assoc(res, "MONEYINSIDE", str, 20);
		H[houseid][MoneyInside] = strval(str);
		sInfo[house_count]++;
		UpdateHouseVisual(houseid);
	}
	db_free_result(res);
	return 1;
}
stock SaveHouse(houseid)
{
	format(SOS, 256, "SELECT * FROM `HOUSEINFO` WHERE `HOUSEID` = '%d'", houseid);
	new DBResult:res = db_query(sInfo[Server], SOS);
	if(db_num_rows(res))
	{
		format(SOS, 500, "UPDATE `HOUSEINFO` SET NAME = '%s', OWNER = '%s', ENX = '%f', ENY = '%f', ENZ = '%f', TYPE = '%d', VALUE = '%d', LOCKED = '%d', MONEYINSIDE = '%d') ",
		H[houseid][Name], H[houseid][Owner], H[houseid][Entry][0], H[houseid][Entry][1], H[houseid][Entry][2], H[houseid][Type], H[houseid][Value], H[houseid][Locked], H[houseid][MoneyInside]);
		db_query(sInfo[Server], SOS);
	}
	else
	{
	    return 0;
	}
	db_free_result(res);
	return 1;
}

CMD:enter(playerid, params[])
{
	for(new x=0; x < SERVER_MAX_HOUSES; x++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.5, H[x][Entry][0], H[x][Entry][1], H[x][Entry][2]))
		{
			new Float:Pos[3];
			GetHouseExitPos(x, Pos[0], Pos[1], Pos[2]);
			SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			SetPlayerInterior(playerid, GetHouseInterior(x) );
			SetPlayerVirtualWorld(playerid, GetHouseInterior(x)+x);
		}
	}
	return 1;
}

CMD:exit(playerid, params[])
{
	for(new x=0; x < SERVER_MAX_HOUSES; x++)
	{
		new Float:Pos[3];
		GetHouseExitPos(x, Pos[0], Pos[1], Pos[2]);
		if(IsPlayerInRangeOfPoint(playerid, 2.0, Pos[0], Pos[1], Pos[2]))
		{
		    SetPlayerPos(playerid, H[x][Entry][0], H[x][Entry][1], H[x][Entry][2]);
		    SetPlayerInterior(playerid, 0);
		    SetPlayerVirtualWorld(playerid, 0);
		}
	}
	return 1;
}

CMD:houseentry(playerid,params[])
{
	new hid;
	if(!sscanf(params, "d", hid))
	{
	    SetPlayerPos(playerid, H[hid][Entry][0], H[hid][Entry][1], H[hid][Entry][2]);
	}
	return 1;
}

