#ifndef N
 #define N 4
#endif

chan CallElevator = [N] of {int}
chan ElevatorArrived = [N] of {int}
chan DoorOpened = [N] of {int}
chan DoorClosed = [N] of {int}

bool OpenDoors[N]
int elevatorPosition = 0
int topFloor = N - 1

proctype floor(int myNum) {
	bool doorOpen = false

	S1: do 
		:: CallElevator!myNum -> 
			goto S2 //call elevator
		:: goto S1 //loop
		:: goto S5 //end
		od
	S2: ElevatorArrived??myNum -> goto S3
	S3: atomic { DoorOpened!myNum; OpenDoors[myNum] = true; } -> goto S4
	S4: atomic { DoorClosed!myNum; OpenDoors[myNum] = false; } -> goto S1

	S5: skip
}	

proctype elevator() {
	int callingFloor
	
	S1: //I'm at the ground floor, check for calls
		end:
		if 
		:: CallElevator??topFloor -> goto S5 //goto the top floor
		:: CallElevator?callingFloor -> goto S3 //service a call
		fi		
	S2: elevatorPosition = 0 -> goto S1
	S3: elevatorPosition = callingFloor -> goto S8
	S4: if
		:: CallElevator??[topFloor] -> CallElevator??topFloor; goto S5;
		:: else -> goto S2 
		fi;
	S5: elevatorPosition = topFloor -> goto S8 //Go to top floor
	S6: DoorOpened??elevatorPosition -> goto S7 //Wiat for door to open
	S7: DoorClosed??elevatorPosition -> goto S4 //Wait for door to close
	S8: ElevatorArrived!elevatorPosition -> goto S6 //signal our arrival
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
