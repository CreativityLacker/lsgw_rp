#include <a_samp>
#include <zcmd>
#include <vehname>
#include <sscanf2>
#include <colweap>

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

forward KickPublic(playerid); public KickPublic(playerid) { Kick(playerid); }

#define SAVE_TYPE_MINING 		1 //saves mining info
#define SAVE_TYPE_TIMING  		2 // saves online hours,seconds,minutes,weededtimes,minedtimes etc.
#define SAVE_TYPE_MAIN   		3 //kils,deaths,money,XP,bankbalance
#define SAVE_TYPE_SERVERSTATS   4 //IP,adminlevel,donated,donorlevel
#define SAVE_TYPE_OWNERSHIP     5 //car1,car2,house1
#define SAVE_TYPE_INVENTORY     6 //weed,seeds,tuna,needlefish,snapper,fertilizer, fishbait
#define SAVE_TYPE_NOTIFICATIONS 7 //notification toggles

#undef 	MAX_VEHICLES
#define MAX_VEHICLES 			25
#define MAX_HOUSES      		300 //currently, this is 500, right?
#define MAX_ATMS        		25
#define MAX_CAR_DEALERSHIPS     2
#define MAX_METALS              3
#define MAX_MINES               3
#define MAX_MINE_SPOTS          10
#define MAX_NOTIFICATION_LINES  8

#define MINING_TOOL_DEFAULT     	0
#define MINING_TOOL_INTERMEDIATE    1
#define MINING_TOOL_ADVANCED        2
#define MINING_TOOL_JACKHAMMER      3 //VIP only

#define METAL_ORE       0
#define METAL_COPPER    1
#define METAL_TIN       2

#define FISH_TUNA       0
#define FISH_SNAPPER    1
#define FISH_NEEDLEFISH 2

#define DEALERSHIP_LS_RODEO     0

#define HOUSE_SMALL 			0
#define HOUSE_MEDIUM 			1
#define HOUSE_BIG 				2
#define HOUSE_HUGE 				3
#define HOUSE_HOTEL             4

#define DIALOG_BALANCE 			0
#define DIALOG_DEPOSIT 			1
#define DIALOG_WITHDRAW 		2
#define DIALOG_REGISTER         3
#define DIALOG_LOGIN            4

native IsValidVehicle(vehicleid);

enum vehiclesinfo
{
	Car,
	Model,
	Owner[24],
	Carcol[2],
	Float:Park[4],
	Locked,
	Cost
}

enum houseinfo
{
	Name[80],
	OwnedBy[24],
	Float:Entry[3],
	Type,
	Lock,
	Value,
	MoneyInside,
	Pickup,
	Text3D:Info
}

enum automatedmachines
{
	Float:APos[3],
	Object,
	Text3D:AText
}

enum main_playerstats
{
	Kills,
	Deaths,
	XP,
	Money,
	Balance
}

enum ownership_playerstats
{
	Cars[2],
	House
}

enum time_playerstats
{
	Times_Weeded = 0,
	Times_Mined = 0,
	Times_Fished = 0,
	Hours_played = 0,
	Minutes_played = 0,
	Seconds_played = 0,
	Times_played = 0,
	Times_Punished = 0
}

enum tempplayerinfo
{
	Inside,
	bool:Registered
}

enum serverplayerinfo
{
	Password[80],
	IP[20],
	AdminLevel,
	VIPLevel,
	Float:Donated,
	Reg_year,
	Reg_month,
	Reg_date
}

enum play_mininginfo
{
	Metals[MAX_METALS],
	Metal_Containers[MAX_METALS],
	Tool,
	Mining_XP
}

enum play_inventoryinfo
{
	Weed,
	Seeds,
	Fishbait,
	Fishes[3],
	Fertilizers
}

enum play_notifyinfo
{
	Join_Leave_News,
	Spree_News,
	Captures_News,
	Admin_News,
	Prvt_News
}

new V[MAX_VEHICLES][vehiclesinfo],
	H[MAX_HOUSES][houseinfo],
	A[MAX_ATMS][automatedmachines],
	
	Float:Dealership[MAX_CAR_DEALERSHIPS][3],
	
	Tmp_P[MAX_PLAYERS][tempplayerinfo],
	M[MAX_PLAYERS][play_mininginfo],
	P[MAX_PLAYERS][main_playerstats],
	Time_P[MAX_PLAYERS][time_playerstats],
	Server_P[MAX_PLAYERS][serverplayerinfo],
	Owner_P[MAX_PLAYERS][ownership_playerstats],
	Invent_P[MAX_PLAYERS][play_inventoryinfo],
	Notify_P[MAX_PLAYERS][play_notifyinfo],
	
	vehicle_count = 1,
	atm_count = 0,
	house_count = 0,
	
	Text:Bank[9],
	Text:CarInfo[12],
	
	DB:Server;


main() { }

