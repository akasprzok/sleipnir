defmodule Sleipnir.Client.Tesla do
  @moduledoc """
  Tesla client for Sleipnir.
  """

  alias Logproto.PushRequest
  alias Sleipnir.Client

  @behaviour Client

  @impl Client
  def new(baseurl, opts \\ []) do
    middleware = [
      {Tesla.Middleware.Headers, headers(opts)},
      {Tesla.Middleware.BaseUrl, baseurl}
    ]

    Tesla.client(middleware, Tesla.Adapter.Hackney)
  end

  @impl Client
  def push(client, %PushRequest{} = request) do
    {:ok, payload} =
      request
      |> PushRequest.encode()
      |> :snappyer.compress()

    client
    |> Tesla.post(Client.push_path(), payload)
    |> case do
      {:ok, response} -> {:ok, parse(response)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp headers(opts) do
    [{"Content-Type", "application/x-protobuf"}]
    |> Enum.concat(maybe_add_org_id(opts))
  end

  defp maybe_add_org_id(opts) do
    case Keyword.get(opts, :org_id) do
      nil -> []
      org_id -> [{"X-Scope-OrgID", org_id}]
    end
  end

  defp parse(response) do
    %{status: response.status, headers: response.headers}
  end
end
