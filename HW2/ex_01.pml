#ifndef N
#define N 2
#endif

init {
	chan dummy = [N] of { byte } // a message channel of N slots
end:	do	
	:: dummy!85    // send value  85 to the channel
	:: dummy!170   // send value 170 to the channel
	od
}
