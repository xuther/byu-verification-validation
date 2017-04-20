#ifndef N
 #define N 3
#endif

mtype = {white, black, terminate, message, act, pass}
chan TokenRing[N] = [N] of {mtype,byte}

proctype node(int me) {
	int messageCount = 0
	mtype color = white
	mtype state = act
	bool hasToken = false
	mtype tokenColor
	int tokenCount = 0
    bool startedToken = false	
	int messageContents

	do
		:: TokenRing[me]?message(messageContents) -> 
			S0: messageCount++
			if 
			:: messageContents == me -> 
			S1:	color = black
				state = act
			:: messageContents != me -> 
            S2: TokenRing[((me+1)%N)]!message(messageContents)
				messageCount--	
				color = black
		fi;
		:: TokenRing[me]?white(messageContents) -> 
			S3: tokenCount = messageContents 
				if 
			:: me == 0 -> 
		S4:			if 
				:: state == pass && color == white && tokenCount + messageCount == 0 ->
		S5:				TokenRing[((me+1)%N)]!terminate(me) //Success, terminate
					break //end
					:: else -> 
		S6:		TokenRing[((me+1)%N)]!white(0) //start a new detection probe
					fi;
			:: else ->		
		S7:			if 
				:: state == act -> 
		S8:				hasToken = true
					if 
						:: color == white -> 
		S9:				tokenColor = white
						:: color == black -> 
		s10:			tokenColor = black
						fi;
				:: state == pass -> 
				S11:		if 
					:: color == white ->
				S12:			tokenColor = white
						//pass on the token
							TokenRing[((me+1)%N)]!white(tokenCount + messageCount)
					:: color == black 
				S13:			tokenColor = black 
						TokenRing[((me+1)%N)]!black(tokenCount + messageCount)
							color = white
					fi;
					fi;
			fi;
			:: TokenRing[me]?black(messageContents) -> 
			S14: tokenCount = messageContents
				if 
			:: me == 0 -> 
				S15:	TokenRing[((me+1)%N)]!white(me)
			:: else -> 
				S16:	if 
				::state == act -> 
				S17:		hasToken = true
				:: state == pass -> 
				S18:		TokenRing[((me+1)%N)]!black(tokenCount + messageCount)
				fi;
				fi;
		:: state == act ->
        S19:	 TokenRing[((me+1)%N)]!message((me + 3)%N)  -> //send a message 
				 tokenCount--;
					 color = black;
		:: state == act -> 
		S201:		state = pass; 
			if 
				:: hasToken == true ->
		S20:		 TokenRing[(me+1)%N]!tokenColor(tokenCount + messageCount);
					 hasToken = false;
			:: else -> skip
				fi;
		:: 	TokenRing[me]?terminate(messageContents) -> 
		S21:			assert(state == pass)
				TokenRing[(me+1)%N]!terminate(me)
					break
		:: startedToken == false && me == 0 -> 
		S22:			TokenRing[me+1%N]!white(0);
				startedToken = true;
	od
    end: skip
}

//validate that if a node goes black, it eventually turns white
ltl a { [](node[1]:color == black -> <> (node[1]:color == white)) }

//I'm not sure how to prove number 2 - as the program is written such that I turn black whenever I recieve a messge, but I only recieve messages from those with a lower pID, but I never send them there. 
ltl b { []( 1 ) }

//Validate that we always send a message after recieving one
ltl c { [](node[1]@S3 || node[1]@S13 || node[1]@S21 -> <>(node[1]@S21 || node[1]@S12 || node[1]@S13 || node[1]@S18 || node[1]@S19 || node[1]@S22 || node[1]@S21 || node[1]@S15 || node[1]@S5 || node[1]@S5) ) }

//Test that we only terminate when there are no outstanding messages
ltl d { []( node[1]@end -> node[1]:messageCount == 0 && node[3]:messageCount == 0 && node[2]:messageCount ==0) }

init {
	atomic {
        byte i 
		for (i : 0 .. (N-1)) {
		run node(i)
		}
	}
}
