defmodule Sleipnir.Client do
  @moduledoc """
  The HTTP client that makes requests on behalf of Sleipnir
  """

  alias Logproto.PushRequest

  @type t :: Tesla.Client.t()
  @type response :: Tesla.Env.t()

  @push_path "/loki/api/v1/push"

  def push_path, do: @push_path

  @spec client(String.t(), Keyword.t()) :: __MODULE__.t()
  def client(baseurl, opts \\ []) do
    middleware = [
      {Tesla.Middleware.Headers, headers(opts)},
      {Tesla.Middleware.BaseUrl, baseurl}
    ]

    Tesla.client(middleware, Tesla.Adapter.Hackney)
  end

  @spec push(__MODULE__.t(), PushRequest.t()) :: {:ok, response()} | {:error, term()}
  def push(client, %PushRequest{} = request) do
    {:ok, payload} =
      request
      |> PushRequest.encode()
      |> :snappyer.compress()

    client
    |> Tesla.post(@push_path, payload)
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
