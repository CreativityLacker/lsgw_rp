#include <a_samp>

#define HORIZONTAL      0
#define VERTICAL        1
#define MAX_STEPS       99
#define INTERVAL        1000// 1 second

#define MAX_TEXTDRAWS 256

new VISIBLE[MAX_PLAYERS][MAX_TEXTDRAWS],
	Float:TPOS[MAX_TEXTDRAWS][2][2],
	Text:T[MAX_TEXTDRAWS],
	TCOL[MAX_TEXTDRAWS],
	MOVE_TYPE[MAX_TEXTDRAWS],
	bool:REPEAT[MAX_TEXTDRAWS],
	ORGSTRING[MAX_TEXTDRAWS][200],
	AFTERSTRING[MAX_TEXTDRAWS][200],
	STEPS_TAKEN[MAX_TEXTDRAWS],
	STEPS[MAX_TEXTDRAWS],
	Float:SPEED[MAX_TEXTDRAWS];

stock CreateMovingTextdraw(Text:textdrawid, color, Float:orgX, Float:orgY, org_string[], movement_type = HORIZONTAL, Float:speed = 1.0, steps_to_move = MAX_STEPS, aft_string[], bool:repeat = false)
{
	new TD = textdrawid;
	T[TD] = TextDrawCreate(org_string, orgX, orgY);
	TPOS[TD][0][0] = orgX;
	TPOS[TD][0][1] = orgY;
	TPOS[TD][1][0] = orgX;
	TPOS[TD][1][1] = orgY;
	TextDrawColor(T[TD], color);
	TCOL[TD] = color;
	STEPS[TD] = steps_to_move;
	SPEED[TD] = speed;
	STEPS_TAKEN[TD] = 0;
	MOVE_TYPE[TD] = movement_type;
	format(AFTERSTRING[TD][sizeof(AFTERSTRING)], 200, "%s", aft_string);
	format(ORGSTRING[TD][sizeof(ORGSTRING)], 200, "%s", org_string);
	REPEAT[TD] = repeat;
	SetTimerEx("MoveTextdraw", INTERVAL, true, "d", TD);
	return 1;
}

forward MoveTextdraw(tdid);
public MoveTextdraw(tdid)
{
	new mov = MOVE_TYPE[tdid];
	new Float:tpo[2];
	tpo[0] = TPOS[tdid][1][0];
	tpo[1] = TPOS[tdid][1][1];
	switch(mov)
	{
	    case HORIZONTAL:
	    {
			if(STEPS_TAKEN[tdid] == STEPS[tdid])
			{
			    if(REPEAT[tdid] == true)
			    {
					TextDrawDestroy(T[tdid]);
					T[tdid] = TextDrawCreate(ORGSTRING[sizeof(ORGSTRING)][tdid], TPOS[tdid][0][0], TPOS[tdid][0][1]);
					STEPS_TAKEN[tdid] = 0;
					TextDrawColor(T[tdid], TCOL[tdid]);
				}
			}
			else
			{
				TextDrawDestroy(T[tdid]);
				T[tdid] = TextDrawCreate(ORGSTRING[tdid], tpo[0], tpo[1]+SPEED[tdid]);
				STEPS_TAKEN[tdid]++;
				TextDrawColor(T[tdid], TCOL[tdid]);
			}
		}
	}
	return 1;
}