public OnGameModeInit()
{
	DisableInteriorEnterExits();
    AddPlayerClass(0, 726.3949,-1276.2904,13.6484, 0, 0, 0, 0, 0, 0, 0);
	Server = db_open("Server.db");
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `VEHICLES`(`ID`, `OWNER`, `MODEL`, `CARCOL1`, `CARCOL2`, `LOCKED`, `PARKX`, `PARKY`, `PARKZ`, `PARKROT`, `COST`)"
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `HOUSES`(`ID`, `NAME`, `OWNER`, `ENTRYX`, `ENTRYY`, `ENTRYZ`, `TYPE`, `LOCK`, `VALUE`, `MONEYINSIDE`) "
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `MAIN_PSTATS`(`USERNAME`,`KILLS`, `DEATHS`, `XP`, `MONEY`, `BALANCE`) "
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `MINING`(`USERNAME`, `ORE`, `COPPER`, `TIN`, `ORE_CONTAINER`, `COPPER_CONTAINER`, `TIN_CONTAINER`, `MINING_XP`, `TOOL`)"
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `TIME_STATS`(`USERNAME`, `TIMES_WEEDED`, `TIMES_MINED`, `TIMES_FISHED`, `TIMES_PUNISHED`, `TIMES_VISITED`, `HOURS_PLAYED`, `MINUTES_PLAYED`, `SECONDS_PLAYED`) "
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `SERVER_STATS`(`USERNAME`, `IP`, `PASSWORD`, `ADMINLEVEL`, `VIPLEVEL`, `DONATED`, `REG_YEAR`, `REG_MONTH`, `REG_DATE`) "
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `OWNERSHIP_STATS`(`USERNAME`, `CAR1`, `CAR2`, `HOUSE`) "
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `INVENTORY_STATS`(`USERNAME`,`WEED`, `SEEDS`, `FISHBAIT`, `TUNA`, `SNAPPER`, `NEEDLEFISH`, `FERTILIZERS`) "
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `BANS` (`NAME`, `IP`,`REASON`, `BY`, `MONTH`, `DATE`, `YEAR`)"
	);
	
	db_query(Server,
	"CREATE TABLE IF NOT EXISTS `NOTIFY_STATS`(`USERNAME`,`JOINLEAVE`, `SPREES`, `CAPTURES`, `ADMINS`, `PRVTNEWS`) "
	);
	
	LoadHouses();
	
	CreateObject(2987,2242.8999023,-1159.7504883,1030.0000000,0.0000000,0.0000000,270.0000000); //object(lxr_motel_doorsim) (2)
	CreateObject(2987,2194.8999023,-1157.0000000,1030.0000000,0.0000000,0.0000000,269.9999695); //object(lxr_motel_doorsim) (3)
	
	LoadCars();
	
	CreateATM(730.3129,-1284.0206,13.5688, 0, 0, 0);
	
	CreateCarDealership(DEALERSHIP_LS_RODEO, 562.4942,-1292.0735,17.2482);
	
	Bank[0] = TextDrawCreate(488.325042, 140.916656, "usebox");
	TextDrawLetterSize(Bank[0], 0.000000, 31.507406);
	TextDrawTextSize(Bank[0], 129.654464, 0.000000);
	TextDrawAlignment(Bank[0], 1);
	TextDrawColor(Bank[0], 0);
	TextDrawUseBox(Bank[0], true);
	TextDrawBoxColor(Bank[0], 102);
	TextDrawSetShadow(Bank[0], 0);
	TextDrawSetOutline(Bank[0], 0);
	TextDrawFont(Bank[0], 0);
	
	Bank[1] = TextDrawCreate(320.000305, 156.916717, "Bank ~n~Automated telling machine");
	TextDrawLetterSize(Bank[1], 0.427979, 2.019999);
	TextDrawTextSize(Bank[1], 314.377929, 147.000030);
	TextDrawAlignment(Bank[1], 2);
	TextDrawColor(Bank[1], -1);
	TextDrawUseBox(Bank[1], true);
	TextDrawBoxColor(Bank[1], 255);
	TextDrawSetShadow(Bank[1], 0);
	TextDrawSetOutline(Bank[1], 1);
	TextDrawBackgroundColor(Bank[1], 51);
	TextDrawFont(Bank[1], 2);
	TextDrawSetProportional(Bank[1], 1);

	Bank[2] =  TextDrawCreate(131.185943, 138.250015, "ld_drv:tvcorn");
	TextDrawLetterSize(Bank[2], 0.000000, 0.000000);
	TextDrawTextSize(Bank[2], 207.554885, 221.666687);
	TextDrawAlignment(Bank[2], 1);
	TextDrawColor(Bank[2], -1);
	TextDrawSetShadow(Bank[2], 0);
	TextDrawSetOutline(Bank[2], 0);
	TextDrawFont(Bank[2], 4);
	
	Bank[3] = TextDrawCreate(488.667602, 137.666717, "ld_drv:tvcorn");
	TextDrawLetterSize(Bank[3], 0.000000, 0.000000);
	TextDrawTextSize(Bank[3], -191.156646, 224.000076);
	TextDrawAlignment(Bank[3], 1);
	TextDrawColor(Bank[3], -1);
	TextDrawSetShadow(Bank[3], 0);
	TextDrawSetOutline(Bank[3], 0);
	TextDrawFont(Bank[3], 4);
	
	Bank[4] = TextDrawCreate(130.717422, 426.416595, "ld_drv:tvcorn");
	TextDrawLetterSize(Bank[4], 0.000000, 0.000000);
	TextDrawTextSize(Bank[4], 213.177291, -165.666641);
	TextDrawAlignment(Bank[4], 1);
	TextDrawColor(Bank[4], -1);
	TextDrawSetShadow(Bank[4], 0);
	TextDrawSetOutline(Bank[4], 0);
	TextDrawFont(Bank[4], 4);
	
	Bank[5] = TextDrawCreate(488.667633, 427.583282, "ld_drv:tvcorn");
	TextDrawLetterSize(Bank[5], 0.000000, 0.000000);
	TextDrawTextSize(Bank[5], -180.849212, -170.916671);
	TextDrawAlignment(Bank[5], 1);
	TextDrawColor(Bank[5], -1);
	TextDrawSetShadow(Bank[5], 0);
	TextDrawSetOutline(Bank[5], 0);
	TextDrawFont(Bank[5], 4);
	
	Bank[6] =   TextDrawCreate(193.967788, 345.916625, "Withdraw");
	TextDrawLetterSize(Bank[6], 0.440159, 2.259166);
	TextDrawTextSize(Bank[6], 291.889160, 9.333333);
	TextDrawAlignment(Bank[6], 1);
	TextDrawColor(Bank[6], -1);
	TextDrawUseBox(Bank[6], true);
	TextDrawBoxColor(Bank[6], 255);
	TextDrawSetShadow(Bank[6], 0);
	TextDrawSetOutline(Bank[6], 1);
	TextDrawBackgroundColor(Bank[6], 51);
	TextDrawFont(Bank[6], 2);
	TextDrawSetProportional(Bank[6], 1);
	TextDrawSetSelectable(Bank[6], true);

	
	Bank[7] =	TextDrawCreate(336.398345, 344.750000, "Deposit");
	TextDrawLetterSize(Bank[7], 0.469208, 2.480834);
	TextDrawTextSize(Bank[7], 424.480346, 16.333333);
	TextDrawAlignment(Bank[7], 1);
	TextDrawColor(Bank[7], -1);
	TextDrawUseBox(Bank[7], true);
	TextDrawBoxColor(Bank[7], 255);
	TextDrawSetShadow(Bank[7], 0);
	TextDrawSetOutline(Bank[7], 1);
	TextDrawBackgroundColor(Bank[7], 51);
	TextDrawFont(Bank[7], 2);
	TextDrawSetProportional(Bank[7], 1);
	TextDrawSetSelectable(Bank[7], true);
	
	Bank[8] = TextDrawCreate(245.505081, 274.166656, "Check balance");
	TextDrawLetterSize(Bank[8], 0.438753, 2.154166);
	TextDrawTextSize(Bank[8], 400.586364, 9.916666);
	TextDrawAlignment(Bank[8], 1);
	TextDrawColor(Bank[8], -1);
	TextDrawUseBox(Bank[8], true);
	TextDrawBoxColor(Bank[8], 255);
	TextDrawSetShadow(Bank[8], 0);
	TextDrawSetOutline(Bank[8], 1);
	TextDrawBackgroundColor(Bank[8], 51);
	TextDrawFont(Bank[8], 2);
	TextDrawSetProportional(Bank[8], 1);
	TextDrawSetSelectable(Bank[8], true);

	
	CarInfo[0] = TextDrawCreate(527.680786, 113.500000, "usebox");
	TextDrawLetterSize(CarInfo[0], 0.000000, 24.118520);
	TextDrawTextSize(CarInfo[0], 112.319183, 0.000000);
	TextDrawAlignment(CarInfo[0], 1);
	TextDrawColor(CarInfo[0], 0);
	TextDrawUseBox(CarInfo[0], true);
	TextDrawBoxColor(CarInfo[0], 102);
	TextDrawSetShadow(CarInfo[0], 0);
	TextDrawSetOutline(CarInfo[0], 0);
	TextDrawFont(CarInfo[0], 0);
	
	CarInfo[1] = TextDrawCreate(184.000000, 281.000000, "Car information");
	TextDrawBackgroundColor(CarInfo[1], 255);
	TextDrawFont(CarInfo[1], 2);
	TextDrawLetterSize(CarInfo[1], 0.289999, 1.600000);
	TextDrawColor(CarInfo[1], -1);
	TextDrawSetOutline(CarInfo[1], 0);
	TextDrawSetProportional(CarInfo[1], 1);
	TextDrawSetShadow(CarInfo[1], 1);
	TextDrawUseBox(CarInfo[1], 1);
	TextDrawBoxColor(CarInfo[1], 255);
	TextDrawTextSize(CarInfo[1], 290.000000, 0.000000);
	TextDrawSetSelectable(CarInfo[1], 0);
	
	CarInfo[2] = TextDrawCreate(307.000000, 280.000000, "GPS");
	TextDrawBackgroundColor(CarInfo[2], 255);
	TextDrawFont(CarInfo[2], 2);
	TextDrawLetterSize(CarInfo[2], 0.370000, 1.899999);
	TextDrawColor(CarInfo[2], -1);
	TextDrawSetOutline(CarInfo[2], 0);
	TextDrawSetProportional(CarInfo[2], 1);
	TextDrawSetShadow(CarInfo[2], 1);
	TextDrawUseBox(CarInfo[2], 1);
	TextDrawBoxColor(CarInfo[2], 255);
	TextDrawTextSize(CarInfo[2], 339.000000, 0.000000);
	TextDrawSetSelectable(CarInfo[2], 0);
	
	CarInfo[3] = TextDrawCreate(288.000000, 188.000000, "New Textdraw"); // GPS icon
	TextDrawBackgroundColor(CarInfo[3], 255);
	TextDrawFont(CarInfo[3], 5);
	TextDrawLetterSize(CarInfo[3], 0.500000, 1.000000);
	TextDrawColor(CarInfo[3], -1);
	TextDrawSetOutline(CarInfo[3], 0);
	TextDrawSetProportional(CarInfo[3], 1);
	TextDrawSetShadow(CarInfo[3], 1);
	TextDrawUseBox(CarInfo[3], 1);
	TextDrawBoxColor(CarInfo[3], 255);
	TextDrawTextSize(CarInfo[3], 69.000000, 85.000000);
	TextDrawSetPreviewModel(CarInfo[3], 1262);
	TextDrawSetPreviewRot(CarInfo[3], 0.000000, 0.000000, 0.000000, 1.000000);
	TextDrawSetSelectable(CarInfo[3], 1);
	
	CarInfo[4] = TextDrawCreate(380.000000, 283.000000, "Car door");
	TextDrawBackgroundColor(CarInfo[4], 255);
	TextDrawFont(CarInfo[4], 2);
	TextDrawLetterSize(CarInfo[4], 0.360000, 1.600000);
	TextDrawColor(CarInfo[4], -1);
	TextDrawSetOutline(CarInfo[4], 0);
	TextDrawSetProportional(CarInfo[4], 1);
	TextDrawSetShadow(CarInfo[4], 1);
	TextDrawUseBox(CarInfo[4], 1);
	TextDrawBoxColor(CarInfo[4], 255);
	TextDrawTextSize(CarInfo[4], 458.000000, 0.000000);
	TextDrawSetSelectable(CarInfo[4], 0);
	
	CarInfo[5] = TextDrawCreate(380.000000, 190.000000, "New Textdraw"); //
	TextDrawBackgroundColor(CarInfo[5], 255);
	TextDrawFont(CarInfo[5], 5);
	TextDrawLetterSize(CarInfo[5], 0.500000, 1.000000);
	TextDrawColor(CarInfo[5], -1);
	TextDrawSetOutline(CarInfo[5], 0);
	TextDrawSetProportional(CarInfo[5], 1);
	TextDrawSetShadow(CarInfo[5], 1);
	TextDrawUseBox(CarInfo[5], 1);
	TextDrawBoxColor(CarInfo[5], 255);
	TextDrawTextSize(CarInfo[5], 70.000000, 81.000000);
	TextDrawSetPreviewModel(CarInfo[5], 2886);
	TextDrawSetPreviewRot(CarInfo[5], 0.000000, 0.000000, 0.000000, 1.000000);
	TextDrawSetSelectable(CarInfo[5], 1);
	
	CarInfo[6] = TextDrawCreate(256.000000, 145.000000, "Car functions");
	TextDrawBackgroundColor(CarInfo[6], 255);
	TextDrawFont(CarInfo[6], 3);
	TextDrawLetterSize(CarInfo[6], 0.589999, 2.200000);
	TextDrawColor(CarInfo[6], -1);
	TextDrawSetOutline(CarInfo[6], 0);
	TextDrawSetProportional(CarInfo[6], 1);
	TextDrawSetShadow(CarInfo[6], 1);
	TextDrawSetSelectable(CarInfo[6], 0);
	
	CarInfo[7] = TextDrawCreate(114.000000, 112.000000, "ld_drv:tvcorn");
	TextDrawBackgroundColor(CarInfo[7], 255);
	TextDrawFont(CarInfo[7], 4);
	TextDrawLetterSize(CarInfo[7], 0.500000, 1.000000);
	TextDrawColor(CarInfo[7], -1);
	TextDrawSetOutline(CarInfo[7], 0);
	TextDrawSetProportional(CarInfo[7], 1);
	TextDrawSetShadow(CarInfo[7], 1);
	TextDrawUseBox(CarInfo[7], 1);
	TextDrawBoxColor(CarInfo[7], 255);
	TextDrawTextSize(CarInfo[7], 191.000000, 169.000000);
	TextDrawSetSelectable(CarInfo[7], 0);
	
	CarInfo[8] =  TextDrawCreate(526.000000, 332.000000, "ld_drv:tvcorn");
	TextDrawBackgroundColor(CarInfo[8], 255);
	TextDrawFont(CarInfo[8], 4);
	TextDrawLetterSize(CarInfo[8], 0.500000, 1.000000);
	TextDrawColor(CarInfo[8], -1);
	TextDrawSetOutline(CarInfo[8], 0);
	TextDrawSetProportional(CarInfo[8], 1);
	TextDrawSetShadow(CarInfo[8], 1);
	TextDrawUseBox(CarInfo[8], 1);
	TextDrawBoxColor(CarInfo[8], 255);
	TextDrawTextSize(CarInfo[8], -250.000000, -164.000000);
	TextDrawSetSelectable(CarInfo[8], 0);
	
	CarInfo[9] = TextDrawCreate(115.000000, 332.000000, "ld_drv:tvcorn");
	TextDrawBackgroundColor(CarInfo[9], 255);
	TextDrawFont(CarInfo[9], 4);
	TextDrawLetterSize(CarInfo[9], 0.500000, 1.000000);
	TextDrawColor(CarInfo[9], -1);
	TextDrawSetOutline(CarInfo[9], 0);
	TextDrawSetProportional(CarInfo[9], 1);
	TextDrawSetShadow(CarInfo[9], 1);
	TextDrawUseBox(CarInfo[9], 1);
	TextDrawBoxColor(CarInfo[9], 255);
	TextDrawTextSize(CarInfo[9], 240.000000, -164.000000);
	TextDrawSetSelectable(CarInfo[9], 0);
	
	CarInfo[10] = TextDrawCreate(525.000000, 112.000000, "ld_drv:tvcorn");
	TextDrawBackgroundColor(CarInfo[10], 255);
	TextDrawFont(CarInfo[10], 4);
	TextDrawLetterSize(CarInfo[10], 0.500000, 1.000000);
	TextDrawColor(CarInfo[10], -1);
	TextDrawSetOutline(CarInfo[10], 0);
	TextDrawSetProportional(CarInfo[10], 1);
	TextDrawSetShadow(CarInfo[10], 1);
	TextDrawUseBox(CarInfo[10], 1);
	TextDrawBoxColor(CarInfo[10], 255);
	TextDrawTextSize(CarInfo[10], -224.000000, 177.000000);
	TextDrawSetSelectable(CarInfo[10], 0);
	
	CarInfo[11] = TextDrawCreate(199.000000, 189.000000, "New Textdraw"); // 'i' icon <= for car info
	TextDrawBackgroundColor(CarInfo[11], 255);
	TextDrawFont(CarInfo[11], 5);
	TextDrawLetterSize(CarInfo[11], 0.500000, 1.000000);
	TextDrawColor(CarInfo[11], -1);
	TextDrawSetOutline(CarInfo[11], 0);
	TextDrawSetProportional(CarInfo[11], 1);
	TextDrawSetShadow(CarInfo[11], 1);
	TextDrawUseBox(CarInfo[11], 1);
	TextDrawBoxColor(CarInfo[11], 255);
	TextDrawTextSize(CarInfo[11], 70.000000, 83.000000);
	TextDrawSetPreviewModel(CarInfo[11], 1239);
	TextDrawSetPreviewRot(CarInfo[11], 0.000000, 0.000000, 0.000000, 1.000000);
	TextDrawSetSelectable(CarInfo[11], 1);

	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 736.8354,-1275.2483,13.5534);
	SetPlayerCameraLookAt(playerid, 736.8354,-1275.2483,13.5534, CAMERA_MOVE);
	SetPlayerCameraPos(playerid, 749.0621,-1267.6788,13.5547);
	return 1;
}

