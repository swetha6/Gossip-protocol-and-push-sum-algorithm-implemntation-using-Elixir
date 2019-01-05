defmodule Server do
  use GenServer
  def handle_call({:updatecount,startTime,length}, Proj2, state) do
    {a,b,c,d} = state
    if(b == 0) do
      count = :ets.update_counter(:table, "count", {2,1})
      if(count == length) do
      end_time = System.monotonic_time(:millisecond) - startTime
      IO.puts "time = #{end_time}"
      System.halt(1)
      end
    end
    state = {a,b+1,c,d}
    {:reply,b+1,state}
  end

  def handle_call({:getcount}, Proj2, state) do
    {a,b,c,d} = state
    {:reply, b, state}
  end

  def handle_call({:getAdjacent}, Proj2, state) do
    {a,b,c,d} = state
    {:reply, c, state}
  end

  def handle_call({:updatestateof_pid,nodeID},Proj2, state) do
    {a,b,c,d} = state
    state = {nodeID,b,c,d}
    {:reply, a, state}
  end

  def handle_call({:add_to_adjList, list} , Proj2, state) do
    {a,b,c,d} = state
    state = {a,b,list,d}
    {:reply,a,state}
  end

  def handle_cast({:pushsum,new_s,new_w,startTime, length},state) do
    {s,consecutive_count,adjList,w} = state
    this_s = s + new_s
    this_w = w + new_w
    diff = cal_diff(this_s,this_w,s,w)
    if(diff < :math.pow(10,-10) && consecutive_count==2) do
      count = :ets.update_counter(:table, "count", {2,1})
      if count == length do
        new_time = System.monotonic_time(:millisecond)
        end_time = new_time - startTime
        IO.puts "Convergence time = #{end_time} Milliseconds"
        System.halt(1)
      end
    end
    consecutive_count =
    if(diff < :math.pow(10,-10) && consecutive_count<2) do
      consecutive_count = consecutive_count + 1
    else
      consecutive_count = 0
    end
    state = {this_s/2,consecutive_count,adjList,this_w/2}
    new_node = Enum.random(adjList)
    Proj2.sendPushSum(new_node, this_s/2, this_w/2,startTime, length)
    {:noreply,state}
  end
  def cal_diff(this_s, this_w, s,w) do
    diff = abs((this_s/this_w) - (s/w))
  end
end
