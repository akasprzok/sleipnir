defmodule Sleipnir.Client.Test do
  @moduledoc """
  A test client that returns what it was sent
  """
  @type t :: %__MODULE__{
          pid: pid()
        }

  defstruct [:pid]
end

defimpl Sleipnir.Client, for: Sleipnir.Client.Test do
  alias Logproto.PushRequest

  def push(client, %PushRequest{} = request) do
    send(client.pid, {:push, request})
    {:ok, %{status: 204, headers: []}}
  end
end