public OnPlayerConnect(playerid)
{
	ResetUser(playerid);
	if(!IsPlayerNPC(playerid))
	{
	    new query[200], DBResult:res;
	    format(query, 200,
	    "SELECT * FROM `BANS` WHERE `NAME`='%s'", pname(playerid) );
	    res = db_query(Server, query);
	    if(db_num_rows(res))
	    {
	        new reason[40], admn[25], date[3];
	        db_get_field_assoc(res, "BY", admn, 25);
	        db_get_field_assoc(res, "REASON", reason, 40);
	        db_get_field_assoc(res, "DATE", query, 5);
			date[2] = strval(query);
			db_get_field_assoc(res, "MONTH", query, 5);
			date[1] = strval(query);
			db_get_field_assoc(res, "YEAR", query, 5);
			date[0] = strval(query);
			SendClientMessage(playerid, RED, "[SERVER] You're banned! ");
	        format(query, 200, "[SERVER] Reason: %s || Banned by: %s || On: %d/%d/%d",
	        reason, admn, date[2], date[1], date[0]);
	        KickEx_(playerid, query);
	        db_free_result(res);
		}
		/*else if(!db_num_rows(res))
		{
		    db_free_result(res);
		    format(query, 200, "SELECT * FROM `BANS` WHERE `IP`='%s'", pip(playerid) );
		    res = db_query(Server, query);
		    if(db_num_rows(res))
		    {
		        new reason[40], admn[25], date[3];
		        db_get_field_assoc(res, "BY", admn, 25);
		        db_get_field_assoc(res, "REASON", reason, 40);
		        db_get_field_assoc(res, "DATE", query, 5);
				date[2] = strval(query);
				db_get_field_assoc(res, "MONTH", query, 5);
				date[1] = strval(query);
				db_get_field_assoc(res, "YEAR", query, 5);
				date[0] = strval(query);
				SendClientMessage(playerid, RED, "[SERVER] You're banned! ");
		        format(query, 200, "[SERVER] Reason: %s || Banned by: %s || On: %d/%d/%d",
		        reason, admn, date[2], date[1], date[0]);
		        KickEx_(playerid, query);
		        db_free_result(res);
			}
		}*/
		else
		{
			db_free_result(res);
			format(query, 200, "SELECT * FROM `SERVER_STATS` WHERE `USERNAME`='%s'", pname(playerid) );
			res = db_query(Server, query);
			if(db_num_rows(res))
			{
			    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
				"Logging in",
				"Welcome to our server! \r\nYou're already registered here! Please enter your password below! ",
				"Login",
				"Quit");
			}
			else
			{
			    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
				"Registeration",
				"Welcome to our server! \r\nYou're not registered! \r\nPlease type in the password you'd like to register with!",
				"Register",
				"Quit");
			}
		}
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	SetVehiclePos(vehicleid, V[vehicleid][Park][0], V[vehicleid][Park][1], V[vehicleid][Park][2]);
	SetVehicleZAngle(vehicleid, V[vehicleid][Park][3]);
	ChangeVehicleColor(vehicleid, V[vehicleid][Carcol][0], V[vehicleid][Carcol][1]);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new vehicleid = GetPlayerVehicleID(playerid),  str[120];
		if(strcmp(V[vehicleid][Owner], "Unowned", false) == 0)
		{
		    format(str, 120, "[VEHICLE] You've entered a %s which is not owned [For sale $ %d]", GetVehicleName(vehicleid), V[vehicleid][Cost]);
		    SendClientMessage(playerid, LIGHTBLUE, str);
		}
		else
		{
			format(str, 120, "[VEHICLE] You've entered a %s which is owned by %s", GetVehicleName(vehicleid), V[vehicleid][Owner]);
			SendClientMessage(playerid, LIGHTBLUE , str);
			if(V[vehicleid][Locked] == 1)
			{
		    	if(strcmp(pname(playerid), V[vehicleid][Owner], false) == 0)
		    	{
		        	SendClientMessage(playerid, INDIANRED, "Your car is locked and only you can enter it. Use /carlock to unlock it! ");
				}
				else
				{
			    	SendClientMessage(playerid, INDIANRED, "This car is locked, you cannot enter it as you're not the owner! ");
			    	RemovePlayerFromVehicle(playerid);
				}
			}
		}
		SendClientMessage(playerid, SEAGREEN , "[SERVER] You can use /carfunc to use functions of this car! ");
	}
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(_:clickedid == INVALID_TEXT_DRAW) 
	{
	    for(new x = 0; x  <  9; x++)
	    {
	        TextDrawHideForPlayer(playerid, Bank[x]);
			TogglePlayerControllable(playerid, true);
		}
		for(new x=0; x < 12; x++)
		{
		    TextDrawHideForPlayer(playerid, CarInfo[x]);
		}
	}
	else
	{
	    if(clickedid == Bank[8])
	    {
			new str[120];
			format(str, 120, "Your current balance is $ %d", P[playerid][Balance]  );
			ShowPlayerDialog(playerid, DIALOG_BALANCE, DIALOG_STYLE_MSGBOX, "Bank - balance", str, "Close", "Close");
		}
		else if(clickedid == Bank[7])
		{
		    ShowPlayerDialog(playerid, DIALOG_DEPOSIT, DIALOG_STYLE_INPUT, "Bank - deposit", "Please insert the amount you'd like to deposit", "Deposit", "Close");
		}
		else if(clickedid == Bank[6])
		{
		    new str[120];
			format(str, 120, "Your balance is $ %d \nHow much would like to withdraw?", P[playerid][Balance] );
		    ShowPlayerDialog(playerid, DIALOG_WITHDRAW, DIALOG_STYLE_INPUT, "Bank - withdraw", str, "Withdraw", "Close");
		}
		else if(clickedid == CarInfo[11])
		{
		    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, INDIANRED, "[ERROR] You need to be in a car to use this function! ");
		    else
		    {
		        new str[500];
		        new Float:vhp;
		        new vid = GetPlayerVehicleID(playerid);
				GetVehicleHealth(vid, vhp);
				format(str, 500,
		        "Vehicle information\r\n%s[%d] owned by %s\r\nCurrent vehicle health:%f\r\nVehicle lock: %s\r\nDriver: %s",
		        GetVehicleName(vid),
				vid,
				V[vid][Owner],
				vhp,
				GetLockState(V[vid][Locked]),
				pname(GetVehicleDriver(vid)) );
				ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "Car information", str, "Close", "Close");
			}
		}
		else if(clickedid == CarInfo[3]) return SendClientMessage(playerid, INDIANRED, "[SERVER] Feature under construction");
		else if(clickedid == CarInfo[5]) return cmd_carlock(playerid, "");
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_BALANCE: return 0;
	    case DIALOG_DEPOSIT:
	    {
	        if(!response) return 0;
	        new mon = strval(inputtext);
	        if(!IsNumeric(inputtext)) return SendClientMessage(playerid, INDIANRED, "[ERROR] You must insert a numeric value! ");
	        else
	        {
	            if(GetPlayerMoneyEx(playerid) < mon) return SendClientMessage(playerid, INDIANRED, "[ERROR] You don't have enough money! ");
				else
				{
				    GivePlayerMoneyEx(playerid, -mon);
				    P[playerid][Balance] += mon;
				    new str[120];
				    format(str, 120, "[BANK] Your new balance is $ %d", P[playerid][Balance]);
				    SendClientMessage(playerid, GREEN, str);
				}
			}
		}
		case DIALOG_WITHDRAW:
		{
		    if(!response) return 0;
		    new mon = strval(inputtext);
		    if(!IsNumeric(inputtext)) return SendClientMessage(playerid, INDIANRED, "[ERROR] You must insert a numeric value! ");
			if(strval(inputtext) < 0) return SendClientMessage(playerid, INDIANRED, "[ERROR] Amount must be positive! ");
			else
		    {
		        if(P[playerid][Balance] > mon) return SendClientMessage(playerid, INDIANRED, "[ERROR] Entered amount exceeds bank balance! ");
				else
				{
				    GivePlayerMoneyEx(playerid, mon);
				    P[playerid][Balance] -= mon;
				    new str[120];
				    format(str, 120, "[BANK] Your new balance is $ %d", P[playerid][Balance] );
					SendClientMessage(playerid, GREEN, str);
				}
			}
		}
		case DIALOG_LOGIN:
		{
		    if(response)
		    {
		        new query[500], DBResult:res;
		        format(query, sizeof(query), "SELECT * FROM `SERVER_STATS` WHERE `NAME` = '%s' COLLATE NOCASE AND `PASSWORD` = '%s'", DB_Escape(pname(playerid)), DB_Escape(inputtext));
				res = db_query(Server, query);
				if(db_num_rows(res))
				{
					db_free_result(res);
					
					format(query, 500,
					"SELECT * FROM `MAIN_PSTATS` WHERE `USERNAME`='%s'", pname(playerid) );
					res = db_query(Server, query);
					db_get_field_assoc(res, "KILLS", query, 10);
					P[playerid][Kills] = strval(query);
					db_get_field_assoc(res, "DEATHS", query, 10);
					P[playerid][Deaths] = strval(query);
					db_get_field_assoc(res, "XP", query, 10);
					P[playerid][XP] = strval(query);
					db_get_field_assoc(res, "MONEY", query, 20);
					P[playerid][Money] = strval(query);
					db_get_field_assoc(res, "BALANCE", query,20);
					P[playerid][Balance] = strval(query);
					db_free_result(res);
					
					format(query, 500,
					"SELECT * FROM `MINING` WHERE `USERNAME`='%s'", pname(playerid));
					res = db_query(Server, query);
					db_get_field_assoc(res, "ORE", query, 20);
					M[playerid][Metals][METAL_ORE] = strval(query);
					db_get_field_assoc(res, "COPPER", query, 20);
					M[playerid][Metals][METAL_COPPER] = strval(query);
					db_get_field_assoc(res, "TIN", query, 20);
					M[playerid][Metals][METAL_TIN] = strval(query);
					db_get_field_assoc(res, "ORE_CONTAINER", query, 20);
					M[playerid][Metal_Containers][METAL_ORE] = strval(query);
					db_get_field_assoc(res, "COPPER_CONTAINER", query, 20);
					M[playerid][Metal_Containers][METAL_COPPER] = strval(query);
					db_get_field_assoc(res, "TIN_CONTAINER", query, 20);
					M[playerid][Metal_Containers][METAL_TIN] = strval(query);
					db_get_field_assoc(res, "MINING_XP", query, 20);
					M[playerid][Mining_XP] = strval(query);
					db_get_field_assoc(res, "TOOL", query, 20);
					M[playerid][Tool] = strval(query);
					db_free_result(res);
					
					format(query, 500,
					"SELECT * FROM `TIME_STATS` WHERE `USERNAME`='%s'", pname(playerid) );
					res = db_query(Server, query);
					db_get_field_assoc(res, "TIMES_WEEDED", query, 20);
					Time_P[playerid][Times_Weeded] = strval(query);
					db_get_field_assoc(res, "TIMES_MINED", query, 20);
					Time_P[playerid][Times_Mined] = strval(query);
					db_get_field_assoc(res, "TIMES_FISHED", query, 20);
					Time_P[playerid][Times_Fished] = strval(query);
					db_get_field_assoc(res, "TIMES_PUNISHED", query, 20);
					Time_P[playerid][Times_Punished] = strval(query);
					db_get_field_assoc(res, "TIMES_VISITED", query, 20);
					Time_P[playerid][Times_played] = strval(query);
					db_get_field_assoc(res, "HOURS_PLAYED", query, 20);
					Time_P[playerid][Hours_played] = strval(query);
					db_get_field_assoc(res, "MINUTES_PLAYED", query, 20);
					Time_P[playerid][Minutes_played] = strval(query);
					db_get_field_assoc(res, "SECONDS_PLAYED", query, 20);
					Time_P[playerid][Seconds_played] = strval(query);
					db_free_result(res);

					format(query, 500,
					"SELECT * FROM `SERVER_STATS` WHERE `USERNAME`='%s'", pname(playerid) );
					res = db_query(Server, query);
					db_get_field_assoc(res, "ADMINLEVEL", query, 20);
					Server_P[playerid][AdminLevel] = strval(query);
					db_get_field_assoc(res, "VIPLEVEL", query, 20);
					Server_P[playerid][VIPLevel] = strval(query);
					db_get_field_assoc(res, "DONATED", query, 25);
					Server_P[playerid][Donated] = floatstr(query);
					db_get_field_assoc(res, "REG_YEAR", query, 20);
					Server_P[playerid][Reg_year] = strval(query);
					db_get_field_assoc(res, "REG_MONTH", query, 20);
					Server_P[playerid][Reg_month] = strval(query);
					db_get_field_assoc(res, "REG_DATE", query, 20);
					Server_P[playerid][Reg_date] = strval(query);
					db_free_result(res);
					
					format(query, 500,
					"SELECT * FROM `OWNERSHIP_STATS` WHERE `USERNAME`='%s'", pname(playerid) );
					res = db_query(Server, query);
					db_get_field_assoc(res, "CAR1", query, 5);
					Owner_P[playerid][Cars][0] = strval(query);
					db_get_field_assoc(res, "CAR2", query, 5);
					Owner_P[playerid][Cars][1] = strval(query);
					db_get_field_assoc(res, "HOUSE", query, 5);
					Owner_P[playerid][House] = strval(query);
					db_free_result(res);
					
					format(query, 500,
					"SELECT * FROM `NOTIFY_STATS` WHERE `USERNAME`='%s'", pname(playerid) );
					res = db_query(Server, query);
					db_get_field_assoc(res, "JOINLEAVE", query, 5);
					Notify_P[playerid][Join_Leave_News] = strval(query);
					db_get_field_assoc(res, "PRVTNEWS", query, 5);
					Notify_P[playerid][Prvt_News] = strval(query);
					db_get_field_assoc(res, "ADMINS",  query, 5);
					Notify_P[playerid][Admin_News] = strval(query);
					db_get_field_assoc(res, "SPRRES", query, 5);
					Notify_P[playerid][Spree_News] = strval(query);
					db_get_field_assoc(res, "CAPTURES", query, 5);
					Notify_P[playerid][Captures_News] = strval(query);
					db_free_result(res);
				}
			}
		}
		case DIALOG_REGISTER:
        {
            if(response)
            {
                new Query[256];
                if(strlen(inputtext) > 24 || strlen(inputtext) < 3)
                {
                    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registeration", "Welcome to our server! \r\nYou're not registered! Please type in the password you'd like to register with! \r\nYour password needs to be at least 3 characters and maximum 24 characters long", "Register", "Quit");
                }
                else
                {
					RegisterUser(playerid, inputtext);
                    new DBResult:Result = db_query(Server, Query);
                    db_free_result(Result);
                    SendClientMessage(playerid, ORANGE, "[SERVER] You're registered successfully! You'll now be taken to team selection... ");
				}
			}
			else return KickEx_(playerid, "You chose to be kicked rather than register.");
        }
	}
	return 1;
}

