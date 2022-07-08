defmodule Sleipnir.Client.Test do
  @moduledoc """
  A test client that returns what it was sent
  """

  alias Logproto.PushRequest
  alias Sleipnir.Client

  @behaviour Client

  @impl Client
  def new(baseurl, opts) do
    send(self(), {baseurl, opts})
    %{baseurl: baseurl, opts: opts}
  end

  @impl Client
  def push(_client, %PushRequest{} = request) do
    send(self(), request)
    {:ok, %{status: 204, headers: []}}
  end
end
