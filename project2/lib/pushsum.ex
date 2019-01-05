defmodule Algo do
  def startPushSum(nodes, start_time) do
    start_node = Enum.random(nodes)
    GenServer.cast(start_node, {:pushsum,0,0,start_time, length(nodes)})
  end

  def cal_diff(this_s, this_w, s,w) do
    diff = abs((this_s/this_w) - (s/w))
  end

  def sendPushSum(new_node, this_s, this_w,start_time, length) do
    GenServer.cast(new_node, {:pushsum,this_s,this_w,start_time, length})
  end
  def startGossip(nodes,start_time) do
    start_node = Enum.random(nodes)
    Proj2.updatecount(start_node,start_time,length(nodes))
    rumour(start_node,start_time,length(nodes))
  end

  def rumour(start_node,start_time,length) do
    count = Proj2.getcount(start_node)
    cond do
      count <10 ->
        adjacentList = Proj2.getAdjacentList(start_node)
        new_node = Enum.random(adjacentList)
        Task.start(Algo, :new_rumour, [new_node,start_time,length])
        rumour(new_node,start_time,length)
      true->
        Process.exit(start_node, :normal)
    end
      rumour(start_node,start_time,length)
  end
  def new_rumour(new_node,start_time,length) do
    Proj2.updatecount(new_node,start_time,length)
    rumour(new_node, start_time, length)
  end

end
