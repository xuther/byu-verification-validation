#ifndef N
 #define N 4
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
			messageCount++
			if 
			:: messageContents == me -> 
				color = black
				state = act
			:: messageContents != me -> 
				TokenRing[((me+1)%N)]!message(messageContents)
				messageCount--	
				color = black
		fi;
		:: TokenRing[me]?white(messageContents) -> 
			tokenCount = messageContents 
				if 
			:: me == 0 -> 
					if 
				:: state == pass && color == white && tokenCount + messageCount == 0 ->
						TokenRing[((me+1)%N)]!terminate(me) //Success, terminate
					break //end
					:: else -> 
					TokenRing[((me+1)%N)]!white(0) //start a new detection probe
					fi;
			:: else ->		
					if 
				:: state == act -> 
						hasToken = true
					if 
						:: color == white -> 
						tokenColor = white
						:: color == black -> 
						tokenColor = black
						fi;
				:: state == pass -> 
						if 
					:: color == white ->
							tokenColor = white
						//pass on the token
							TokenRing[((me+1)%N)]!white(tokenCount + messageCount)
					:: color == black 
							tokenColor = black 
						TokenRing[((me+1)%N)]!black(tokenCount + messageCount)
							color = white
					fi;
					fi;
			fi;
			:: TokenRing[me]?black(messageContents) -> 
			tokenCount = messageContents
				if 
			:: me == 0 -> 
					TokenRing[((me+1)%N)]!white(me)
			:: else -> 
					if 
				::state == act -> 
						hasToken = true
				:: state == pass -> 
						TokenRing[((me+1)%N)]!black(tokenCount + messageCount)
				fi;
				fi;
		:: state == act ->
					 TokenRing[((me+1)%N)]!message((me + 3)%N)  -> //send a message 
				 tokenCount--;
					 color = black;
		:: state == act -> 
				state = pass; 
			if 
				:: hasToken == true ->
				 TokenRing[(me+1)%N]!tokenColor(tokenCount + messageCount);
					 hasToken = false;
			:: else -> skip
				fi;
		:: 	TokenRing[me]?terminate(messageContents) -> 
					assert(state == pass)
				TokenRing[(me+1)%N]!terminate(me)
					break
		:: startedToken == false && me == 0 -> 
					TokenRing[me+1%N]!white(0);
				startedToken = true;
	od
}

init {
	byte i 
	atomic {
		for (i : 0 .. (N-1)) {
		run node(i)
		}
	}
}
