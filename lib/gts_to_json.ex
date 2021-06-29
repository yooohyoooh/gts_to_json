defmodule GtsToJson do


  def main do
    file_name = "cube.gts"

    {_status, json_data} =
    gts_to_map(file_name) ## ここまで実行するとマップ形式
    |> map_to_struct()
    |> struct_to_json()

    json_data
  end

  def gts_to_map(file_name) do

    [head, vertexes, lines, triangles] =
    read_file(file_name)
    |> data_label

    [head_map(head), ver_map(vertexes), line_map(lines), tri_map(triangles)]
  end

  def map_to_struct([head, vertexes, lines, triangles]) do
      # data = elem(Poison.encode(head), 1)
      # vertex = elem(Poison.encode(vertexes), 1)
      # line = elem(Poison.encode(lines), 1)
      # triangle = elem(Poison.encode(triangles), 1)

    %GtsData{data: head, vertex: vertexes, line: lines, triangle: triangles}
  end

  def struct_to_json(struct) do
    Poison.encode(struct)
  end


  def read_file(file_name) do
    {_status, data} = File.read(file_name)
    data
    |> String.split("\r\n")
    |> Enum.map(fn x -> String.split(x, " ") end)
    |> Enum.map(fn x -> Enum.filter(x, fn y -> y != "" end) end)
    # |> Enum.map(fn x -> Enum.map(x, fn y -> String.to_integer(y) end) end)
    # 文字コード化してしまうのでデータの数値化は保留
  end

  def data_label(data_list) do
    [head | tail] = data_list
    [vertex, line, triangle] = Enum.map(head, fn x -> String.to_integer(x) end)
    vertexes = Enum.take(tail, vertex)
    lines = Enum.slice(tail, vertex, line)
    triangles = Enum.take(tail, -triangle)

    [head, vertexes, lines, triangles]
  end

  def head_map([vertex, line, triangle]) do
    %{"頂点の数" => vertex, "線分の数" => line, "三角形の数" => triangle}
  end

  def ver_map(vertexes) do
    for [x, y, z] <- vertexes do
      %{"x成分値" => x, "y成分値" => y, "z成分値" => z}
    end
  end

  def line_map(lines) do
    for [start, goal] <- lines do
      %{"始点の頂点番号" => start, "終点の頂点番号" => goal}
    end
  end

  def tri_map(triangles) do
    for [a, b, c] <- triangles do
      %{"１点目の線分番号" => a, "２点目の線分番号" => b, "３点目の線分番号" => c}
    end
  end

end
