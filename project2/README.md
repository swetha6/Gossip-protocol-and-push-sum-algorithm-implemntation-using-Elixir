Team Members:
Sai Swetha Kondubhatla UFID: 1175 - 9282
Nikhil Reddy Kortha UFID: 7193 - 8560

What is working?
Algorithms: PushSum, Gossip
Topologies: Full, Line, Sphere/Torus, Imperfect line, 3D, random 2D

Largest Network for each topology:

					      Gossip	PushSum
Full				    6,000	  2,000
Line				    2,000	  500
Imperfect Line	5,000	  7,000
Random 2D			  3,500	  2,000
3D					    10,000	7,000
Sphere/Torus		10,000	5,000

How to run the code?
The topologies can be written as follows: full, line, rand2D, 3D, impline, torus
Algorithm: gossip, pushsum


mix run lib/my_project.ex numNodes topology algorithm

Bonus part:
mix run lib/my_project.ex numNodes topology algorithm fail_nodes