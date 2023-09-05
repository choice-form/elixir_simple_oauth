defmodule SimpleOAuth.WechatTest do
  use ExUnit.Case, aysnc: true

  import Tesla.Mock

  alias SimpleOAuth.Wechat

  describe "get_user_info/2" do
    test "success" do
      user_info = %{
        "openid" => "openid",
        "unionid" => "unionid",
        "nickname" => "nickname",
        "headimgurl" => "url"
      }

      mock(fn
        %{
          method: :get,
          url:
            "https://api.weixin.qq.com/sns/oauth2/access_token?appid=app_appid&secret=app_secret&code=code&grant_type=authorization_code"
        } ->
          %Tesla.Env{status: 200, body: %{"access_token" => "access_token", "openid" => "openid"}}

        %{
          method: :get,
          url: "https://api.weixin.qq.com/sns/userinfo?access_token=access_token&openid=openid"
        } ->
          %Tesla.Env{status: 200, body: user_info}
      end)

      assert {:ok, ^user_info} = Wechat.get_user_info("code", test_config())
    end

    test "returns {:error, :get_wechat_token_error}" do
      mock(fn
        %{
          method: :get,
          url:
            "https://api.weixin.qq.com/sns/oauth2/access_token?appid=app_appid&secret=app_secret&code=code&grant_type=authorization_code"
        } ->
          %Tesla.Env{status: 500}
      end)

      assert {:error, :get_wechat_token_error} = Wechat.get_user_info("code", test_config())
    end

    test "returns {:error, :get_wechat_token_error} if token info doesn't contains openid" do
      mock(fn
        %{
          method: :get,
          url:
            "https://api.weixin.qq.com/sns/oauth2/access_token?appid=app_appid&secret=app_secret&code=code&grant_type=authorization_code"
        } ->
          %Tesla.Env{status: 200, body: %{"access_token" => "access_token"}}
      end)

      assert {:error, :get_wechat_token_error} = Wechat.get_user_info("code", test_config())
    end

    test "returns {:error, :get_user_info_error}" do
      mock(fn
        %{
          method: :get,
          url:
            "https://api.weixin.qq.com/sns/oauth2/access_token?appid=app_appid&secret=app_secret&code=code&grant_type=authorization_code"
        } ->
          %Tesla.Env{status: 200, body: %{"access_token" => "access_token", "openid" => "openid"}}

        %{
          method: :get,
          url: "https://api.weixin.qq.com/sns/userinfo?access_token=access_token&openid=openid"
        } ->
          %Tesla.Env{status: 400}
      end)

      assert {:error, :get_wechat_user_info_error} = Wechat.get_user_info("code", test_config())
    end
  end

  defp test_config do
    [appid: "app_appid", secret: "app_secret"]
  end
end
