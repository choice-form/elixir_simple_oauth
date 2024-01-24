defmodule SimpleOAuth.Wechat do
  @behaviour SimpleOAuth.API

  alias SimpleOAuth.Wechat.Client

  @impl true
  def get_user_info(code, config \\ config()) do
    with {:ok, %{"access_token" => access_token, "openid" => openid}} <- token(code, config),
         {:ok, user_info} <- user_info(access_token, openid) do
      {:ok, user_info}
    else
      {:ok, _} -> {:error, :get_wechat_token_error}
      err -> err
    end
  end

  defp token(code, config) do
    appid = config[:appid]
    secret = config[:secret]

    params = [appid: appid, secret: secret, code: code, grant_type: "authorization_code"]

    case Client.token(params) do
      {:ok, body} -> {:ok, body}
      :error -> {:error, :get_wechat_token_error}
    end
  end

  defp user_info(access_token, openid) do
    params = [access_token: access_token, openid: openid]

    case Client.user_info(params) do
      {:ok, body} -> {:ok, body}
      :error -> {:error, :get_wechat_user_info_error}
    end
  end

  @doc false
  def config(config \\ SimpleOAuth.config!(:wechat_web)), do: config
end
