defmodule Proj2 do
  use GenServer
  def main(numNodes,topo,algo) do
    numNodes = if (topo == "torus") do
      sqrt = round(:math.sqrt(numNodes))
      numNodes = sqrt * sqrt
    else
      numNodes
    end
    numNodes = if(topo == "3D") do
      cuberoot = round(:math.pow(numNodes,0.34))
      numNodes = cuberoot * cuberoot * cuberoot
    else
      numNodes
    end

    nodes = createnodes(numNodes)
    table = createtable()
    cond do
      topo == "full" ->
        Topo.buildfullTopo(nodes)
      topo == "line" ->
        Topo.buildlineTopo(nodes)
      topo == "impline" ->
        Topo.buildImlineTopo(nodes)
      topo == "rand2D" ->
        Topo.buildRand2D(nodes)
      topo == "torus" ->
        Topo.toroid(nodes)
      topo == "3D" ->
        Topo.build3D(nodes)
    end
    start_time = System.monotonic_time(:millisecond)
    cond do
      algo == "gossip" ->
        Algo.startGossip(nodes,start_time)
      algo == "pushsum" ->
        Algo.startPushSum(nodes,start_time)
        infinite_loop()
    end
  end
  def handle_cast({:pushsum,new_s,new_w,start_time, length},state) do
    {s,consecutive_count,adjList,w} = state
    this_s = s + new_s
    this_w = w + new_w
    diff = Algo.cal_diff(this_s,this_w,s,w)
    if(diff < :math.pow(10,-10) && consecutive_count==2) do
      count = :ets.update_counter(:table, "count", {2,1})
      if count == length do
        new_time = System.monotonic_time(:millisecond)
        end_time = new_time - start_time
        IO.puts "Convergence time = #{end_time} ms"
        System.halt(1)
      end
    end
    consecutive_count =
    if(diff < :math.pow(10,-10) && consecutive_count<2) do
      consecutive_count + 1
    else
      0
    end
    state = {this_s/2,consecutive_count,adjList,this_w/2}
    new_node = Enum.random(adjList)
    Algo.sendPushSum(new_node, this_s/2, this_w/2,start_time, length)
    {:noreply,state}
  end

    # def sendPushSum(new_node, this_s, this_w,start_time, length) do
    #   GenServer.cast(new_node, {:pushsum,this_s,this_w,start_time, length})
    # end
  def infinite_loop() do
    infinite_loop()
  end
  def createnodes(numNodes) do
     Enum.map((1..numNodes),fn(x) ->
      pid = start_node()
      updatestateof_pid(pid,x)
      pid
    end)
  end
  def createtable do
    table = :ets.new(:table, [:named_table, :public])
    :ets.insert(table, {"count" , 0})
  end

  def add_to_adjList(pid, list) do
    GenServer.call(pid, {:add_to_adjList, list})
  end

  def handle_call({:add_to_adjList, list} , _from, state) do
    {a,b,c,d} = state
    state = {a,b,list,d}
    {:reply,a,state}
  end

  def start_node() do
    {:ok,pid} = GenServer.start_link(__MODULE__, :ok, [])
    pid
  end
  def init(:ok) do
    {:ok, {0,0,[],1}}
    #{nodeID, count, adjacentList}
  end
  def updatestateof_pid(pid, nodeID) do
    GenServer.call(pid, {:updatestateof_pid, nodeID})
  end
  def handle_call({:updatestateof_pid,nodeID},__from, state) do
    {a,b,c,d} = state
    state = {nodeID,b,c,d}
    {:reply, a, state}
  end

  def getAdjacentList(pid) do
    GenServer.call(pid,{:getAdjacent})
  end

  def handle_call({:getAdjacent}, _from, state) do
    {a,b,c,d} = state
    {:reply, c, state}
  end

  def getcount(pid) do
    GenServer.call(pid,{:getcount})
  end
  def handle_call({:getcount}, _from, state) do
    {a,b,c,d} = state
    {:reply, b, state}
  end

  def updatecount(pid,start_time,length) do
    GenServer.call(pid, {:updatecount, start_time,length})
  end
  def handle_call({:updatecount,start_time,length}, _from, state) do
    {a,b,c,d} = state
    if(b == 0) do
      count = :ets.update_counter(:table, "count", {2,1})
      if(count == length) do
      end_time = System.monotonic_time(:millisecond) - start_time
      IO.puts "Convergence time = #{end_time} ms"
      System.halt(1)
      end
    end
    state = {a,b+1,c,d}
    {:reply,b+1,state}
  end
end
