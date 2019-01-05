[head,middle,err,tail] = System.argv()
numNodes = elem(Integer.parse(head),0)
topology = middle
algorithm = err
fail_nodes = elem(Integer.parse(tail),0)
Proj2.main(numNodes,topology,algorithm,fail_nodes)