stock IsNumeric(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}

stock GetLockState(lock)
{
	new st[20];
	if(lock == 0) st = "Unlocked";
	else if(lock == 1) st = "Locked";
	return st;
}

stock GetVehicleDriver(vehicleid)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(GetPlayerVehicleID(i) == vehicleid && GetPlayerState(i) == PLAYER_STATE_DRIVER) return i; //Returns playerid if the player is in the vehicleid provided AND is the driver
    }
    return 1;
}

stock ShowATMScreen(toplayer)
{
	for(new x=0; x < 9; x++)
	{
	    TextDrawShowForPlayer(toplayer, Bank[x]);
	}
	SelectTextDraw(toplayer, INDIANRED);
	TogglePlayerControllable(toplayer, false);
	SendClientMessage(toplayer, INDIANRED, "Use /stopbanking to close ATM screen! ");
	return 1;
}

stock HideATMScreen(fromplayer)
{
	for(new x=0;x < 9; x++)
	{
	    TextDrawHideForPlayer(fromplayer, Bank[x]);
	}
    CancelSelectTextDraw(fromplayer);
    TogglePlayerControllable(fromplayer, true);
	return 1;
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

stock SaveCar(vid)
{
	new str[500];
	format(str, 200, "SELECT * FROM `VEHICLES` WHERE `ID` = '%d' ", vid);
	new DBResult:res = db_query(Server, str);
	if(!db_num_rows(res)) return 0;
	else
	{
	    format(str, 500,
		"UPDATE VEHICLES SET OWNER='%s', MODEL='%d', CARCOL1='%d', CARCOL2='%d', LOCKED='%d', PARKX = '%f', \
		 PARKY = '%f', PARKZ = '%f', PARKROT = '%f', COST ='%d' WHERE `ID`='%d'",
		DB_Escape(V[vid][Owner]), V[vid][Model], V[vid][Carcol][0], V[vid][Carcol][1], V[vid][Locked],
		V[vid][Park][0], V[vid][Park][1], V[vid][Park][2], V[vid][Park][3], V[vid][Cost], vid);
		db_free_result(res);
		res = db_query(Server, str);
		if(!res) print("car save query failed");
	}
	db_free_result(res);
	return 1;
}

stock SaveHouse(hid)
{
	new str[500];
	format(str, 200, "SELECT * FROM `HOUSES` WHERE `ID` = '%d' ", hid);
	new DBResult:res = db_query(Server, str);
	if(!db_num_rows(res)) return 0;
	else
	{
	    format(str, 500,
	    "UPDATE HOUSES SET NAME='%s', OWNER='%s', VALUE='%d', ENTRYX='%f', ENTRYY='%f', ENTRYZ='%f', MONEYINSIDE='%d', TYPE='%d', LOCK='%d' WHERE ID = '%d'",
	    DB_Escape(H[hid][Name]), DB_Escape(H[hid][OwnedBy]), H[hid][Value], H[hid][Entry][0], H[hid][Entry][1], H[hid][Entry][2], H[hid][MoneyInside], H[hid][Type], H[hid][Lock], hid);
		db_free_result(res);
		res = db_query(Server, str);
		if(!res) print("house save query failed");
	}
	db_free_result(res);
	return 1;
}

stock CreateVehicleEx(modelid, Float:X, Float:Y, Float:Z, Float:ROT, carcol1, carcol2, owner[], cost)
{
    new str[500],
	vid = vehicle_count;
	if(IsValidVehicle(vid)) DestroyVehicle(vid);
    format(str, 200, "SELECT * FROM `VEHICLES` WHERE `ID` = '%d'", vid);
    new DBResult:res = db_query(Server, str);
    if(!db_num_rows(res))
    {
		V[vid][Model] = modelid;
		format(V[vid][Owner], 40, "%s", owner);
		V[vid][Carcol][0] = carcol1;
		V[vid][Carcol][1] = carcol2;
		V[vid][Park][0] = X;
		V[vid][Park][1] = Y;
		V[vid][Park][2] = Z;
		V[vid][Park][3] = ROT;
		V[vid][Cost] = cost;
		CreateVehicle(modelid, X, Y, Z, ROT, carcol1, carcol2, -1);
		format(str, 500,
		"INSERT INTO `VEHICLES`(`ID`, `OWNER`, `MODEL`, `CARCOL1`, `CARCOL2`, `LOCKED`, `PARKX`, `PARKY`, `PARKZ`, `PARKROT`, `COST`) \
		VALUES ('%d', '%s', '%d', '%d', '%d', '%d', '%f', '%f', '%f', '%f', '%d')",
		vid, DB_Escape(owner), modelid, carcol1, carcol2, 0, X, Y, Z, ROT, cost);
		db_free_result(res);
		res = db_query(Server, str);
		vehicle_count++;
	}
	else
	{
	    db_get_field_assoc(res, "OWNER", V[vid][Owner], 40);
	    db_get_field_assoc(res, "CARCOL1", str, 5);
	    V[vid][Carcol][0] = strval(str);
	    db_get_field_assoc(res, "CARCOL2", str, 5);
	    V[vid][Carcol][1] = strval(str);
	    db_get_field_assoc(res, "MODEL", str, 5);
	    V[vid][Model] = strval(str);
	    db_get_field_assoc(res, "PARKX", str, 20);
	    V[vid][Park][0] = floatstr(str);
	    db_get_field_assoc(res, "PARKY", str, 20);
	    V[vid][Park][1] = floatstr(str);
	    db_get_field_assoc(res, "PARKZ", str, 20);
	    V[vid][Park][2] = floatstr(str);
		db_get_field_assoc(res, "PARKROT", str, 20);
		V[vid][Park][3] = floatstr(str);
		db_get_field_assoc(res, "COST", str, 20);
		V[vid][Cost] = strval(str);
		CreateVehicle(V[vid][Model], V[vid][Park][0], V[vid][Park][1], V[vid][Park][2], V[vid][Park][3], V[vid][Carcol][0], V[vid][Carcol][1], -1);
		vehicle_count++;
	}
	SetVehicleToRespawn(vid);
	db_free_result(res);
	return 1;
}

stock IsPointInRangeOfPoint(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2, Float:range)
{
    x2 -= x;
    y2 -= y;
    z2 -= z;
    return ((x2 * x2) + (y2 * y2) + (z2 * z2)) < (range * range);
}

stock CreateHouse(name[], owner[], Float:eX, Float:eY, Float:eZ, type, value)
{
	new str[500], hid = house_count;
	format(str, 200, "SELECT * FROM `HOUSES` WHERE `ID` = '%d' ", hid);
	new DBResult:res;
	res = db_query(Server, str);
	if(!db_num_rows(res))
	{
		format(H[hid][OwnedBy], 24, "%s", owner);
		format(H[hid][Name], 80, "%s", name);
		H[hid][Entry][0] = eX;
		H[hid][Entry][1] = eY;
		H[hid][Entry][2] = eZ;
		H[hid][Type] = type;
		H[hid][Value] = value;
		format(str, 120, "%s[%d]\nOwned by %s\nValue $%d\nHouse type: %s", H[hid][Name], hid, H[hid][OwnedBy], H[hid][Value], GetTypeName(type) );
		H[hid][Info] = Create3DTextLabel(str, LIGHTBLUE, eX, eY, eZ, 50.0, 0, 1);
		H[hid][Pickup] = CreatePickup( GetPickupModel(hid), 1, eX, eY, eZ, -1);
		format(str, 500,
		"INSERT INTO `HOUSES`(`ID`, `NAME`, `OWNER`, `ENTRYX`, `ENTRYY`, `ENTRYZ`, `TYPE`, `LOCK`, `VALUE`, `MONEYINSIDE`) \
		VALUES ('%d', '%s', '%s', '%f', '%f', '%f', '%d', '0', '%d', '0')",
		hid, DB_Escape(H[hid][Name]), DB_Escape(H[hid][OwnedBy]), H[hid][Entry][0], H[hid][Entry][1], H[hid][Entry][2], H[hid][Type], H[hid][Value]);
        db_free_result(res);
		res = db_query(Server, str);
		if(!res) print("house query failed");
		house_count++;
	}
	else
	{
		db_get_field_assoc(res, "NAME", H[hid][Name], 80);
		db_get_field_assoc(res, "OWNER", H[hid][OwnedBy], 24);
		db_get_field_assoc(res, "ENTRYX", str, 20);
		H[hid][Entry][0] = floatstr(str);
		db_get_field_assoc(res, "ENTRYY", str, 20);
		H[hid][Entry][1] = floatstr(str);
		db_get_field_assoc(res, "ENTRYZ", str, 20);
		H[hid][Entry][2] = floatstr(str);
		db_get_field_assoc(res, "TYPE", str, 20);
		H[hid][Type] = strval(str);
		db_get_field_assoc(res, "LOCK", str, 5);
		H[hid][Lock] = strval(str);
		db_get_field_assoc(res, "VALUE", str, 20);
		H[hid][Value] = strval(str);
		db_get_field_assoc(res, "MONEYINSIDE", str, 20);
		H[hid][MoneyInside] = strval(str);
		format(str, 120, "%s[%d]\nOwned by %s\nValue $%d\nHouse type: %s", H[hid][Name], hid, H[hid][OwnedBy], H[hid][Value], GetTypeName(H[hid][Type]) );
		H[hid][Info] = Create3DTextLabel(str, LIGHTBLUE, eX, eY, eZ, 50.0, 0, 1);
		H[hid][Pickup] = CreatePickup(GetPickupModel(hid), 1, eX, eY, eZ, -1);
		house_count++;
	}
	db_free_result(res);
	return 1;
}

stock LoadHouses()
{
	new str[500], DBResult:res;
	for(new x=0; x< MAX_HOUSES; x++)
	{
	    format(str, 500, "SELECT * FROM `HOUSES` WHERE `ID` = '%d' ", x);
	    res = db_query(Server, str);
	    if(db_num_rows(res))
	    {
			db_get_field_assoc(res, "NAME", H[x][Name], 80);
			db_get_field_assoc(res, "OWNER", H[x][OwnedBy], 24);
			db_get_field_assoc(res, "ENTRYX", str, 20);
			H[x][Entry][0] = floatstr(str);
			db_get_field_assoc(res, "ENTRYY", str, 20);
			H[x][Entry][1] = floatstr(str);
			db_get_field_assoc(res, "ENTRYZ", str, 20);
			H[x][Entry][2] = floatstr(str);
			db_get_field_assoc(res, "TYPE", str, 20);
			H[x][Type] = strval(str);
			db_get_field_assoc(res, "LOCK", str, 5);
			H[x][Lock] = strval(str);
			db_get_field_assoc(res, "VALUE", str, 20);
			H[x][Value] = strval(str);
			db_get_field_assoc(res, "MONEYINSIDE", str, 20);
			H[x][MoneyInside] = strval(str);
			format(str, 120, "%s[%d]\nOwned by %s\nValue $%d\nHouse type: %s", H[x][Name], x, H[x][OwnedBy], H[x][Value], GetTypeName(H[x][Type]) );
			H[x][Info] = Create3DTextLabel(str, LIGHTBLUE, H[x][Entry][0], H[x][Entry][1], H[x][Entry][2], 50.0, 0, 1);
			H[x][Pickup] = CreatePickup(GetPickupModel(x), 1, H[x][Entry][0], H[x][Entry][1], H[x][Entry][2], -1);
			house_count++;
			continue;
		}
		else return 0;
	}
	return 1;
}

stock LoadCars()
{
	new str[500], DBResult:res;
	for(new x=0; x < MAX_VEHICLES; x++)
	{
	    format(str, 500, "SELECT * FROM `VEHICLES` WHERE `ID`='%d'", x);
	    res = db_query(Server, str);
	    if(db_num_rows(res))
	    {
		    db_get_field_assoc(res, "OWNER", V[x][Owner], 40);
		    db_get_field_assoc(res, "CARCOL1", str, 5);
		    V[x][Carcol][0] = strval(str);
		    db_get_field_assoc(res, "CARCOL2", str, 5);
		    V[x][Carcol][1] = strval(str);
		    db_get_field_assoc(res, "MODEL", str, 5);
		    V[x][Model] = strval(str);
		    db_get_field_assoc(res, "PARKX", str, 20);
		    V[x][Park][0] = floatstr(str);
		    db_get_field_assoc(res, "PARKY", str, 20);
		    V[x][Park][1] = floatstr(str);
		    db_get_field_assoc(res, "PARKZ", str, 20);
		    V[x][Park][2] = floatstr(str);
			db_get_field_assoc(res, "PARKROT", str, 20);
			V[x][Park][3] = floatstr(str);
			db_get_field_assoc(res, "COST", str, 20);
			V[x][Cost] = strval(str);
			CreateVehicle(V[x][Model], V[x][Park][0], V[x][Park][1], V[x][Park][2], V[x][Park][3], V[x][Carcol][0], V[x][Carcol][1], -1);
			vehicle_count++;
			continue;
		}
	}
	return 1;
}
	

stock GetTypeName(type)
{
	new hstr[80];
	switch(type)
	{
		case HOUSE_SMALL: hstr = "Small";
		case HOUSE_MEDIUM: hstr = "Medium";
		case HOUSE_BIG: hstr = "Big";
		case HOUSE_HUGE: hstr = "Huge";
		case HOUSE_HOTEL: hstr = "Hotel";
	}
	return hstr;
}

stock GetHouseExit(houseid, &Float:X, &Float:Y, &Float:Z, &interior)
{
	new type = H[houseid][Type];
	switch(type)
	{
	    case HOUSE_SMALL:
	    {
			interior = 15;
			X = 295.138977;
			Y = 1474.469971;
			Z = 1080.519897;
		}
		case HOUSE_MEDIUM:
		{
		    interior = 2;
		    X = 225.756989;
			Y = 1240.000000;
			Z = 1082.149902;
		}
		case HOUSE_BIG:
		{
		    interior = 3;
		    X = 235.508994;
			Y = 1189.169897;
			Z = 1080.339966;
		}
		case HOUSE_HUGE:
		{
		    interior = 5;
		    X = 1299.14;
			Y = -794.77;
			Z = 1084.00;
		}
		case HOUSE_HOTEL:
		{
		    interior = 18;
		    X = 1710.433715;
			Y = -1669.379272;
			Z = 20.225049;
		}
	}
	return 1;
}
	

stock GetPickupModel(houseid)
{
	if(strcmp(H[houseid][OwnedBy], "Unowned", false) == 0) return 1273;
	else return 1272;
}

stock CreateATM(Float:x, Float:y, Float:z, Float:rX, Float:rY, Float:rZ)
{
	if(atm_count > MAX_ATMS) return printf("cant create more atms as it exceeds max limit of %d", MAX_ATMS);
	else
	{
	    new atmid = atm_count;
	    A[atmid][Object] = CreateObject(2942, x, y, z, rX, rY, rZ, 300.0);
	    new str[120];
	    format(str, 120, "ATM %d\nType /bank to use", atmid);
	    A[atmid][AText] = Create3DTextLabel(str, LIGHTBLUE, x, y, z, 75.0, 0, 1);
	    A[atmid][APos][0] = x;
	    A[atmid][APos][1] = y;
	    A[atmid][APos][2] = z;
		atm_count++;
	}
	return 1;
}
	


stock CreateCarDealership(id, Float:X, Float:Y, Float:Z)
{
	Dealership[id][0] = X;
	Dealership[id][1] = Y;
	Dealership[id][2] = Z;
	new str[120];
	format(str, 120, "Car dealership\n%s", GetDealerShipName(id) );
	Create3DTextLabel(str, LIGHTBLUE, X, Y, Z, 100.0, 0);
	return 1;
}

stock GetDealerShipName(dealershipid)
{
	new dsnm[80];
	switch(dealershipid)
	{
	    case DEALERSHIP_LS_RODEO: dsnm = "Rodeo Dealership";
	    default: dsnm = "Vehicle dealership";
	}
	return dsnm;
}

stock IsVehicleInRangeOfPoint(vehicleid, Float:range, Float:x, Float:y, Float:z)
{
	new Float:px,Float:py,Float:pz;
	GetVehiclePos(vehicleid,px,py,pz);
	px -= x;
	py -= y;
	pz -= z;
	return ((px * px) + (py * py) + (pz * pz)) < (range * range);
}

stock IsPlayerNearDealership(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		for(new x=0; x < MAX_CAR_DEALERSHIPS; x++)
		{
		    if(IsPlayerInRangeOfPoint(playerid, 15.0, Dealership[x][0], Dealership[x][1], Dealership[x][2])) return 1;
		    else return -1;
		}
	}
	else
	{
	    new vid = GetPlayerVehicleID(playerid);
		for(new x=0; x < MAX_CAR_DEALERSHIPS; x++)
		{
		    if(IsVehicleInRangeOfPoint(vid, 15.0, Dealership[x][0], Dealership[x][1], Dealership[x][2])) return 1;
			else return -1;
		}
	}
	return -1;
}

