defmodule SimpleOAuth.SGMTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias SimpleOAuth.SGM

  describe "get_user_info/2" do
    test "success" do
      mock(fn
        %{
          method: :get,
          url:
            "http://idp.saic-gm.com/oauthweb/oauth/token?client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Fapi%2Fcallback"
        } ->
          %Tesla.Env{
            status: 200,
            body: %{"access_token" => "access_token", "expires_in" => 3599}
          }

        %{
          method: :get,
          url: "http://idp.saic-gm.com/oauthweb/user/userinfo?access_token=access_token"
        } ->
          %Tesla.Env{status: 200, body: %{"uid" => "uid"}}
      end)

      assert {:ok, %{"uid" => "uid"}} = SGM.get_user_info("code", test_config())
    end

    test "returns {:error, :get_sgm_token_error}" do
      mock(fn
        %{
          method: :get,
          url:
            "http://idp.saic-gm.com/oauthweb/oauth/token?client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Fapi%2Fcallback"
        } ->
          %Tesla.Env{status: 500}
      end)

      assert {:error, :get_sgm_token_error} = SGM.get_user_info("code", test_config())
    end

    test "returns {:error, :get_sgm_user_info_error}" do
      mock(fn
        %{
          method: :get,
          url:
            "http://idp.saic-gm.com/oauthweb/oauth/token?client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Fapi%2Fcallback"
        } ->
          %Tesla.Env{
            status: 200,
            body: %{"access_token" => "access_token", "expires_in" => 3599}
          }

        %{
          method: :get,
          url: "http://idp.saic-gm.com/oauthweb/user/userinfo?access_token=access_token"
        } ->
          %Tesla.Env{status: 500}
      end)

      assert {:error, :get_sgm_user_info_error} = SGM.get_user_info("code", test_config())
    end
  end

  defp test_config do
    [
      client_id: "client_id",
      client_secret: "client_secret",
      callback_path: "/api/callback",
      host: "https://example.com"
    ]
  end
end
