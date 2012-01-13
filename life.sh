#!/bin/bash

function get_item {

	local MATRIX="$1"
	local X="$2"
	local Y="$3"

	echo -e "$MATRIX" | awk '{if (NR==Y) print substr($0, X, 1);}' Y="$Y" X="$X"

}

function live_neighbours {

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

function calculate_row {

	local MATRIX="$1"
	local Y="$2"
	local LIVE_NEIGHBOURS
	local NEW_ROW=""
	local ITEM
	local COL

        for (( COL=1; COL<=$COLS; COL++ ))
        do
                LIVE_NEIGHBOURS=$(live_neighbours "$MATRIX" "$COL" "$Y")
                ITEM="$(get_item "$MATRIX" $COL $Y)"

                #echo "$ROW,$COL: '$ITEM' '$LIVE_NEIGBOURS'"

                if [ "$ITEM" = "*" ]; then

                        if [ "$LIVE_NEIGHBOURS" = "3" -o "$LIVE_NEIGHBOURS" = "4" ]; then
                                NEW_ROW="${NEW_ROW}*"
                        else
                                NEW_ROW="${NEW_ROW}."
                        fi
                else

                        if [ "$LIVE_NEIGHBOURS" = "3" ]; then
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

THE_WORLD="\
..................
....*.............
.....*............
...***............
..................
..................
..................
........***.......
..................
..................
..................
.................."

# Read the initial world from stdin
THE_WORLD="$(cat -)"

rm life.tmp 2>/dev/null

clear
echo -e "$THE_WORLD"

ROWS=$(echo $(echo -e "$THE_WORLD" | wc -l))
COLS=$(echo $[ $(echo -e "$THE_WORLD" | head -1 | wc -c) - 1 ])

while true
do

	for (( ROW=1; ROW<=$ROWS; ROW++ ))
	do
	
		echo "$(calculate_row "$THE_WORLD" $ROW)" >> life.tmp &

	done

	wait

	THE_WORLD="$(cat life.tmp | sort -n | awk '{print $2}')"
	rm life.tmp
	clear
	echo -e "$THE_WORLD"

done
