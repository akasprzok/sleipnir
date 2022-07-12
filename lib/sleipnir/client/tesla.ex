defmodule Sleipnir.Client.Tesla do
  @moduledoc """
  Tesla client for Sleipnir.
  """
  def new(baseurl, opts \\ []) do
    middleware = [
      {Tesla.Middleware.Headers, headers(opts)},
      {Tesla.Middleware.BaseUrl, baseurl},
      {Tesla.Middleware.Telemetry, []},
      {Tesla.Middleware.Retry,
       [
         delay: 200,
         max_retries: 5,
         max_delay: 5_000,
         jitter_factor: 0.2,
         should_retry: fn
           {:ok, _} -> false
           {:error, _} -> true
         end
       ]}
    ]

    Tesla.client(middleware, Tesla.Adapter.Hackney)
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
end

defimpl Sleipnir.Client, for: Tesla.Client do
  alias Logproto.PushRequest

  alias Sleipnir.Paths

  def push(client, %PushRequest{} = request) do
    {:ok, payload} =
      request
      |> PushRequest.encode()
      |> :snappyer.compress()

    client
    |> Tesla.post(Paths.push(), payload)
    |> case do
      {:ok, response} -> {:ok, parse(response)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse(response) do
    Map.take(response, [:headers, :status])
  end
end