stock pname(playerid)
{
	new name[24];
	GetPlayerName(playerid, name, 24);
	return name;
}

stock GetPlayerMoneyEx(playerid)
{
	return GetPlayerMoney(playerid);
}

stock GivePlayerMoneyEx(playerid, money)
{
	GivePlayerMoney(playerid, money);
	return P[playerid][Money] += money;
}

stock GetColorID(str[])
{
	if(isnull(str)) return -1;
	if(strcmp(str, "black", true) == 0) return 0;
	else if(strcmp(str, "white", true) == 0) return 1;
	else if(strcmp(str, "lightblue", true) == 0) return 2;
	else if(strcmp(str, "red", true) == 0) return 3;
	else if(strcmp(str, "grey", true) == 0) return 4;
	else if(strcmp(str, "pink", true) == 0) return 5;
	else if(strcmp(str, "yellow", true) == 0) return 6;
	return -1;
}

stock RegisterUser(playerid, pass[])
{
	if(Tmp_P[playerid][Registered] == true) return 0;
	else
	{
		format(Server_P[playerid][Password], 80, "%s", pass);
	    new query[500];
	    format(query, 500, "INSERT INTO `MINING`(`USERNAME`, `ORE`, `COPPER`, `TIN`, `ORE_CONTAINER`, `COPPER_CONTAINER`, `TIN_CONTAINER`, `MINING_XP`, `TOOL`) \
		VALUES ('%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d')",
		DB_Escape(pname(playerid)), M[playerid][Metals][METAL_ORE], M[playerid][Metals][METAL_COPPER], M[playerid][Metals][METAL_TIN],
		M[playerid][Metal_Containers][METAL_ORE], M[playerid][Metal_Containers][METAL_COPPER], M[playerid][Metal_Containers][METAL_TIN],
		M[playerid][Mining_XP], M[playerid][Tool] );
		db_query(Server, query);
		
		format(query, 500, "INSERT INTO `MAIN_PSTATS`(`USERNAME`,`KILLS`, `DEATHS`, `XP`, `MONEY`, `BALANCE`) \
		VALUES ('%s', '%d', '%d', '%d', '%d', '%d')", DB_Escape(pname(playerid)), P[playerid][Kills], P[playerid][Deaths], P[playerid][XP],
		P[playerid][Money], P[playerid][Balance] );
		db_query(Server, query);
		
		format(query, 500, "INSERT INTO `TIME_STATS`(`USERNAME`, `TIMES_WEEDED`, `TIMES_MINED`, `TIMES_FISHED`, `TIMES_PUNISHED`, `TIMES_VISITED`, `HOURS_PLAYED`, `MINUTES_PLAYED`, `SECONDS_PLAYED`) \
		VALUES('%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d') ",
		DB_Escape(pname(playerid)) , Time_P[playerid][Times_Weeded], Time_P[playerid][Times_Mined], Time_P[playerid][Times_Fished], Time_P[playerid][Times_Punished], Time_P[playerid][Times_played],
		Time_P[playerid][Hours_played], Time_P[playerid][Minutes_played], Time_P[playerid][Seconds_played] );
		db_query(Server, query);

		new year, month, day;
		getdate(year, month, day);
        format(query, 500, "INSERT INTO `SERVER_STATS`(`USERNAME`, `IP`, `PASSWORD`, `ADMINLEVEL`, `VIPLEVEL`, `DONATED`, `REG_YEAR`, `REG_MONTH`, `REG_DATE`) \
		VALUES('%s', '%s', '%s', '%d', '%d', '%f', '%d', '%d', '%d')",

		DB_Escape( pname(playerid) ),
		DB_Escape( pip(playerid) ),
		DB_Escape(Server_P[playerid][Password]),
		Server_P[playerid][AdminLevel],
		Server_P[playerid][VIPLevel],
		Server_P[playerid][Donated],
		year, month, day
		);
		
		db_query(Server, query);
		
		format(query, 500,
		"INSERT INTO `OWNERSHIP_STATS`(`USERNAME`,`CAR1`, `CAR2`, `HOUSE`) VALUES('%s', '%d', '%d', '%d')",
		DB_Escape(pname(playerid)), Owner_P[playerid][Cars][0], Owner_P[playerid][Cars][1], Owner_P[playerid][House] );
		db_query(Server, query);

		format(query, 500,
		"INSERT INTO `INVENTORY_STATS`(`USERNAME`,`WEED`, `SEEDS`, `FISHBAIT`, `TUNA`, `SNAPPER`, `NEEDLEFISH`, `FERTILIZERS`)\
		VALUES('%s', '0', '0', '0','0', '0', '0', '0')",
		pname(playerid) );
		db_query(Server, query);
		
		format(query, 500,
		"INSERT INTO `NOTIFY_STATS`(`USERNAME`,`JOINLEAVE`, `SPREES`, `CAPTURES`, `ADMINS`, `PRVTNEWS`) \
		VALUES('%s', '%d', '%d', '%d', '%d', '%d')",
		pname(playerid),Notify_P[playerid][Join_Leave_News], Notify_P[playerid][Spree_News],
	  	Notify_P[playerid][Captures_News], Notify_P[playerid][Admin_News],
	   	Notify_P[playerid][Prvt_News]
	   	);
	   	db_query(Server, query);

		Tmp_P[playerid][Registered] = true;
	}
	return 1;
}

