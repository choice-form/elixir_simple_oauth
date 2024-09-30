defmodule SimpleOAuth.SGMTest do
  use ExUnit.Case, async: true

  alias SimpleOAuth.SGM

  setup {Req.Test, :verify_on_exit!}

  describe "get_user_info/2" do
    test "success" do
      Req.Test.expect(SimpleOAuth.SGMClient, 2, fn
        %Plug.Conn{
          method: "GET",
          host: "idp.saic-gm.com",
          request_path: "/oauthweb/oauth/token",
          query_string:
            "client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Fapi%2Fcallback"
        } = conn ->
          Req.Test.json(conn, %{"access_token" => "access_token", "expires_in" => 3599})

        %Plug.Conn{
          method: "GET",
          host: "idp.saic-gm.com",
          request_path: "/oauthweb/user/userinfo",
          query_string: "access_token=access_token"
        } = conn ->
          Req.Test.json(conn, %{"uid" => "uid"})
      end)

      assert {:ok, %{"uid" => "uid"}} = SGM.get_user_info("code", test_config())
    end

    test "returns {:error, :get_sgm_token_error}" do
      Req.Test.expect(SimpleOAuth.SGMClient, fn
        %Plug.Conn{
          method: "GET",
          host: "idp.saic-gm.com",
          request_path: "/oauthweb/oauth/token",
          query_string:
            "client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Fapi%2Fcallback"
        } = conn ->
          Plug.Conn.send_resp(conn, 500, "")
      end)

      assert {:error, :get_sgm_token_error} = SGM.get_user_info("code", test_config())
    end

    test "returns {:error, :get_sgm_user_info_error}" do
      Req.Test.expect(SimpleOAuth.SGMClient, 2, fn
        %Plug.Conn{
          method: "GET",
          host: "idp.saic-gm.com",
          request_path: "/oauthweb/oauth/token",
          query_string:
            "client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Fapi%2Fcallback"
        } = conn ->
          Req.Test.json(conn, %{"access_token" => "access_token", "expires_in" => 3599})

        %Plug.Conn{
          method: "GET",
          host: "idp.saic-gm.com",
          request_path: "/oauthweb/user/userinfo",
          query_string: "access_token=access_token"
        } = conn ->
          Plug.Conn.send_resp(conn, 500, "")
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
