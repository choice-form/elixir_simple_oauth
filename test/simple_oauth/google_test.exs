defmodule SimpleOAuth.GoogleTest do
  use ExUnit.Case, async: true

  alias SimpleOAuth.Google

  setup {Req.Test, :verify_on_exit!}

  describe "get_user_info/2" do
    test "success" do
      # request_body = Jason.encode!(%{
      #   code: "code",
      #   client_id: "client_id",
      #   client_secret: "client_secret",
      #   grant_type: "authorization_code",
      #   redirect_uri: "https://example.com/api/callback"
      # })

      Req.Test.expect(SimpleOAuth.GoogleClient, 2, fn
        %Plug.Conn{
          method: "POST",
          host: "oauth2.googleapis.com",
          request_path: "/token"
          # TODO 无法测试 body ，待查找方案，初步判定为 req 不支持
          # body_params: ^request_body
        } = conn ->
          Req.Test.json(conn, %{
            "access_token" => "access_token",
            "expires_in" => 3599,
            "id_token" => "id_token",
            "scope" =>
              "openid https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email",
            "token_type" => "Bearer"
          })

        %Plug.Conn{
          method: "GET",
          host: "www.googleapis.com",
          request_path: "/oauth2/v3/userinfo",
          query_string: "access_token=access_token"
        } = conn ->
          Req.Test.json(conn, %{
            "email" => "test@gmail.com",
            "email_verified" => true,
            "family_name" => "Wang",
            "given_name" => "Kenton",
            "locale" => "zh-CN",
            "name" => "Kenton Wang",
            "picture" => "https://avatar_link",
            "sub" => "sub"
          })
      end)

      assert {:ok, %{"email" => "test@gmail.com"}} = Google.get_user_info("code", test_config())
    end

    test "returns {:error, :get_google_token_error}" do
      Req.Test.expect(SimpleOAuth.GoogleClient, fn
        %Plug.Conn{
          method: "POST",
          host: "oauth2.googleapis.com",
          request_path: "/token"
        } = conn ->
          Plug.Conn.send_resp(conn, 500, "")
      end)

      assert {:error, :get_google_token_error} = Google.get_user_info("code", test_config())
    end

    test "returns {:error, :get_google_user_info_error}" do
      Req.Test.expect(SimpleOAuth.GoogleClient, 2, fn
        %Plug.Conn{
          method: "POST",
          host: "oauth2.googleapis.com",
          request_path: "/token"
        } = conn ->
          Req.Test.json(conn, %{
            "access_token" => "access_token",
            "expires_in" => 3599,
            "id_token" => "id_token",
            "scope" =>
              "openid https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email",
            "token_type" => "Bearer"
          })

        %Plug.Conn{
          method: "GET",
          host: "www.googleapis.com",
          request_path: "/oauth2/v3/userinfo"
        } = conn ->
          Plug.Conn.send_resp(conn, 500, "")
      end)

      assert {:error, :get_google_user_info_error} = Google.get_user_info("code", test_config())
    end
  end

  describe "oauth_url/1" do
    test "success" do
      assert Google.oauth_url(test_config()) ==
               "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&scope=email%20profile&client_id=client_id&redirect_uri=https%3A%2F%2Fexample.com%2Fapi%2Fcallback"
    end
  end

  describe "config/1" do
    test "set default scope and callback_path if not exist" do
      assert [scope: "profile email", callback_path: "/oauth/google/callback"] ==
               Google.config([])
    end

    test "use scope and callback_path from args" do
      assert [scope: "email", callback_path: "/callback"] ==
               Google.config(scope: "email", callback_path: "/callback")
    end
  end

  defp test_config do
    [
      client_id: "client_id",
      client_secret: "client_secret",
      callback_path: "/api/callback",
      host: "https://example.com",
      scope: "email profile"
    ]
  end
end
