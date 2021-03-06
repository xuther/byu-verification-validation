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

//mutex
ltl a { [] counter <= 1}
//inner sanctum locks door
ltl b { []( pc_value(0) == 26 -> (state[1] < 9 && state[1] > 6) && (state[2] < 9 && state[2] > 6) && (state[3] < 9 && state[3] > 6) ) }
// Least pid of all in waitin room 
ltl c { []( state[2] == 8 -> flag[1] < 5 && flag[0] < 5) }
// All proccesses in inner sanctum must have flat 4
ltl d { []( pc_value(0) == 105 -> ((state[1] < 4 && state[1] > 10) || flag[1] == 4) && ((state[2] < 4 && state[2] > 10) || flag[2] == 4) && ((state[3] < 4 && state[3] > 10) || flag[3] == 4) ) }
//processes that request access to the inner sanctum eventually get there
ltl e { []( flag[0] == 1 -> <> flag[0] == 4 ) }

init {
    counter = 0
	int j 
	atomic {
		for (j : 0 .. N-1) {
			run process(j) 
		}
	}
}

