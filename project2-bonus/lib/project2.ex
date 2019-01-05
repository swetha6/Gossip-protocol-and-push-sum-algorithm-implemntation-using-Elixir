defmodule Topo do
  def generate_array(length, list \\ []) do
    if length == 0 do
      list
  else
    length-1 |> generate_array([:rand.uniform() |> Float.round(2) | list])
  end
  end

  def check_neighbours(c, p) do
    {a, b} = p
    {p, q} = c
    first = :math.pow((a-p), 2)
    last = :math.pow((b-q), 2)
    radii = :math.pow(first + last, 1/2)
    if radii <= 0.1 and radii > 0 do
      true
    else
      false
    end
  end
  def create_coordinates(nodes) do
    length = Enum.count(nodes)
    x = generate_array(length)
    y = generate_array(length)
    coordinates = Enum.zip(x, y)
  end

  def buildRand2D(nodes) do
    list = create_coordinates(nodes)
    Enum.each(nodes, fn x ->
      i = Enum.find_index(nodes, fn b -> b == x end)
      c = Enum.fetch!(list, i)
      num_nodes = Enum.count(nodes)
      n_list = Enum.filter((0..num_nodes-1), fn y -> check_neighbours(c, Enum.at(list, y)) end)
      adjlist = Enum.map_every(n_list, 1, fn x -> Enum.at(nodes, x) end)
      Proj2.add_to_adjList(x,adjlist)
    end)
  end

  def buildImlineTopo(nodes) do
    num_nodes = length(nodes)
    start = 0
    end_val = (num_nodes - 1)
    Enum.each(nodes, fn(x) ->
      index = Enum.find_index(nodes,fn(i) -> i==x end)
      adjlist = []
      cond do
        index < end_val && index > start ->
          n1 = Enum.at(nodes,index-1)
          n2 = Enum.at(nodes,index+1)
          n3 = Enum.random(nodes)
          adjlist = adjlist ++ [n1,n2,n3]
          Proj2.add_to_adjList(x,adjlist)
        index < start ->
          n2 = Enum.at(nodes,index+1)
          n3 = Enum.random(nodes)
          adjlist = adjlist ++ [n2,n3]
          Proj2.add_to_adjList(x,adjlist)
        true->
          n1 = Enum.at(nodes,index-1)
          n3 = Enum.random(nodes)
          adjlist = adjlist ++ [n1,n3]
          Proj2.add_to_adjList(x,adjlist)
          # IO.inspect adjlist
      end
    end)
  end
  def buildlineTopo(nodes) do
    num_nodes = length(nodes)
    start = 0
    end_val = (num_nodes - 1)
    Enum.each(nodes, fn(x) ->
      index = Enum.find_index(nodes,fn(i) -> i==x end)
      adjlist = []
      cond do
        index < end_val && index > start ->
          n1 = Enum.at(nodes,index-1)
          n2 = Enum.at(nodes,index+1)
          adjlist = adjlist ++ [n1,n2]
          Proj2.add_to_adjList(x,adjlist)
        index < start ->
          n2 = Enum.at(nodes,index+1)
          adjlist = adjlist ++ [n2]
          Proj2.add_to_adjList(x,adjlist)
        true->
          n1 = Enum.at(nodes,index-1)
          adjlist = adjlist ++ [n1]
          Proj2.add_to_adjList(x,adjlist)
          # IO.inspect adjlist
      end
    end)
  end
  def buildfullTopo(nodes) do
    Enum.each(nodes, fn(x) ->
      adjlist = List.delete(nodes,x)
      Proj2.add_to_adjList(x,adjlist)
    end)
  end
  def toroid(nodes) do
    numNodes=Enum.count(nodes)
    sqrt = :math.sqrt(numNodes)
    numNodesSQRT1= :math.sqrt numNodes
    numNodesSQRT = trunc(numNodesSQRT1)
    ans = trunc(:math.pow(numNodesSQRT,2) )
    all = Enum.slice(nodes, 0, ans)
    Enum.each(nodes, fn(k) ->
      neighbors=[]
      count=Enum.find_index(nodes, fn(x) -> x==k end)
      neighbors=if(!bottom_node(count,sqrt)) do
        index = count + round(numNodesSQRT)
        neighbhour1=Enum.fetch!(nodes, index)
        neighbors = neighbors ++ [neighbhour1]
        neighbors
    else
      neighbors
    end
      neighbors=if(!top_node(count,sqrt)) do
        index=count - round(numNodesSQRT)
        neighbhour2=Enum.fetch!(nodes, index)
        neighbors = neighbors ++ [neighbhour2]
        neighbors
      else
        neighbors
      end

      neighbors=if(!left_node(count,sqrt)) do
        index=count - 1
        neighbhour3=Enum.fetch!(nodes,index )
        neighbors = neighbors ++ [neighbhour3]
        neighbors
      else
        neighbors
      end

       neighbors=if(!right_node(count,sqrt)) do
        index=count + 1
        neighbhour4=Enum.fetch!(nodes, index)
        neighbors = neighbors ++ [neighbhour4]
        neighbors
      else
        neighbors
      end

      neighbors = if(top_node(count, sqrt)) do
      index = count + round(numNodesSQRT)*(round(numNodesSQRT)-1)
      neighbour5 = Enum.fetch!(nodes, index)
      neighbors = neighbors ++ [neighbour5]
      neighbors
      else
        neighbors
      end

      neighbors = if(bottom_node(count,sqrt)) do
      index= count - (round(numNodesSQRT)* round(numNodesSQRT)-1)
      #IO.puts "bottom"
      # IO.inspect index
      neighbour6 = Enum.fetch!(nodes, index)
      neighbors = neighbors ++[neighbour6]
      neighbors
      else
        neighbors
      end
      neighbors = if(right_node(count, sqrt))do
      index = count - (round(numNodesSQRT)-1)
      #IO.puts "right"
      # IO.inspect index
      neighbour7 = Enum.fetch!(nodes, index)
      neighbors = neighbors ++ [neighbour7]
      neighbors

      else
        neighbors
      end

      neighbors = if(left_node(count, sqrt)) do
      index = count + (round(numNodesSQRT)-1)
      neighbour8 = Enum.fetch!(nodes, index)
      neighbors = neighbors ++ [neighbour8]
      neighbors

      else
         neighbors
      end
      # IO.inspect neighbors
      Proj2.add_to_adjList(k,neighbors)
    end)
  end
  def bottom_node(i,sqrt) do
    if(i>=(sqrt*sqrt - sqrt)) do
      true
    else
      false
    end
  end

  def top_node(i,sqrt) do
    if(i< sqrt) do
      true
    else
      false
    end
  end

  def left_node(i,sqrt) do
    if(rem(i,trunc(sqrt)) == 0) do
      true
    else
      false
    end
  end

  def right_node(i,sqrt) do
    if(rem(i+1,trunc(sqrt)) == 0) do
      true
    else
      false
    end
  end
  def is3DRight(i,length) do
    # IO.puts length
    num = trunc(:math.pow(length, 0.34))
    # IO.puts "num = #{num}"
    len1 = num*num
    i = rem(i,len1)
    # IO.puts i
    # IO.puts i+1
    # IO.puts num
    k = rem(i+1, num)
    # IO.puts k
    if(rem(i+1, num)==0) do
      # IO.puts "lol"
      true
    else
      false
    end
  end

  def is3DLeft(i,length) do
    num = trunc(:math.pow(length, 0.34))
    len1 = num*num
    i = rem(i,len1)
    if(rem(i, trunc(:math.sqrt(len1)))==0) do
      true
    else
      false
    end
  end

  def isNodeFront(i,length) do
    len1 = trunc(:math.pow(length,0.34))
    if i < trunc(:math.pow(len1, 2)) do
      true
    else
      false
    end
  end

  def isNodeLast(i,length) do
    len1 = trunc(:math.pow(length, 0.34))
    if i + trunc(:math.pow(len1, 2)) >= length do
      true
    else
      false
    end

  end

  def is3DTop(i,length) do
    num = trunc(:math.pow(length, 0.34))
    i = rem(i , (num*num))
    if (i < num) do
      true
    else
      false
    end
  end

  def is3DBottom(i,length) do
    num = trunc(:math.pow(length, 0.34))
    len1 = num*num
    i = rem i , len1
    if i >= len1 -  trunc(:math.sqrt(len1)) do
      true
    else
      false
    end
  end
  def build3D(nodes) do
    numNodes=Enum.count(nodes)
    #numNodesSQRT= trunc(:math.pow(numNodes, 0.34))
    # ans = :math.pow(numNodesSQRT,3)
    # all = Enum.slice(nodes, 0, ans)

    Enum.each(nodes, fn(k) ->
      adjList=[]
      # IO.inspect adjList
      count=Enum.find_index(nodes, fn(x) -> x==k end)
      adjList = if(is3DLeft(count,numNodes))do
      n1 = Enum.fetch!(nodes, count+1) #adding right element
      adjList = adjList ++ [n1]
      #IO.puts "left"
      adjList
    else
      adjList
    end
    # IO.inspect adjList
    # if(isNodeLast(count,numNodes))do
    #   IO.puts "here"
    # end
    adjList=if(is3DRight(count,numNodes))do
      n2=Enum.fetch!(nodes, count-1)
      adjList = adjList ++[n2]
     # IO.puts "right"
      # IO.inspect count
      adjList
    else
      adjList
    end

    adjList=if(!is3DRight(count,numNodes) && !is3DLeft(count,numNodes)) do
      n3 = Enum.fetch!(nodes, count-1)
      n4 = Enum.fetch!(nodes, count+1)
      #IO.puts "not right not left"
      adjList=adjList++[n3]
      adjList= adjList++[n4]
      adjList
    else
      adjList
    end
    adjList=if(!isNodeFront(count,numNodes) && !isNodeLast(count,numNodes)) do
      mover = trunc(:math.pow(numNodes, 0.34))
      mover = mover*mover
     # IO.puts "not front & not last"
      n5=Enum.fetch!(nodes, count+mover)
      n6=Enum.fetch!(nodes, count-mover)
      adjList = adjList ++ [n5]
      adjList = adjList ++ [n6]
      adjList
    else
      adjList
    end

    # IO.puts count
    adjList = if(!isNodeFront(count,numNodes) && isNodeLast(count,numNodes)) do
      mover = trunc(:math.pow(numNodes, 0.34))
      #IO.puts "not front but last"
      mover = mover*mover
      n7 = Enum.fetch!(nodes, count-mover)
      adjList = adjList ++[n7]
      adjList
    else
      adjList
    end
    # IO.inspect adjList

    adjList = if(!isNodeLast(count,numNodes) && isNodeFront(count,numNodes)) do
      mover = trunc(:math.pow(numNodes, 0.34))
      #IO.puts "not last front"
      mover = mover*mover
      n8=Enum.fetch!(nodes, count+mover)
      adjList = adjList++[n8]
    else
      adjList
    end

    adjList = if(!is3DTop(count,numNodes) && !is3DBottom(count,numNodes)) do
      #IO.puts "not top not bottom"
      mover = trunc(:math.pow(numNodes, 0.34))
      n9 = Enum.fetch!(nodes, count+mover)
      n10 = Enum.fetch!(nodes, count-mover)
      adjList = adjList ++[n9]
      adjList = adjList++ [n10]
      adjList
    else
      adjList
    end

    adjList = if(!is3DTop(count,numNodes) && is3DBottom(count,numNodes)) do
      #IO.puts "not top but bottom"
      mover = trunc(:math.pow(numNodes, 0.34))
      n11 = Enum.fetch!(nodes, count-mover)
      adjList = adjList++ [n11]
      adjList
    else
      adjList
    end

    adjList = if(is3DTop(count,numNodes) && !is3DBottom(count,numNodes)) do
      #IO.puts "top not bottom"
      mover = trunc(:math.pow(numNodes, 0.34))
      n12 = Enum.fetch!(nodes, count+mover)
      #IO.inspect n12
      adjList = adjList ++ [n12]
      adjList
    else
      adjList
    end
      #IO.puts "XXXXX"
      Proj2.add_to_adjList(k,adjList)
    end)
    #IO.puts "the end"
  end

  end
