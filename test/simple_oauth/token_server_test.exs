defmodule SimpleOAuth.TokenServerTest do
  use ExUnit.Case, async: true

  alias SimpleOAuth.TokenServer
  alias SimpleOAuth.TokenServer.Record

  setup ctx do
    cluster = start_supervised!({ExUnitCluster.Manager, ctx})
    {:ok, cluster: cluster}
  end

  describe "during startup" do
    test "init state to []", %{cluster: cluster} do
      node_1 = ExUnitCluster.start_node(cluster)
      assert [] = ExUnitCluster.call(cluster, node_1, TokenServer, :state, [])
    end

    # NOTE ExUnitCluster doesn't support connect to the other nodes in same cluster automatically.
    # The GenServer complete the startup process without connected nodes.
    # So the synchronization doesn't effective.

    # test "sync state from cluster", %{cluster: cluster} do
    #   node_1 = ExUnitCluster.start_node(cluster)
    #   records = [Record.new(%{provider: "lark", key: "app_access_token", value: "token"})]
    #   ExUnitCluster.call(cluster, node_1, TokenServer, :state, [records])

    #   assert ^records = ExUnitCluster.call(cluster, node_1, TokenServer, :state, [])
    #   node_2 = start_connected_node(cluster, node_1)
    #   ExUnitCluster.call(cluster, node_2, Node, :list, []) |> IO.inspect()
    #   assert ^records = ExUnitCluster.call(cluster, node_2, TokenServer, :state, [])
    # end
  end

  describe "working with the isolated node itself" do
    test "get new value and cache it by running fetcher", %{cluster: cluster} do
      node = ExUnitCluster.start_node(cluster)

      record =
        Record.new(%{provider: "lark", key: "app_access_token", value: "token", expires_in: 7200})

      fetcher = fn -> {:ok, record} end

      assert [] = ExUnitCluster.call(cluster, node, TokenServer, :state, [])

      assert {:ok, "token"} =
               ExUnitCluster.call(cluster, node, TokenServer, :get, [
                 "lark",
                 "app_access_token",
                 fetcher
               ])

      assert [^record] = ExUnitCluster.call(cluster, node, TokenServer, :state, [])
    end

    test "get existed value", %{cluster: cluster} do
      node = ExUnitCluster.start_node(cluster)

      record =
        Record.new(%{provider: "lark", key: "app_access_token", value: "token", expires_in: 7200})

      fetcher = fn -> {:ok, nil} end

      assert :ok = ExUnitCluster.call(cluster, node, TokenServer, :state, [[record]])

      assert {:ok, "token"} =
               ExUnitCluster.call(cluster, node, TokenServer, :get, [
                 "lark",
                 "app_access_token",
                 fetcher
               ])

      assert [^record] = ExUnitCluster.call(cluster, node, TokenServer, :state, [])
    end

    test "get new value and cache it by running fetcher if record expired", %{cluster: cluster} do
      node = ExUnitCluster.start_node(cluster)

      record =
        Record.new(%{provider: "lark", key: "app_access_token", value: "token", expires_in: 7200})
        |> set_expired()

      new_record =
        Record.new(%{
          provider: "lark",
          key: "app_access_token",
          value: "new_token",
          expires_in: 7200
        })

      fetcher = fn -> {:ok, new_record} end

      assert :ok = ExUnitCluster.call(cluster, node, TokenServer, :state, [[record]])

      assert {:ok, "new_token"} =
               ExUnitCluster.call(cluster, node, TokenServer, :get, [
                 "lark",
                 "app_access_token",
                 fetcher
               ])

      assert [^new_record] = ExUnitCluster.call(cluster, node, TokenServer, :state, [])
    end
  end

  describe "working with cluster" do
    test "get new value and cache it by sync state from other nodes", %{cluster: cluster} do
      node_1 = ExUnitCluster.start_node(cluster)

      record =
        Record.new(%{provider: "lark", key: "app_access_token", value: "token", expires_in: 7200})

      assert :ok = ExUnitCluster.call(cluster, node_1, TokenServer, :state, [[record]])

      node_2 = start_connected_node(cluster, node_1)

      assert [] = ExUnitCluster.call(cluster, node_2, TokenServer, :state, [])

      fetcher = fn -> {:ok, nil} end

      assert {:ok, "token"} =
               ExUnitCluster.call(cluster, node_2, TokenServer, :get, [
                 "lark",
                 "app_access_token",
                 fetcher
               ])

      assert [^record] = ExUnitCluster.call(cluster, node_2, TokenServer, :state, [])
    end

    test "get new value and cache it by running fetcher then sync it to other nodes", %{
      cluster: cluster
    } do
      node_1 = ExUnitCluster.start_node(cluster)
      node_2 = start_connected_node(cluster, node_1)

      record =
        Record.new(%{provider: "lark", key: "app_access_token", value: "token", expires_in: 7200})

      fetcher = fn -> {:ok, record} end

      assert [] = ExUnitCluster.call(cluster, node_1, TokenServer, :state, [])
      assert [] = ExUnitCluster.call(cluster, node_2, TokenServer, :state, [])

      assert {:ok, "token"} =
               ExUnitCluster.call(cluster, node_1, TokenServer, :get, [
                 "lark",
                 "app_access_token",
                 fetcher
               ])

      assert [^record] = ExUnitCluster.call(cluster, node_1, TokenServer, :state, [])
      assert [^record] = ExUnitCluster.call(cluster, node_2, TokenServer, :state, [])
    end

    test "get new value and cache it by running fetcher if record expired then sync it to other nodes",
         %{cluster: cluster} do
      node_1 = ExUnitCluster.start_node(cluster)
      node_2 = start_connected_node(cluster, node_1)

      record =
        Record.new(%{provider: "lark", key: "app_access_token", value: "token", expires_in: 7200})
        |> set_expired()

      new_record =
        Record.new(%{provider: "lark", key: "app_access_token", value: "token", expires_in: 7200})

      fetcher = fn -> {:ok, new_record} end

      assert :ok = ExUnitCluster.call(cluster, node_1, TokenServer, :state, [[record]])
      assert :ok = ExUnitCluster.call(cluster, node_2, TokenServer, :state, [[record]])

      assert {:ok, "token"} =
               ExUnitCluster.call(cluster, node_1, TokenServer, :get, [
                 "lark",
                 "app_access_token",
                 fetcher
               ])

      assert [^new_record] = ExUnitCluster.call(cluster, node_1, TokenServer, :state, [])
      assert [^new_record] = ExUnitCluster.call(cluster, node_2, TokenServer, :state, [])
    end
  end

  defp start_connected_node(cluster, base_node) do
    new_node = ExUnitCluster.start_node(cluster)
    ExUnitCluster.call(cluster, new_node, Node, :connect, [base_node])
    new_node
  end

  defp set_expired(%{updated_at: updated_at} = record) do
    new_time =
      updated_at.time
      |> DateTime.from_unix!(:millisecond)
      |> DateTime.add(-3, :hour)
      |> DateTime.to_unix(:millisecond)

    Map.put(record, :updated_at, %{updated_at | time: new_time})
  end
end
