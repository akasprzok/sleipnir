defmodule Sleipnir.Client.Test do
  @moduledoc """
  A client that can be useful for testing applications using Sleipnir.
  Can be used instead of a mock client, or a mock server.

  Returns the push request passed to `push` to the `pid` specified when
  constructing the client in the form of {:push, request}.

  `delay_ms` is an optional field that can be used to make the client "slow" -
  it will still send the message right at invocation, but only returns after the specified delay has elapsed.
  Defaults to 0.

  """
  @type t :: %__MODULE__{
          pid: pid(),
          delay_ms: integer()
        }

  @enforce_keys [:pid]
  defstruct [
    :pid,
    delay_ms: 0
  ]
end

defimpl Sleipnir.Client, for: Sleipnir.Client.Test do
  alias Logproto.PushRequest

  def push(client, %PushRequest{} = request, _opts \\ []) do
    send(client.pid, {:push, request})
    :timer.sleep(client.delay_ms)
    {:ok, %{status: 204, headers: []}}
  end
end
