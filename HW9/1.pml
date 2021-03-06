#ifndef N
 #define N 4
#endif

chan CallElevator = [N] of {int}
chan ElevatorArrived = [N] of {int}
chan DoorOpened = [N] of {int}
chan DoorClosed = [N] of {int}

bool OpenDoors[N]
int elevatorPosition = 0
int topFloor = 3 

proctype floor(int myNum) {
    bool calling = 0
	S1: do 
		:: CallElevator!myNum -> 
            calling = 1 
			goto S2 //call elevator
		:: goto S1 //loop
		:: goto S5 //end
		od
	S2: ElevatorArrived??myNum -> 
        calling = 0
        goto S3
	S3: atomic { DoorOpened!myNum; OpenDoors[myNum] = true; } -> goto S4
	S4: atomic { DoorClosed!myNum; OpenDoors[myNum] = false; } -> goto S1

	S5: skip
}	

proctype elevator() {
	int callingFloor
	
	S1: //I'm at the ground floor, check for calls
		if 
		:: CallElevator??[topFloor] -> CallElevator??topFloor; goto S5; //goto the top floor
		:: else -> 
			if 
			:: CallElevator?[callingFloor]-> CallElevator?callingFloor -> goto S3 //service a call
			:: else -> goto S1
			fi;		
		fi;
	S2: atomic {
        if
	    :: CallElevator??[topFloor] -> CallElevator??topFloor; goto S5;
        :: else -> elevatorPosition = 0 -> goto S1
        fi;
        }
	S3: elevatorPosition = callingFloor -> goto S8
	S4: if
	    :: CallElevator??[topFloor] -> CallElevator??topFloor; goto S5;
	    :: else -> goto S2 
	    fi;
	S5: elevatorPosition = topFloor -> goto S8 //Go to top floor
	S6: DoorOpened??elevatorPosition -> goto S7 //Wiat for door to open
	S7: DoorClosed??elevatorPosition -> goto S4 //Wait for door to close
	S8: //check to make sure that the top floor didn't call us while we were travelling. 
		atomic {
			if 
			:: CallElevator??[topFloor] -> CallElevator!elevatorPosition; CallElevator??topFloor; goto S5;
			:: else ->  ElevatorArrived!elevatorPosition -> goto S6; //signal our arrival
			fi
		}
}

init {
	byte i 
	atomic {
	for (i : 0 .. topFloor) {
 
		run floor(i)
	}

	run elevator();
	}
}

//Door doesn't open unless the elevator is present
ltl a { []( OpenDoors[1] -> elevatorPosition ==1 ) }

//Floor is served eventually - Requires fairness
ltl b { []( floor[1]:calling -> <> (!floor[1]:calling) ) }

//Ground floor visited repeately after being called
ltl c { []( elevator[0]:callingFloor -> <> (!elevatorPosition) ) }

//Top Floor priority
ltl d { []( floor[3]:calling -> (!elevator[0]@S2) U elevator[0]@S5) }