stock pip(playerid)
{
	new ip[20];
	GetPlayerIp(playerid, ip, 20);
	format(Server_P[playerid][IP], 20, "%s", ip);
	return ip;
}

stock SaveUser(id, save_type)
{
    if(Temp_P[playerid][Registered] != true) return 0;
	new query[500],  DBResult:res;
	switch(save_type)
	{
	    case SAVE_TYPE_MINING:
	    {
			format(query, 500,
			"SELECT * FROM `MINING` WHERE `USERNAME` = '%s' ", pname(id) );
			res = db_query(Server, query);
			if(db_num_rows(res))
			{
			    format(query, 500,
			    "UPDATE MINING SET ORE='%d',COPPER='%d',TIN='%d',ORE_CONTAINER='%d',COPPER_CONTAINER='%d',TIN_CONTAINER='%d', \
				TOOL='%d', MININGXP='%d' WHERE `USERNAME`='%s' ",
			    M[id][Metals][METAL_ORE], M[id][Metals][METAL_COPPER], M[id][Metals][METAL_TIN], M[id][Metal_Container][METAL_ORE],
			    M[id][Metal_Container][METAL_COPPER], M[id][Metal_Container][METAL_TIN], M[id][Tool], M[id][Mining_XP], DB_Escape(pname(id)) );
				db_query(Server, query);
				db_free_result(res);
			}
			else return db_free_result(res);
		}
		case SAVE_TYPE_TIMING:
		{
		    format(query, 500,
		    "SELECT * FROM `TIME_STATS` WHERE `USERNAME` = '%s' ", pname(id) );
		    res = db_query(Server, query);
		    if(db_num_Rows(res))
		    {
				format(query, 500,
				"UPDATE TIME_STATS SET TIMES_WEEDED='%d',TIMES_MINED='%d',TIMES_FISHED='%d',TIMES_PUNISHED='%d',HOURS_PLAYED='%d',MINUTES_PLAYED='%d',SECONDS_PLAYED='%d',TIMES_PLAYED='%d' ",
				Time_P[playerid][Times_Weeded], Time_P[playerid][Times_Mined], Time_P[playerid][Times_Fished],
				Time_P[playerid][Times_Punished], Time_P[playerid][Hours_played], Time_P[playerid][Minutes_played], Time_P[playerid][Seconds_played], Time_P[playerid][Times_played]);
				db_query(Server, query);
				db_free_result(res);
			}
			else return db_free_result(res);
		}
		
		case SAVE_TYPE_MAIN:
		{
			format(query, 500,
			"SELECT * FROM `MAIN_STATS` WHERE `USERNAME` = '%s' ", pname(id) );
			res = db_query(Server, query);
			if(db_num_rows(res))
			{
				format(query, 500,
				"UPDATE MAIN_STATS SET KILLS='%d',DEATHS='%d',XP='%d',MONEY='%d',BALANCE='%d' WHERE `USERNAME`='%s'",
				P[playerid][Kills], P[playerid][Deaths], P[playerid][XP], P[playerid][Money], P[playerid][Balance],
				DB_Escape(pname(playerid)) );
				db_query(Server, query);
				db_free_result(res);
			}
		}
		case SAVE_TYPE_SAVESTATS:
		{
		    format(query, 500,
		    "SELECT * FROM `SERVER_STATS` WHERE `USERNAME`='%s'", pname(id) );
		    res = db_query(Server, query);
		    if(db_num_rows(res))
		    {
		        format(query, 500,
		        "UPDATE SERVER_STATS SET PASSWORD='%s',IP='%s',ADMINLEVEL='%d',VIPLEVEL='%d',DONATED='%f',REG_YEAR='%d',REG_MONTH='%d',REG_DAY='%d'",
				DB_Escape(Server_P[playerid][Password]), DB_Escape(Server_P[playerid][IP])
				db_query(Server, query);
				db_free_result(res);
		    }
		}
		case SAVE_TYPE_OWNERSHIP:
		{
		    format(query, 500,
		    "SELECT * FROM `MAIN_STATS` WHERE `USERNAME`='%s'", pname(id) );
		    res = db_query(Server, query);
			if(db_num_rows(res))
			{
			    format(query, 500,
			    "UPDATE OWNERSHIP_STATS SET CAR1='%d',CAR2='%d',HOUSE='%d' WHERE `USERNAME`='%s'",
			    Owner_P[id][Car][0], Owner_P[id][Car][1], Owner_P[id][House], DB_Escape(pname(id)) );
				db_query(Server, query);
				db_free_result(res);
			}
		}
		case SAVE_TYPE_INVENTORY:
		{
		    format(query, 500,
		    "SELECT * FROM `MAIN_STATS` WHERE `USERNAME`='%s'", pname(id) );
		    res = db_query(Server, query);
		    if(db_num_rows(res))
		    {
		        format(query, 500,
		        "UPDATE INVENTORY_STATS SET WEED='%d',SEEDS='%d',FISHBAIT='%d',TUNA='%d',SNAPPER='%d',NEEDLEFISH='%d',FERTILIZIERS='%d' WHERE `USERNAME`='%s'",
		        Invent_P[id][Weed], Invent_P[id][Seeds], Invent_P[id][Fishbait], Invent_P[id][Fishes][FISH_TUNA],
		        Invent_P[id][Fishes][FISH_SNAPPER], Invent_P[id][Fishes][FISH_NEEDLEFISH], Invent_P[id][Fertilizers] );
				db_query(Server, query);
				db_free_result(res);
			}
		}
		case SAVE_TYPE_NOTIFY:
		{
		    format(query, 500,
		    "SELECT * FROM `MAIN_STATS` WHERE `USERNAME`='%s'", pname(id) );
		    res = db_query(Server, query);
		    if(db_num_rows(res))
		    {
		        format(query, 500,
		        "UPDATE NOTIFY_STATS SET JOINLEAVE='%d',SPREES='%d',CAPTURES='%d',ADMINS='%d',PRVTNEWS='%d'",
		        Notify_P[playerid][Join_Leave_News], Notify_P[playerid][Spree_News],
		        Notify_P[playerid][Captures_News], Notify_P[playerid][Admin_News],
		        Notify_P[playerid][Prvt_News]
		        );
		        db_query(Server, query);
		        db_free_result(res);
			}
		}
	}
}

stock ResetUser(playerid)
{
	Tmp_P[playerid][Inside] = -1;
	Tmp_P[playerid][Registered] = false;
	P[playerid][Kills] = 0;
	P[playerid][Deaths] = 0;
	P[playerid][XP] = 0;
	P[playerid][Money] = 0;
	P[playerid][Balance] = 0;
	for(new x=0; x < 3; x++)
	{
		M[playerid][Metals][x] = 0;
		M[playerid][Metal_Containers][x] = 0;
	}
	M[playerid][Tool] = MINING_TOOL_DEFAULT;
	M[playerid][Mining_XP] = 0;
	Time_P[playerid][Hours_played] = 0;
	Time_P[playerid][Minutes_played] = 0;
	Time_P[playerid][Seconds_played] = 0;
	Owner_P[playerid][Cars][0] = 9999;
	Owner_P[playerid][Cars][1] = 9999;
	Owner_P[playerid][House]  = 9999;
	format(Server_P[playerid][IP], 20, "nill");
	format(Server_P[playerid][Password], 20, "nAn");
	Server_P[playerid][AdminLevel] = 0;
	Server_P[playerid][VIPLevel] = 0;
	Server_P[playerid][Donated] = 0.0;
	Server_P[playerid][Reg_date] = 1;
	Server_P[playerid][Reg_month] = 1;
	Server_P[playerid][Reg_year] = 2013;
	Invent_P[playerid][Weed] = 0;
	Invent_P[playerid][Seeds] = 0;
	Invent_P[playerid][Fishbait] = 0;
	Invent_P[playerid][Fertilizers] = 0;
	for(new x =0; x < 3; x++)
	{
	    Invent_P[playerid][Fishes][x] = 0;
	}
	Notify_P[playerid][Join_Leave_News] = 0;
	Notify_P[playerid][Spree_News] = 0;
	Notify_P[playerid][Captures_News] = 0;
	Notify_P[playerid][Admin_News] = 0;
	Notify_P[playerid][Prvt_News] = 0;
	return 1;
}

stock KickEx_(playerid, str[])
{
	SendClientMessage(playerid, RED, str);
	SetTimerEx("KickPublic", 1000, 0, "d", playerid);
	return 1;
}

stock ShowCarFunctions(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, INDIANRED, "[ERROR] You need to be in a car to use this command! ");
	else
	{
	    for(new x=0; x < 12; x++)
	    {
	        TextDrawShowForPlayer(playerid, CarInfo[x]);
		}
		SelectTextDraw(playerid, INDIANRED);
		SendClientMessage(playerid, INDIANRED, "[SERVER] Use ESC key or /stopcarfunc command to hide this screen! ");
	}
	return 1;
}

