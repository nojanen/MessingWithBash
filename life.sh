#!/bin/bash
# The Game of Life

function get_cell {

	local MATRIX="$1"
	local X="$2"
	local Y="$3"

	echo -e "$MATRIX" | awk '{if (NR==Y) print substr($0, X, 1);}' Y="$Y" X="$X"
}

function alive_cells {

	local MATRIX="$1"
	local X="$2"
	local Y="$3"
	local NEIGHBOURS

	AWK_GET_NEIGHBOURS='
		{
		if (NR>=Y-1 && NR<=Y+1) 
			if (X==1) 
				print substr($0, X-1, 2); 
			else 
				print substr($0, X-1, 3); 
		}'

	NEIGHBOURS="$(echo -e "$MATRIX" | awk "$AWK_GET_NEIGHBOURS" X="$X" Y="$Y")"
	
	echo $(echo "$NEIGHBOURS" | grep -o "\*" | wc -l)
}

function new_row {

	local MATRIX="$1"
	local Y="$2"
	local X
	local ALIVE_CELLS
	local NEW_ROW=""
	local CELL

        for (( X=1; X<=$COLS; X++ ))
        do
                ALIVE_CELLS=$(alive_cells "$MATRIX" "$X" "$Y")
                CELL="$(get_cell "$MATRIX" "$X" "$Y")"

                if [ "$CELL" = "*" ]; then

                        if [ "$ALIVE_CELLS" = "3" -o "$ALIVE_CELLS" = "4" ]; then
                                NEW_ROW="${NEW_ROW}*"
                        else
                                NEW_ROW="${NEW_ROW}."
                        fi
                else

                        if [ "$ALIVE_CELLS" = "3" ]; then
                                NEW_ROW="${NEW_ROW}*"
                        else
                                NEW_ROW="${NEW_ROW}."
                        fi

                fi
        done

	echo "$Y $NEW_ROW"
}

###    ###   ######   ###  ###    ###
####  ####  ###  ###  ###  #####  ###
### ## ###  ########  ###  ###  #####
###    ###  ###  ###  ###  ###    ###

# Read the initial world from stdin
THE_WORLD="$(cat -)"
NEW_WORLD=""
COLS=$(echo $[ $(echo -e "$THE_WORLD" | head -1 | wc -c) - 1 ])
ROWS=$(echo $(echo -e "$THE_WORLD" | wc -l))

while [ ! "$THE_WORLD" == "$NEW_WORLD" ]
do

	[ ! "$NEW_WORLD" == "" ] && THE_WORLD="$NEW_WORLD"

	clear
	echo -e "$THE_WORLD"
	rm life.tmp 2>/dev/null

	for (( ROW=1; ROW<=$ROWS; ROW++ ))
	do
	
		echo "$(new_row "$THE_WORLD" "$ROW")" >> life.tmp &

	done

	wait

	NEW_WORLD="$(cat life.tmp | sort -n | awk '{print $2}')"

done

