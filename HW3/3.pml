#ifndef N
 #define N 4 
#endif

int flag[N]
int counter = 0

proctype process(int self) {
	int i 
S1:	do
	:: true -> skip //non Critical Section
	:: flag[self] = 1 -> 
S0:		atomic {
			for (i : 0 .. N-1) {
				if 
				:: flag[i] >= 3 -> goto S0
				:: else -> skip
				fi;
			}
		goto S2
		}	
	od
S2: flag[self] = 3
S3:	atomic {
		for (i : 0 .. N-1) {
			if
			:: flag[i] == 1 -> goto S4
			:: else -> skip
			fi;
		}
		goto S6
	}
S4: flag[self] = 2
S5:	atomic {
		for (i : 0 .. N-1) {
			if 
			:: flag[i] == 4 -> goto S6 
			:: else -> skip 
			fi;
			goto S5
			}
	}
S6: flag[self] = 4
S7: atomic {
		for (i : 0 .. self-1) {
			if 
			:: flag[i] >= 2 -> goto S7
			:: else -> skip
			fi;
		}
	}
S8: counter ++ 
assert(counter == 1) 
S9: counter -- 
S10: atomic {
		for (i : self + 1 .. N-1) {
			if 
			:: flag[i] == 2 || flag[i] == 3 -> goto S10
			:: else -> skip
			fi;
		}
	}
S11: flag[self] = 0 
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