stock HideCarFunctions(playerid)
{
	for(new x=0; x < 12; x++)
	{
	    TextDrawHideForPlayer(playerid, CarInfo[x]);
	}
    CancelSelectTextDraw(playerid);
    return 1;
}

CMD:carcols(playerid, params[])
{
	SendClientMessage(playerid, LIGHTBLUE, "____ Vehicle color ID's ____ ");
	SendClientMessage(playerid, LIGHTBLUE, "black, white, lightblue, red, grey, pink, yellow");
	return 1;
}

CMD:carcolor(playerid ,params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, INDIANRED, "You're not in any vehicle! ");
	else
	{
	    new vid = GetPlayerVehicleID(playerid);
	    if(IsPlayerNearDealership(playerid) == -1) return SendClientMessage(playerid, INDIANRED, "You're not near any dealership! ");
	    if(strcmp(V[vid][Owner], pname(playerid), false) == 0)
	    {
			new col1[10], col2[10];
			if(sscanf(params, "s[10]s[10]", col1, col2)) return SendClientMessage(playerid, INDIANRED, "[SERVER] /carcolor [color1 name] [color2 name] (/carcols for list) ");
			else
			{
			    new carcol[2];
			    carcol[0] = GetColorID(col1);
			    carcol[1] = GetColorID(col2);
			    if(carcol[0] == -1 || carcol[1] == -1) return SendClientMessage(playerid, INDIANRED, "[SERVER] Please make sure the spelling are right! ");
				else
				{
				    V[vid][Carcol][0] = carcol[0];
				    V[vid][Carcol][1] = carcol[1];
				    ChangeVehicleColor(vid, carcol[0], carcol[1]);
					new str[120];
					format(str, 120, "[SERVER] Car color's changed to [1: %s] and [2: %s]", col1, col2);
					SendClientMessage(playerid, GREEN, str);
				}
			}
		}
		else return SendClientMessage(playerid, INDIANRED, "[ERROR] This isn't your car! ");
	}
	return 1;
}

