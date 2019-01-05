defmodule Pushsum do
  use GenServer
  def main(numNodes,topo,algo) do
    allNodes = Enum.map((1..numNodes), fn(x) ->
      pid=start_node()
      updatePIDState(pid, x)
      pid
    end)

    table = :ets.new(:table, [:named_table,:public])
    :ets.insert(table, {"count",0})
    buildFull(allNodes)
    startTime = System.monotonic_time(:millisecond)
    startPushSum(allNodes, startTime)
  end

  def start_node() do
    {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
    pid
  end
  def init(:ok) do
    {:ok, {0,0,[],1}} #{s,pscount,adjList,w} , {nodeId,count,adjList,w}
  end

  def updatePIDState(pid,nodeID) do
    GenServer.call(pid, {:UpdatePIDState,nodeID})
  end

  def handle_call({:UpdatePIDState,nodeID}, _from ,state) do
    {a,b,c,d} = state
    state={nodeID,b,c,d}
    {:reply,a, state}
  end

  def buildFull(allNodes) do
    Enum.each(allNodes, fn(k) ->
      adjList=List.delete(allNodes,k)
      updateAdjacentListState(k,adjList)
    end)
  end

  def updateAdjacentListState(pid,map) do
    GenServer.call(pid, {:UpdateAdjacentState,map})
  end

  def handle_call({:UpdateAdjacentState,map}, _from, state) do
    {a,b,c,d}=state
    state={a,b,map,d}
    {:reply,a, state}
  end

  def startPushSum(allNodes, startTime) do
    chosenFirstNode = Enum.random(allNodes)
    GenServer.cast(chosenFirstNode, {:ReceivePushSum,0,0,startTime, length(allNodes)})
  end

  def handle_cast({:ReceivePushSum,incomingS,incomingW,startTime, total_nodes},state) do

    {s,pscount,adjList,w} = state
    myS = s + incomingS
    myW = w + incomingW
    difference = abs((myS/myW) - (s/w))
    if(difference < :math.pow(10,-10) && pscount==2) do
      count = :ets.update_counter(:table, "count", {2,1})
      if count == total_nodes do
        endTime = System.monotonic_time(:millisecond) - startTime
        IO.puts "Convergence achieved in = " <> Integer.to_string(endTime) <>" Milliseconds"
        System.halt(1)
      end
    end
    pscount =
    if(difference < :math.pow(10,-10) && pscount<2) do
      pscount + 1
    end

    if(difference > :math.pow(10,-10)) do
      0
    end
    state = {myS/2,pscount,adjList,myW/2}
    randomNode = Enum.random(adjList)
    sendPushSum(randomNode, myS/2, myW/2,startTime, total_nodes)
    {:noreply,state}
  end

  def sendPushSum(randomNode, myS, myW,startTime, total_nodes) do
    GenServer.cast(randomNode, {:ReceivePushSum,myS,myW,startTime, total_nodes})
  end

end
