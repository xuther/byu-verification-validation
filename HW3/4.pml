#ifndef N 
 #define N 4
#endif

chan comms[N] = [10] of {int} //this is unbounded, but we choose an arbitrarily large channel. 

chan elected = [1] of {int}

proctype process(int ident) {
	int d, e, f, c = 0

	d = ident

	do
		:: comms[(ident + 1) % N]!d -> 
			comms[ident]?e
			if 
			:: e == ident -> 
				elected!ident
				goto end 
			:: else -> 
				skip
			fi;	
			if 
				:: elected?<c> -> goto end
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
				:: elected?<c> -> goto end
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
		:: timeout -> skip
	od;


relay: 
if 
	:: elected?<c> -> goto end
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
		 :: elected?<c> -> goto end
		 :: else -> skip
	 fi; 

	 comms[(ident + 1) % N]!d	
		 :: elected?<c> -> goto end
od;

end: skip
}

init {
atomic {
	int i 
	for(i:0 .. N-1) {
			run process(i)	
		}
	}
	}
