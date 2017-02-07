mtype = { task }
chan prodToSched = [5] of {mtype, byte}
chan schedToCons[2] = [2] of {mtype, byte}
 
proctype Producer(byte me) {
 prodToSched!task(me)
 prodToSched!task(me)
}
 
proctype Consumer(byte me) { 
  byte you
endconsumer:
  do
  :: schedToCons[me]?task(you)
  od
}
 
init { 
  byte i
  atomic { 
    for (i : 0 .. 4) {
      run Producer(i)
    }
    run Consumer(0)
    run Consumer(1)
  } 
}
 
active proctype Scheduler () {  
byte j  
endscheduler: 
do
	:: prodToSched?task(j) ->
	atomic { 
		if 
			:: nfull(schedToCons[0]) || nfull(schedToCons[1]) -> 
			if
			:: len(schedToCons[0]) < len(schedToCons[1]) -> 
				assert(len(schedToCons[0]) <= len(schedToCons[1]));
				schedToCons[0]!task(j);
				
			:: else ->
				assert(len(schedToCons[1]) <= len(schedToCons[0]));
				schedToCons[1]!task(j);
				
			fi;
		fi;		
	}  
od

}
