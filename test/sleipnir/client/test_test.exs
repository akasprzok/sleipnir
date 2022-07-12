defmodule Sleipnir.Client.TestTest do
  use ExUnit.Case, async: true
  doctest Sleipnir.Client.Test

  alias Sleipnir.Client.Test, as: TestClient

  defp client(_) do
    client = %TestClient{pid: self()}
    %{client: client}
  end

  describe "push/1" do
    setup [:client]

    test "sends PushRequest to pid", %{client: client} do
      request =
        "blablabla"
        |> Sleipnir.entry()
        |> Sleipnir.stream([{"service", "loki"}])
        |> Sleipnir.request()

      assert {:ok, %{status: 204, headers: []}} == Sleipnir.push(client, request)
      assert_receive {:push, ^request}
    end
  end
end
