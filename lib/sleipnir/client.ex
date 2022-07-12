defprotocol Sleipnir.Client do
  @moduledoc """
  The HTTP client that makes requests on behalf of Sleipnir
  """

  alias Sleipnir.PushRequest
  @type t :: term()
  @type response :: %{
          status: integer(),
          headers: [{binary(), binary()}]
        }
  @type reason :: term()

  @spec push(t(), PushRequest.t()) :: {:ok, response()} | {:error, reason}
  def push(client, push_request)
end
