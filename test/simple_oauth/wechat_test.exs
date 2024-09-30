defmodule SimpleOAuth.WechatTest do
  use ExUnit.Case, aysnc: true

  alias SimpleOAuth.Wechat

  setup {Req.Test, :verify_on_exit!}

  describe "get_user_info/2" do
    test "success" do
      user_info = %{
        "openid" => "openid",
        "unionid" => "unionid",
        "nickname" => "nickname",
        "headimgurl" => "url"
      }

      Req.Test.expect(SimpleOAuth.WechatClient, 2, fn
        %Plug.Conn{
          method: "GET",
          host: "api.weixin.qq.com",
          request_path: "/sns/oauth2/access_token",
          query_string:
            "appid=app_appid&secret=app_secret&code=code&grant_type=authorization_code"
        } = conn ->
          Req.Test.json(conn, %{"access_token" => "access_token", "openid" => "openid"})

        %Plug.Conn{
          method: "GET",
          host: "api.weixin.qq.com",
          request_path: "/sns/userinfo",
          query_string: "access_token=access_token&openid=openid"
        } = conn ->
          Req.Test.json(conn, user_info)
      end)

      assert {:ok, ^user_info} = Wechat.get_user_info("code", test_config())
    end

    test "returns {:error, :get_wechat_token_error}" do
      Req.Test.expect(SimpleOAuth.WechatClient, fn
        %Plug.Conn{
          method: "GET",
          host: "api.weixin.qq.com",
          request_path: "/sns/oauth2/access_token",
          query_string:
            "appid=app_appid&secret=app_secret&code=code&grant_type=authorization_code"
        } = conn ->
          Plug.Conn.send_resp(conn, 500, "")
      end)

      assert {:error, :get_wechat_token_error} = Wechat.get_user_info("code", test_config())
    end

    test "returns {:error, :get_wechat_token_error} if token info doesn't contains openid" do
      Req.Test.expect(SimpleOAuth.WechatClient, fn
        %Plug.Conn{
          method: "GET",
          host: "api.weixin.qq.com",
          request_path: "/sns/oauth2/access_token",
          query_string:
            "appid=app_appid&secret=app_secret&code=code&grant_type=authorization_code"
        } = conn ->
          Req.Test.json(conn, %{"access_token" => "access_token"})
      end)

      assert {:error, :get_wechat_token_error} = Wechat.get_user_info("code", test_config())
    end

    test "returns {:error, :get_user_info_error}" do
      Req.Test.expect(SimpleOAuth.WechatClient, 2, fn
        %Plug.Conn{
          method: "GET",
          host: "api.weixin.qq.com",
          request_path: "/sns/oauth2/access_token",
          query_string:
            "appid=app_appid&secret=app_secret&code=code&grant_type=authorization_code"
        } = conn ->
          Req.Test.json(conn, %{"access_token" => "access_token", "openid" => "openid"})

        %Plug.Conn{
          method: "GET",
          host: "api.weixin.qq.com",
          request_path: "/sns/userinfo",
          query_string: "access_token=access_token&openid=openid"
        } = conn ->
          Plug.Conn.send_resp(conn, 400, "")
      end)

      assert {:error, :get_wechat_user_info_error} = Wechat.get_user_info("code", test_config())
    end
  end

  defp test_config do
    [appid: "app_appid", secret: "app_secret"]
  end
end
