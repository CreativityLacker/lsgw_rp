//Global Textdraws:

new Text:Textdraw0;


Textdraw0 = TextDrawCreate(641.531494, 364.916687, "usebox");
TextDrawLetterSize(Textdraw0, 0.000000, 9.016667);
TextDrawTextSize(Textdraw0, 384.529998, 0.000000);
TextDrawAlignment(Textdraw0, 1);
TextDrawColor(Textdraw0, 0);
TextDrawUseBox(Textdraw0, true);
TextDrawBoxColor(Textdraw0, 102);
TextDrawSetShadow(Textdraw0, 0);
TextDrawSetOutline(Textdraw0, 0);
TextDrawFont(Textdraw0, 0);


//Player Textdraws:

new PlayerText:Textdraw0[MAX_PLAYERS];


Textdraw0[playerid] = CreatePlayerTextDraw(playerid, 377.628143, 365.750061, "1.~n~2.~n~3.~n~4.~n~5.~n~6.~n~7.~n~8.");
PlayerTextDrawLetterSize(playerid, Textdraw0[playerid], 0.250878, 1.133333);
PlayerTextDrawAlignment(playerid, Textdraw0[playerid], 1);
PlayerTextDrawColor(playerid, Textdraw0[playerid], -1);
PlayerTextDrawSetShadow(playerid, Textdraw0[playerid], 0);
PlayerTextDrawSetOutline(playerid, Textdraw0[playerid], 1);
PlayerTextDrawBackgroundColor(playerid, Textdraw0[playerid], 51);
PlayerTextDrawFont(playerid, Textdraw0[playerid], 1);
PlayerTextDrawSetProportional(playerid, Textdraw0[playerid], 1);

