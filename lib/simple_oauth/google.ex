defmodule SimpleOAuth.Google do
  alias SimpleOAuth.Google.Client

  # https://developers.google.com/identity/protocols/oauth2/web-server
  @auth_url "https://accounts.google.com/o/oauth2/v2/auth?response_type=code"

  @behaviour SimpleOAuth.API

  @impl true
  def need_token_server, do: false

  @impl true
  def get_user_info(code, config \\ config()) do
    with {:ok, %{"access_token" => access_token}} <- token(code, config),
         {:ok, user_info} <- user_info(access_token) do
      {:ok, user_info}
    end
  end

  def oauth_url(config \\ config()) do
    query = %{
      client_id: Keyword.fetch!(config, :client_id),
      scope: config[:scope],
      redirect_uri: redirect_uri(config)
    }

    params = URI.encode_query(query, :rfc3986)

    "#{@auth_url}&#{params}"
  end

  defp user_info(token) do
    case Client.user_info(token) do
      {:ok, resp_body} -> {:ok, resp_body}
      :error -> {:error, :get_google_user_info_error}
    end
  end

  defp token(code, config) do
    req_body =
      %{
        client_id: config[:client_id],
        client_secret: config[:client_secret],
        redirect_uri: redirect_uri(config),
        grant_type: "authorization_code",
        code: code
      }

    case Client.token(req_body) do
      {:ok, resp_body} -> {:ok, resp_body}
      :error -> {:error, :get_google_token_error}
    end
  end

  defp redirect_uri(config) do
    Keyword.fetch!(config, :host) <> config[:callback_path]
  end

  @doc false
  def config(config \\ SimpleOAuth.config!(:google)) do
    Keyword.merge(default_config(), config)
  end

  defp default_config do
    [scope: "profile email", callback_path: "/oauth/google/callback"]
  end
end
