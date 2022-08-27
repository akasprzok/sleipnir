defprotocol Sleipnir.Client do
  @moduledoc """
  The HTTP client that makes requests on behalf of Sleipnir
  """

  alias Sleipnir.PushRequest

  @typedoc """
  Returned if the request was successfully sent.
  Loki will generally respond with status 204 No Content on a successful request.
  Headers should contain the headers from the response.
  """
  @type response :: %{
          status: integer(),
          headers: [{binary(), binary()}]
        }
  @type reason :: term()
  @type result :: {:ok, response} | {:error, reason}

  @doc """
  Pushes the request to Loki.
  Implementations may define their own options.
  """
  @spec push(Sleipnir.Client.t(), PushRequest.t(), Keyword.t()) :: result()
  def push(client, push_request, opts \\ [])
end
