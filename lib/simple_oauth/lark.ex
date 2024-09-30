defmodule SimpleOAuth.Lark do
  @moduledoc """
  暂只支持使用企业自建应用登录。
  """

  @behaviour SimpleOAuth.API

  # NOTE https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/reference/authen-v1/login-overview

  alias SimpleOAuth.TokenServer
  alias SimpleOAuth.Lark.Client
  alias SimpleOAuth.TokenServer.Record

  @impl true
  def get_user_info(code, config \\ config()) do
    with {:ok, app_access_token} <-
           get_token("app_access_token", fn -> app_access_token(config) end),
         {:ok, %{"access_token" => access_token}} <-
           token(code, app_access_token, config),
         {:ok, user_info} <- Client.user_info(access_token) do
      {:ok, user_info}
    end
  end

  defp token(code, app_access_token, _config) do
    req_body = %{grant_type: "authorization_code", code: code}

    headers = %{
      "Authorization" => "Bearer #{app_access_token}",
      "content-type" => "application/json; charset=utf-8"
    }

    case Client.token(req_body, headers) do
      {:ok, resp_body} -> {:ok, resp_body}
      :error -> {:error, :get_google_token_error}
    end
  end

  def oauth_url(config \\ config()) do
    query = %{
      app_id: Keyword.fetch!(config, :app_id),
      redirect_uri: redirect_uri(config),
      scope: config[:scope],
      state: config[:state]
    }

    query =
      query
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> URI.encode_query(:rfc3986)

    base_url = "https://open.feishu.cn/open-apis/authen/v1/authorize"
    base_url <> "?" <> query
  end

  defp redirect_uri(config) do
    Keyword.fetch!(config, :host) <> config[:callback_path]
  end

  @doc false
  def config(config \\ SimpleOAuth.config!(:lark)) do
    Keyword.merge(default_config(), config)
  end

  defp default_config do
    [callback_path: "oauth/lark/callback"]
  end

  def get_token(key, fetcher), do: TokenServer.get("lark", key, fetcher)

  def app_access_token(config) do
    case Client.app_access_token(config[:app_id], config[:app_secret]) do
      {:ok, %{"app_access_token" => token, "expire" => expires_in}} ->
        {:ok,
         Record.new(%{
           provider: "lark",
           key: "app_access_token",
           value: token,
           expires_in: expires_in
         })}

      {:error, _} = err ->
        err

      :error ->
        {:error, :client_request_error}
    end
  end
end
