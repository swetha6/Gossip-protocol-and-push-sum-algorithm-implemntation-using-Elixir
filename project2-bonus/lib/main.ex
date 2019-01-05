defmodule Proj2 do
  use GenServer
  def main(numNodes,topo,algo,err) do
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
      true ->
        IO.puts "Invalid Arguments"
        System.halt(1)
    end
    startTime = System.monotonic_time(:millisecond)
    deleted_nodes = delete_rand(nodes,err,0,[])
    # new_nodes = Enum.filter(nodes,fn(x) -> Enum.member?(deleted_nodes,x) == false end)
    # IO.inspect deleted_nodes
    remove_neighbours(nodes,deleted_nodes)
    cond do
      algo == "gossip" ->
        startGossip(nodes,startTime,err)
      algo == "pushsum" ->
        startPushSum(nodes,startTime,err)
        infinite_loop()
    end
  end
  def delete_rand(nodes,err,err_done,deleted_nodes) do
    new_nodes = []
    d_nodes = []
    # IO.puts err_done
    if(err_done < err ) do
      # IO.puts "here"
      rand_node = Enum.random(nodes)
      new_nodes = if(Process.alive?(rand_node) == true) do
        # IO.puts "alive"
         new_nodes = List.delete(nodes,rand_node)
         d_nodes = deleted_nodes ++ [rand_node]
        #  IO.inspect d_nodes
        Process.exit(rand_node,:normal)
        delete_rand(new_nodes,err,err_done+1,d_nodes)
      else
        delete_rand(new_nodes,err,err_done,d_nodes)
      end
  else
    deleted_nodes
  end
  end

  # def kill_nodes(deleted_nodes) do
  #   Enum.each(deleted_nodes, fn(x) ->
  #     Process.exit(x,:kill)
  #   end)
  # end
  def remove_neighbours(new_nodes,deleted_nodes) do
    # kill_nodes(deleted_nodes)
    Enum.each(new_nodes, fn(x) ->
      delete_fromadjlist(x,deleted_nodes)
    end)
  end

  def delete_fromadjlist(pid,deleted_nodes) do
    # IO.puts "here"
    adjlist = getAdjacentList(pid)
    new_adjlist = Enum.filter(adjlist, fn(x) -> (Enum.member?(deleted_nodes,x) == false) end)
    # IO.inspect new_adjlist
    add_to_adjList(pid,new_adjlist)
  end


    def startPushSum(nodes, startTime,err) do
      start_node = Enum.random(nodes)
      GenServer.cast(start_node, {:pushsum,0,0,startTime, length(nodes),err})
    end
    def cal_diff(this_s, this_w, s,w) do
      diff = abs((this_s/this_w) - (s/w))
    end
    def handle_cast({:pushsum,new_s,new_w,startTime, length,err},state) do
      {s,consecutive_count,adjList,w} = state
      this_s = s + new_s
      this_w = w + new_w
      diff = cal_diff(this_s,this_w,s,w)
      if(diff < :math.pow(10,-10) && consecutive_count==2) do
        count = :ets.update_counter(:table, "count", {2,1})
        if count == length-err do
          new_time = System.monotonic_time(:millisecond)
          end_time = new_time - startTime
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
      sendPushSum(new_node, this_s/2, this_w/2,startTime, length,err)
      {:noreply,state}
    end

    def sendPushSum(new_node, this_s, this_w,startTime, length,err) do
      GenServer.cast(new_node, {:pushsum,this_s,this_w,startTime, length,err})
    end
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
  def startGossip(nodes,startTime,err) do
    start_node = Enum.random(nodes)
    updatecount(start_node,startTime,length(nodes),err)
    rumour(start_node,startTime,length(nodes),err)
  end

  def rumour(start_node,startTime,length,err) do
    count = getcount(start_node)
    cond do
      count <=10 ->
        adjacentList = getAdjacentList(start_node)
        new_node = Enum.random(adjacentList)

        Task.start(Proj2, :new_rumour, [new_node,startTime,length,err])
        rumour(start_node,startTime,length,err)
      true->
        Process.exit(start_node, :normal)
    end
       rumour(start_node,startTime,length,err)
  end
  def new_rumour(new_node,startTime,length,err) do
    updatecount(new_node,startTime,length,err)
    rumour(new_node, startTime, length,err)
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

  def updatecount(pid,startTime,length,err) do
    GenServer.call(pid, {:updatecount, startTime,length,err})
  end
  def handle_call({:updatecount,startTime,length,err}, _from, state) do
    {a,b,c,d} = state
    if(b == 0) do
      count = :ets.update_counter(:table, "count", {2,1})
      if(count == length-err) do
      end_time = System.monotonic_time(:millisecond) - startTime
      IO.puts "time = #{end_time}"
      System.halt(1)
      end
    end
    state = {a,b+1,c,d}
    {:reply,b+1,state}
  end

end
