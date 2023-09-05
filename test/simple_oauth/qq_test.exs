defmodule SimpleOAuth.QQTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias SimpleOAuth.QQ

  describe "get_user_info/2" do
    test "success" do
      user_info = %{
        "ret" => 0,
        "msg" => "",
        "nickname" => "Peter",
        "figureurl" => "http://qzapp.qlogo.cn/qzapp/111111/942FEA70050EEAFBD4DCE2C1FC775E56/30",
        "figureurl_1" => "http://qzapp.qlogo.cn/qzapp/111111/942FEA70050EEAFBD4DCE2C1FC775E56/50",
        "figureurl_2" =>
          "http://qzapp.qlogo.cn/qzapp/111111/942FEA70050EEAFBD4DCE2C1FC775E56/100",
        "figureurl_qq_1" =>
          "http://q.qlogo.cn/qqapp/100312990/DE1931D5330620DBD07FB4A5422917B6/40",
        "figureurl_qq_2" =>
          "http://q.qlogo.cn/qqapp/100312990/DE1931D5330620DBD07FB4A5422917B6/100",
        "gender" => "男"
      }

      mock(fn
        %{
          method: :get,
          url:
            "https://graph.qq.com/oauth2.0/token?client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fqq%2Fcallback"
        } ->
          %Tesla.Env{status: 200, body: "access_token=access_token&expires_in=3600"}

        %{
          method: :get,
          url: "https://graph.qq.com/oauth2.0/me?access_token=access_token"
        } ->
          %Tesla.Env{
            status: 200,
            body: "callback( {\"client_id\":\"client_id\",\"openid\":\"openid\"} );\n"
          }

        %{
          method: :get,
          url:
            "https://graph.qq.com/user/get_user_info?access_token=access_token&openid=openid&oauth_consumer_key=client_id"
        } ->
          %Tesla.Env{status: 200, body: Jason.encode!(user_info)}
      end)

      user_info_with_openid = Map.put(user_info, "openid", "openid")
      assert {:ok, ^user_info_with_openid} = QQ.get_user_info("code", test_config())
    end

    test "returns {:error, :get_qq_token_error}" do
      mock(fn
        %{
          method: :get,
          url:
            "https://graph.qq.com/oauth2.0/token?client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fqq%2Fcallback"
        } ->
          %Tesla.Env{status: 500}
      end)

      assert {:error, :get_qq_token_error} = QQ.get_user_info("code", test_config())
    end

    test "returns {:error, :get_qq_openid_error}" do
      mock(fn
        %{
          method: :get,
          url:
            "https://graph.qq.com/oauth2.0/token?client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fqq%2Fcallback"
        } ->
          %Tesla.Env{status: 200, body: "access_token=access_token&expires_in=3600"}

        %{
          method: :get,
          url: "https://graph.qq.com/oauth2.0/me?access_token=access_token"
        } ->
          %Tesla.Env{status: 500}
      end)

      assert {:error, :get_qq_openid_error} = QQ.get_user_info("code", test_config())
    end

    test "returns {:error, :get_user_info_error}" do
      mock(fn
        %{
          method: :get,
          url:
            "https://graph.qq.com/oauth2.0/token?client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fqq%2Fcallback"
        } ->
          %Tesla.Env{status: 200, body: "access_token=access_token&expires_in=3600"}

        %{
          method: :get,
          url: "https://graph.qq.com/oauth2.0/me?access_token=access_token"
        } ->
          %Tesla.Env{
            status: 200,
            body: "callback( {\"client_id\":\"client_id\",\"openid\":\"openid\"} );\n"
          }

        %{
          method: :get,
          url:
            "https://graph.qq.com/user/get_user_info?access_token=access_token&openid=openid&oauth_consumer_key=client_id"
        } ->
          %Tesla.Env{status: 500}
      end)

      assert {:error, :get_qq_user_info_error} = QQ.get_user_info("code", test_config())
    end
  end

  defp test_config do
    [
      client_id: "client_id",
      client_secret: "client_secret",
      host: "https://example.com",
      callback_path: "/oauth/qq/callback"
    ]
  end
end
