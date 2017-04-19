#ifndef N
 #define N 4 
#endif

int flag[N]
int state[N]
int counter = 0

proctype process(int self) {
	int i 
S1:	do
	:: true -> skip //non Critical Section
	:: flag[self] = 1 -> 
S0:		atomic {
			state[self] = 1
			for (i : 0 .. N-1) {
				if 
				:: flag[i] >= 3 -> goto S0
				:: else -> skip
				fi;
			}

		goto S2
		}	
	od
S2: atomic {flag[self] = 3; state[self] = 2} 
S3:	atomic {
		state[self] = 3
		for (i : 0 .. N-1) {
			if
			:: flag[i] == 1 -> goto S4
			:: else -> skip
			fi;
		}
		goto S6
	}
S4: atomic { flag[self] = 2; state[self] = 4 }
S5:	atomic {
		state[self] = 5
		for (i : 0 .. N-1) {
			if 
			:: flag[i] == 4 -> goto S6 
			:: else -> skip 
			fi;
			goto S5
			}
	}
S6: atomic { flag[self] = 4; state[self] = 6}
S7: atomic {
		state[self] = 7
		for (i : 0 .. self-1) {
			if 
			:: flag[i] >= 2 -> goto S7
			:: else -> skip
			fi;
		}
	}
S8: atomic{ counter ++; state[self] = 8}
S9: counter -- 
S10: atomic {
		state[self] = 9	
		for (i : self + 1 .. N-1) {
			if 
			:: flag[i] == 2 || flag[i] == 3 -> goto S10
			:: else -> skip
			fi;
		}
	}
S11: atomic { flag[self] = 0; state[self] = 10; } 
	 goto S1
}


//test for mutual exclusion
never {
    S0: do 
        :: counter > 1 -> break 
        od;
}

// test for inner sanctum locking the door
// Due to mirrored processes, only have to test one process
never {
    S0: if
        ::  pc_value(0) == 26 ->
            if
            :: (state[1] < 9 && state[1] > 6) && (state[2] < 9 && state[2] > 6) && (state[3] < 9 && state[3] > 6) -> goto end
            :: else -> goto S0
            fi;
        :: else -> goto S0 //we're not at the doorway, carry on
        fi;
    end: skip
}

// test for property II, if  process is at 10,11,or 12 it's process is the least of all in waitinf room or inner sanctum
never {
    S0: if
        :: state[2] == 8 -> //assert that we have the lowest pid of all the processes in the waiting room/inner sanctum
            if
            :: (flag[1] >= 5 && flag[0] >= 5) -> goto end
            :: else -> goto S0
            fi;
        :: else -> goto S0
        fi;
    end: skip
}

// Test for property III
never {
    S0: if
        :: pc_value(0) == 105 ->
            atomic {if 
                :: (state[1] > 4 && state[1] < 10 && flag[1] != 4) || (state[2] > 4 && state[2] < 10 && flag[2] != 4) || (state[3] > 4 && state[3] < 10 && flag[3] != 4) -> goto end
                :: else -> skip
            fi }
        :: else -> goto S0
        fi;
    end: skip
}

//test for "If a process requests access to the inner sanctum, it eventually reaches it"
//So we're testing for negation "If a process requests access to the inner sanctum, it never reaches it"
never {
    S0: do
        :: true //We can 
        :: flag[0] == 1 -> break //We request access to the inner sanctum
        od

    accept: do
            :: flag[0] !=  4 //we never make it into the inner sacntum
            :: else -> goto S0
            od
    }

init {
    counter = 0
	int j 
	atomic {
		for (j : 0 .. N-1) {
			run process(j) 
		}
	}
}
