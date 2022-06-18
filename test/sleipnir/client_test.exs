defmodule Sleipnir.ClientTest do
  use ExUnit.Case, async: true
  doctest Sleipnir.Client

  alias Logproto.{PushRequest, StreamAdapter}

  import Sleipnir.Client

  defp endpoint_url(port), do: "http://localhost:#{port}"

  defp bypass(_) do
    bypass = Bypass.open()
    client = bypass.port |> endpoint_url() |> client()
    {:ok, bypass: bypass, client: client}
  end

  describe "client/1" do
    test "returns a valid client" do
      %Tesla.Client{} = client("localhost:3000")
    end
  end

  describe "push/1" do
    setup [:bypass]

    test "smoke test", %{client: client, bypass: bypass} do
      labels = [{"service", "sleipnir"}]
      entry = Sleipnir.entry("blablabla")
      stream = Sleipnir.stream(labels, [entry])
      request = Sleipnir.request(stream)

      Bypass.expect_once(
        bypass,
        "POST",
        "/loki/api/v1/push",
        fn conn ->
          {:ok, payload, _conn} = Plug.Conn.read_body(conn)
          {:ok, decompressed_payload} = :snappyer.decompress(payload)

          %PushRequest{
            streams: [
              %StreamAdapter{
                entries: [
                  ^entry
                ],
                labels: ~s({service="sleipnir"})
              }
            ]
          } = decompressed_payload |> PushRequest.decode()

          Plug.Conn.resp(
            conn,
            204,
            ""
          )
        end
      )

      client |> push(request)
    end
  end
end
