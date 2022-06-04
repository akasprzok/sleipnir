defmodule Sleipnir.ClientTest do
  use ExUnit.Case, async: true
  doctest Sleipnir.Client

  import Sleipnir.Client
  import Tesla.Mock

  @base_url "https://google.com"

  def mocks(_) do
    client = client(@base_url, Tesla.Mock)

    url = @base_url <> push_path()

    mock(fn
      %{method: :post, url: ^url} ->
        %Tesla.Env{status: 204}
    end)

    %{client: client}
  end

  describe "client/1" do
    test "returns a valid client" do
      %Tesla.Client{} = client("localhost:3000")
    end
  end

  describe "push/1" do
    setup [:mocks]

    test "let's mock some stuff I guess", %{client: client} do
      {:ok, %Tesla.Env{} = response} = client |> push("blablabla")

      assert response.status == 204
    end
  end
end
