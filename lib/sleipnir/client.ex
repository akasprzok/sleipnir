defmodule Sleipnir.Client do
  @moduledoc """
  The HTTP client that makes requests on behalf of Sleipnir
  """

  alias Logproto.PushRequest

  @type t :: Tesla.Client.t()
  @type response :: Tesla.Env.t()

  @push_path "/loki/api/v1/push"

  def push_path, do: @push_path

  def client(baseurl) do
    middleware = [
      {Tesla.Middleware.Headers, [{"Content-Type", "application/x-protobuf"}]},
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
end