CMD:carlock(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, INDIANRED,  "You're not in any vehicle! ");
	else
	{
	    new vid = GetPlayerVehicleID(playerid);
	    if(strcmp(V[vid][Owner], pname(playerid), false) == 0)
	    {
	        if(V[vid][Locked] == 0)
	        {
	            SendClientMessage(playerid, INDIANRED, "Car locked");
				V[vid][Locked] = 1;
			}
			else if(V[vid][Locked] == 1)
			{
			    SendClientMessage(playerid, GREEN , "Car unlocked");
				V[vid][Locked] = 0;
			}
		}
		else return SendClientMessage(playerid, INDIANRED, "[ERROR] This isn't your car! ");
	}
	return 1;
}

CMD:enter(playerid, params[])
{
	if(Tmp_P[playerid][Inside] == -1)
	{
	    for(new x=0; x < MAX_HOUSES; x++)
	    {
	        if(IsPlayerInRangeOfPoint(playerid, 2.0, H[x][Entry][0], H[x][Entry][1], H[x][Entry][2]))
	        {
	            if(H[x][Lock] == 0)
	            {
		            new Float:Pos[3], inte;
		            GetHouseExit(x, Pos[0], Pos[1], Pos[2], inte);
		            Tmp_P[playerid][Inside] = x;
		            SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
					SetPlayerInterior(playerid, inte);
					SetPlayerVirtualWorld(playerid, x+inte);
					if(H[x][Type] != HOUSE_HOTEL) SendClientMessage(playerid, LIGHTBLUE , "You entered this house [It is unlocked]");
					else if(H[x][Type] == HOUSE_HOTEL) SendClientMessage(playerid, LIGHTBLUE, "You entered a hotel...");
					break;
				}
				else if(H[x][Lock] == 1)
				{
					if(strcmp(pname(playerid), H[x][OwnedBy], false) == 0)
					{
			            new Float:Pos[3], inte;
			            GetHouseExit(x, Pos[0], Pos[1], Pos[2], inte);
			            Tmp_P[playerid][Inside] = x;
			            SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
						SetPlayerInterior(playerid, inte);
						SetPlayerVirtualWorld(playerid, x+inte);
						SendClientMessage(playerid, LIGHTBLUE, "You entered your own house [It is locked, but you as an owner can enter it]");
						break;
					}
					else
					{
					    SendClientMessage(playerid, INDIANRED, "This house is locked and you're not the owner! ");
					}
				}
			}
		}
	}
	return 1;
}

CMD:exit(playerid, params[])
{
	if(Tmp_P[playerid][Inside] != -1)
	{
		new hid = Tmp_P[playerid][Inside];
		Tmp_P[playerid][Inside] = -1;
		SetPlayerPos(playerid, H[hid][Entry][0], H[hid][Entry][1], H[hid][Entry][2]);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
	}
	return 1;
}

CMD:houselock(playerid, params[])
{
	if(Tmp_P[playerid][Inside] == -1) return SendClientMessage(playerid, INDIANRED, "[ERROR] You're not inside any house! ");
	else
	{
		new hid = Tmp_P[playerid][Inside];
		if(strcmp(H[hid][OwnedBy], pname(playerid) ) == 0)
		{
			if(H[hid][Lock] == 0)
			{
			    H[hid][Lock] = 1;
				SendClientMessage(playerid, INDIANRED, "House locked! ");
			}
			else if(H[hid][Lock] == 1)
			{
			    H[hid][Lock] = 0;
				SendClientMessage(playerid, GREEN , "House unlocked");
			}
		}
	}
	return 1;
}

CMD:storemoney(playerid, params[])
{
	if(Tmp_P[playerid][Inside] == -1) return SendClientMessage(playerid, INDIANRED, "[ERROR] You're not inside any house! ");
	else
	{
		new amt, hid = Tmp_P[playerid][Inside];
		if(sscanf(params, "d", amt)) return SendClientMessage(playerid, INDIANRED, "[ERROR] /storemoney [amount] ");
		if(strcmp(H[hid][OwnedBy], pname(playerid) ) == 0)
		{
		    if(GetPlayerMoneyEx(playerid) < amt) return SendClientMessage(playerid, INDIANRED, "[ERROR] You don't have so much money! ");
		    H[hid][MoneyInside] += amt;
			new str[120];
			format(str, 120, "You stored $ %d inside your house! New balance : %d", amt, H[hid][MoneyInside]);
			SendClientMessage(playerid, GREEN , str);
			GivePlayerMoneyEx(playerid, -amt);
			SaveHouse(hid);
		}
		else
		{
		    SendClientMessage(playerid, INDIANRED, "[ERROR] This isn't your house! ");
		}
	}
	return 1;
}

CMD:withdrawmoney(playerid, params[])
{
	if(Tmp_P[playerid][Inside] == -1) return SendClientMessage(playerid, INDIANRED, "[ERROR] You're not inside any house! ");
	else
	{
	    new amt, hid = Tmp_P[playerid][Inside];
	    if(strcmp(pname(playerid), H[hid][OwnedBy], false) == 0)
	    {
	        if(amt > H[hid][MoneyInside]) return SendClientMessage(playerid, INDIANRED, "[ERROR] Entered amount exceeds house balance! ");
			H[hid][MoneyInside] -= amt;
			new str[120];
			format(str, 120, "You withdrawed $ %d from your house! New balance in house: %d", amt, H[hid][MoneyInside]);
			SendClientMessage(playerid, GREEN, str);
			GivePlayerMoneyEx(playerid, amt);
			SaveHouse(hid);
		}
		else
		{
		    SendClientMessage(playerid, INDIANRED, "[ERROR] This isn't your house! ");
		}
	}
	return 1;
}

CMD:park(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, INDIANRED, "[ERROR] You're not inside any car! ");
	else
	{
	    new vid = GetPlayerVehicleID(playerid);
	    if(strcmp(pname(playerid), V[vid][Owner], false) == 0)
	    {
			new Float:Pos[4];
			GetVehiclePos(vid, Pos[0], Pos[1], Pos[2]);
			GetVehicleZAngle(vid, Pos[3]);
			V[vid][Park][0] = Pos[0];
			V[vid][Park][1] = Pos[1];
			V[vid][Park][2] = Pos[2];
			V[vid][Park][3] = Pos[3];
			GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]+5);
			SendClientMessage(playerid, GREEN, "Parking place of your car has been updated! ");
			SaveCar(vid);
		}
		else
		{
		    SendClientMessage(playerid, INDIANRED, "[ERROR] This is not your car! ");
		}
	}
	return 1;
}

CMD:housename(playerid, params[])
{
	if(Tmp_P[playerid][Inside] == -1) return SendClientMessage(playerid, INDIANRED, "[ERROR] You're not inside any house! ");
	else
	{
	    new hid = Tmp_P[playerid][Inside];
	    if(strcmp(H[hid][OwnedBy], pname(playerid), false) == 0)
	    {
			new nm[80];
			if(sscanf(params, "s[80]", nm)) return SendClientMessage(playerid, INDIANRED, "[ERROR] /housename [new name]");
			else
			{
				format(H[hid][Name], 80, "%s", nm);
				format(nm, 120, "[HOUSE] New house name is '%s' ", H[hid][Name]);
				SendClientMessage(playerid, GREEN, nm);
				format(nm, 120, "%s[%d]\nOwned by %s\nValue $%d\nHouse type: %s", H[hid][Name], hid, H[hid][OwnedBy], H[hid][Value], GetTypeName(H[hid][Type]) );
				Update3DTextLabelText(H[hid][Info], LIGHTBLUE, nm);
				SaveHouse(hid);
			}
		}
	}
	return 1;
}

CMD:bank(playerid, params[])
{
	for(new x=0; x < MAX_ATMS; x++)
	{
	    if(IsPlayerInRangeOfPoint(playerid, 2.5, A[x][APos][0], A[x][APos][1], A[x][APos][2]))
	    {
	        ShowATMScreen(playerid);
		}
	}
	return 1;
}

CMD:stopbanking(playerid, params[])
{
	HideATMScreen(playerid);
	return 1;
}

CMD:createhouse(playerid, params[])
{
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	new htype,
	ht[80],
	value;
	if(!sscanf(params, "s[80]d", ht, value))
	{
	    if(isnull(ht)) return SendClientMessage(playerid, INDIANRED, "/createhouse [type] [value] ");
	    if(strcmp(ht, "small", true) == 0) htype = HOUSE_SMALL;
	    else if(strcmp(ht, "medium", true) == 0) htype = HOUSE_MEDIUM;
	    else if(strcmp(ht, "big", true) == 0) htype = HOUSE_BIG;
	    else if(strcmp(ht, "huge", true) == 0) htype = HOUSE_HUGE;
	    else if(strcmp(ht, "hotel", true) ==0) htype = HOUSE_HOTEL;
	    CreateHouse("For sale", "Unowned", Pos[0], Pos[1], Pos[2], htype, value);
	}
	return 1;
}

CMD:carfunc(playerid, params[])
{
	ShowCarFunctions(playerid);
	return 1;
}

CMD:stopcarfunc(playerid, params[])
{
	HideCarFunctions(playerid);
	return 1;
}

CMD:spawnmecar(playerid, params[])
{
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	CreateVehicleEx(522, Pos[0], Pos[1], Pos[2]+5, 0, 1, 1, pname(playerid), 15000);
	return 1;
}
