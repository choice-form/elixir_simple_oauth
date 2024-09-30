defmodule SimpleOAuth.QQTest do
  use ExUnit.Case, async: true

  alias SimpleOAuth.QQ

  setup {Req.Test, :verify_on_exit!}

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

      Req.Test.expect(
        SimpleOAuth.QQClient,
        3,
        fn
          %Plug.Conn{
            method: "GET",
            host: "graph.qq.com",
            request_path: "/oauth2.0/token",
            query_string:
              "client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fqq%2Fcallback"
          } = conn ->
            Req.Test.text(conn, "access_token=access_token&expires_in=3600")

          %Plug.Conn{
            method: "GET",
            host: "graph.qq.com",
            request_path: "/oauth2.0/me",
            query_string: "access_token=access_token"
          } = conn ->
            Req.Test.text(
              conn,
              "callback( {\"client_id\":\"client_id\",\"openid\":\"openid\"} );\n"
            )

          %Plug.Conn{
            method: "GET",
            host: "graph.qq.com",
            request_path: "/user/get_user_info",
            query_string: "access_token=access_token&openid=openid&oauth_consumer_key=client_id"
          } = conn ->
            Req.Test.json(conn, user_info)
        end
      )

      user_info_with_openid = Map.put(user_info, "openid", "openid")
      assert {:ok, ^user_info_with_openid} = QQ.get_user_info("code", test_config())
    end

    test "returns {:error, :get_qq_token_error}" do
      Req.Test.expect(SimpleOAuth.QQClient, fn %Plug.Conn{
                                                 method: "GET",
                                                 host: "graph.qq.com",
                                                 request_path: "/oauth2.0/token"
                                               } = conn ->
        Plug.Conn.send_resp(conn, 500, "")
      end)

      assert {:error, :get_qq_token_error} = QQ.get_user_info("code", test_config())
    end

    test "returns {:error, :get_qq_openid_error}" do
      Req.Test.expect(SimpleOAuth.QQClient, 2, fn
        %Plug.Conn{method: "GET", host: "graph.qq.com", request_path: "/oauth2.0/token"} = conn ->
          Req.Test.text(conn, "access_token=access_token&expires_in=3600")

        %Plug.Conn{method: "GET", host: "graph.qq.com", request_path: "/oauth2.0/me"} = conn ->
          Plug.Conn.send_resp(conn, 500, "")
      end)

      assert {:error, :get_qq_openid_error} = QQ.get_user_info("code", test_config())
    end

    test "returns {:error, :get_user_info_error}" do
      Req.Test.expect(SimpleOAuth.QQClient, 3, fn
        %Plug.Conn{
          method: "GET",
          host: "graph.qq.com",
          request_path: "/oauth2.0/token",
          query_string:
            "client_id=client_id&client_secret=client_secret&code=code&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fexample.com%2Foauth%2Fqq%2Fcallback"
        } = conn ->
          Req.Test.text(conn, "access_token=access_token&expires_in=3600")

        %Plug.Conn{method: "GET", host: "graph.qq.com", request_path: "/oauth2.0/me"} = conn ->
          Req.Test.text(
            conn,
            "callback( {\"client_id\":\"client_id\",\"openid\":\"openid\"} );\n"
          )

        %Plug.Conn{method: "GET", host: "graph.qq.com", request_path: "/user/get_user_info"} =
            conn ->
          Plug.Conn.send_resp(conn, 500, "")
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
