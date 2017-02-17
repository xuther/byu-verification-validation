1. Generate state in veification model
1. Pull letter from state - label and check prop. 
1. Normal ddfs stuff
1. Repeat

## Normal ddfs sutff
1. go instersecting and finding set - 
dfs search
1. if we find accept state - start dfs from the accept state. 
	* as soon as we find a state that is in the original dfs stack, we report the error. 


[Empty Set] 
     |    ^
	 v    |
    [R]   |
	 |    |
	 v    |
  [R ^ A] |
     |    |
	 v    |
    [A]----
      
	 + - +
     v   | {*}
    [q0]-+
	 |
	 | {R}
	 v
  +>[q1*]
  |  |
  +--+
   {!A}



