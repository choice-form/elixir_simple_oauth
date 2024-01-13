defmodule SimpleOAuth.QQ do
  @behaviour SimpleOAuth.API

  # NOTE https://wiki.connect.qq.com/
  # 根据网站所述，部分接口有变化，后续在使用过程中注意

  alias SimpleOAuth.QQ.Client

  @impl true
  def need_token_server, do: false
  @impl true
  def get_user_info(code, config \\ config()) do
    with {:ok, access_token} <- token(code, config),
         {:ok, openid} <- openid(access_token),
         {:ok, user_info} <- user_info(access_token, openid, config) do
      {:ok, Map.put(user_info, "openid", openid)}
    end
  end

  defp token(code, config) do
    params =
      [
        client_id: config[:client_id],
        client_secret: config[:client_secret],
        code: code,
        grant_type: "authorization_code",
        redirect_uri: redirect_uri(config)
      ]

    case Client.token(params) do
      {:ok, body} -> {:ok, body}
      :error -> {:error, :get_qq_token_error}
    end
  end

  defp openid(token) do
    case Client.openid(access_token: token) do
      {:ok, body} -> {:ok, body}
      :error -> {:error, :get_qq_openid_error}
    end
  end

  defp redirect_uri(config) do
    Keyword.fetch!(config, :host) <> config[:callback_path]
  end

  defp user_info(token, openid, config) do
    params = [access_token: token, openid: openid, oauth_consumer_key: config[:client_id]]

    case Client.user_info(params) do
      {:ok, body} -> {:ok, body}
      :error -> {:error, :get_qq_user_info_error}
    end
  end

  @doc false
  def config(config \\ SimpleOAuth.config!(:qq)) do
    Keyword.merge(default_config(), config)
  end

  defp default_config do
    [callback_path: "/oauth/qq/callback"]
  end
end
