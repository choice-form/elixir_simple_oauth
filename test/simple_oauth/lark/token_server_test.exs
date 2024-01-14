defmodule SimpleOAuth.Lark.TokenServerTest do
  use ExUnit.Case

  alias SimpleOAuth.Lark.TokenServer

  import Tesla.Mock

  setup do
    TokenServer.start_link([])
    TokenServer.set_state(%{test: true})

    :ok
  end

  test "request a new token if not cached, then cache it" do
    request_body = Jason.encode!(%{app_id: "app_id", app_secret: "app_secret"})

    mock_global(fn
      %{
        method: :post,
        url: "https://open.feishu.cn/open-apis/auth/v3/app_access_token/internal",
        body: ^request_body
      } ->
        %Tesla.Env{
          status: 200,
          body: %{"code" => 0, "msg" => "", "app_access_token" => "token", "expire" => 7200}
        }
    end)

    assert {:ok, "token"} = TokenServer.app_access_token("app_id", "app_secret")
    assert %{app_access_token: "token"} = TokenServer.get_state()
    # test clear cache signal
    assert %{test_signal: {:app_access_token, 6300}} = TokenServer.get_state()
  end

  test "use cached value first" do
    assert :ok = TokenServer.set_state(%{app_access_token: "token"})
    assert {:ok, "token"} = TokenServer.app_access_token("app_id", "app_secret")
  end
end
