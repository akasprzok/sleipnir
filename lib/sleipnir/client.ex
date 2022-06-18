defmodule Sleipnir.Client do
  @moduledoc """
  The HTTP client that makes requests on behalf of Sleipnir
  """

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

  @spec push(__MODULE__.t(), Sleipnir.request()) :: {:ok, response()} | {:error, term()}
  def push(client, request) do
    client
    |> Tesla.post(@push_path, request)
  end
end
