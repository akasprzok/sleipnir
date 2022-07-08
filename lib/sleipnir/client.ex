defmodule Sleipnir.Client do
  @moduledoc """
  The HTTP client that makes requests on behalf of Sleipnir
  """

  alias Logproto.PushRequest

  @type t :: term()
  @type response :: %{
          status: pos_integer(),
          headers: [{binary(), binary()}]
        }
  @type reason :: term()

  @push_path "/loki/api/v1/push"

  def push_path, do: @push_path

  @callback new(baseurl :: String.t(), opts :: Keyword.t()) :: t()

  @callback push(client :: t(), request :: PushRequest.t()) ::
              {:ok, response()} | {:error, reason()}
end
