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
assert(counter == 1) 
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
S11: atomic { flag[self] = 0; state[self] = 10;
			for (i: 0 .. N -1) {
					if 
						:: i != self -> 
							if
							::state[i] > 4 && state[i] < 10 -> 
								assert( flag[i] == 4 ) 
							:: else -> skip
							fi;
						:: else -> skip
					fi;
				}			
			} 
	 goto S1
}


init {
	int j 
	atomic {
		for (j : 0 .. N-1) {
			run process(j) 
		}
	}
}
