#ifndef N 
 #define N 4
#endif

chan comms[N] = [10] of {int} //this is unbounded, but we choose an arbitrarily large channel. 

chan elected = [1] of {int}
int count = 0
int finalElected = -1

//This validates claim 1 and 2. If all the processes end in a valid state we know that There was exactly one leader elected. 
proctype process(int ident) {
	int d, e, f, c = 0

	d = ident

S1:	do
	:: comms[(ident + 1) % N]!d -> 
		do 
		:: comms[ident]?e -> 	
			if 
			:: e == ident -> 
				elected!ident
				goto end 
			:: else -> 
				skip
			fi;	
			if 
				:: len(elected) > 0 -> goto end
				:: else -> skip
			fi;

			if 
			:: d > e -> comms[(ident +1) %N]!d
			:: else -> comms[(ident + 1) % N] ! e
			fi;

			comms[ident]?f

			if 
				:: f == ident -> 
					elected!ident
					goto end
				:: else -> skip
			fi;

			if 
				:: len(elected) > 0 -> goto end
				:: else -> skip
			fi;


			int max = 0
			if 
			:: f > d -> max = f
			:: else -> max = d
			fi; 
			if 
			:: e >= max -> d = e
			:: else -> goto relay
			fi;
		:: timeout -> 
			if 
				:: len(elected) > 0 -> goto end
				:: else -> goto S1
			fi;
		od;
	:: timeout -> 
		if 
			:: len(elected) > 0 -> goto end
			:: else -> goto S1
		fi;
	od;

relay: 
if 
	:: len(elected) > 0 -> goto end
	:: else -> skip
fi
do
	:: comms[ident]?d -> 

	 if 
		 :: d == ident -> 
			 elected!ident
			 goto end
		 :: else -> skip
	 fi;

	 if 
		 :: len(elected) > 0 -> goto end
		 :: else -> skip
	 fi; 

	 comms[(ident + 1) % N]!d	
		 :: elected?<c> -> goto end
od;

end: count++	
	if 
	:: count == N -> //wait until the last process leaves
		elected?c
        finalElected = c
		//assert (c == N-1) //assert that the leader was the highest numbered process
	:: else -> skip
	fi;	
}

init {
atomic {
	int i 
	for(i:0 .. N-1) {
			run process(i)	
		}
	}
}


//Assert only ever one elected. This feels odd as the model is built in such a way that there can only ever be one elected leader
ltl a { [](len(elected) < 2) }

//assert that a leader is always elected. Again, odd beacuse if the model gets to a valid end state, it means a leader was elected
ltl b { [](<> process[0]@end) }

//assert that the final elected leader is the leader with the highest pid
ltl c { [](<> (finalElected == N-1) ) }

