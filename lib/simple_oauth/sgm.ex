defmodule SimpleOAuth.SGM do
  alias SimpleOAuth.SGM.Client

  @behaviour SimpleOAuth.API

  @impl true
  def get_user_info(code, config \\ config()) do
    with {:ok, %{"access_token" => access_token}} <- token(code, config),
         {:ok, user_info} <- user_info(access_token) do
      {:ok, user_info}
    end
  end

  defp user_info(token) do
    case Client.user_info(access_token: token) do
      {:ok, resp_body} -> {:ok, resp_body}
      :error -> {:error, :get_sgm_user_info_error}
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
      {:ok, resp_body} -> {:ok, resp_body}
      :error -> {:error, :get_sgm_token_error}
    end
  end

  defp redirect_uri(config) do
    Keyword.fetch!(config, :host) <> config[:callback_path]
  end

  @doc false
  def config(config \\ SimpleOAuth.config!(:sgm)) do
    Keyword.merge(default_config(), config)
  end

  defp default_config do
    [callback_path: "/oauth/sgm/callback"]
  end
end
