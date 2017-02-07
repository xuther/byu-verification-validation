mtype = { a0, a1, b0, b1, err } // file ex_2.pml

chan a2b = [0] of { mtype }// a rendezvous channel for messages from A to B
chan b2a = [0] of { mtype }// a second channel for the reverse direction

active proctype A()
{
S1: if 
    :: a2b!a1
    :: a2b!err
    fi;
S2: if
	:: b2a?b1  -> goto S1
	:: b2a?b0  -> goto S3
	:: b2a?err -> goto S5
	fi;
S3: if
	:: a2b!a1  -> goto S2
	:: a2b!err -> goto S2
	fi;
S4: if
	:: b2a?err -> goto S5
	:: b2a?b1 -> goto S1
	:: b2a?b0 -> goto S1
	fi;
S5: if
	:: a2b!a0  -> goto S4
	:: a2b!err -> goto S4
	fi;
}

active proctype B()
{
goto S2
S1: if
	::b2a!b1
	::b2a!err
	fi;
S2: if
    :: a2b?a0  -> goto S3
    :: a2b?a1  -> goto S1
    :: a2b?err -> goto S5
    fi;
S3: if
	:: b2a!b1 -> goto S2
	:: b2a!err -> goto S2
	fi;
S4: if
    :: a2b?a1  -> goto S1
    :: a2b?a0  -> goto S1
    :: a2b?err -> goto S5
    fi;
S5: if 
	:: b2a!b0 -> goto S4
	:: b2a!err -> goto S4
	fi;
}
