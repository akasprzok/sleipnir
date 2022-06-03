defmodule Sleipnir.Client do
  @moduledoc """
  The HTTP client that makes requests on behalf of Sleipnir
  """

  def client(baseurl) do
    middleware = [
      {Tesla.MiddleWare.Headers, [{"Content-Type", "application/x-protobuf"}]},
      {Tesla.Middleware.BaseUrl, baseurl}
    ]

    adapter = {Tesla.Adapter.Hackney, [recv_timeout: 15_000]}
    Tesla.client(middleware, adapter)
  end

  def push(client, data) do
    Tesla.post()
  end
end
