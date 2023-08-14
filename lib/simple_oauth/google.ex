defmodule SimpleOAuth.Google do
  alias SimpleOAuth.Google.OAuthClient

  # https://developers.google.com/identity/protocols/oauth2/web-server
  @auth_url "https://accounts.google.com/o/oauth2/v2/auth?response_type=code"

  def oauth_url(config \\ config()) do
    query = %{
      client_id: Keyword.fetch!(config, :client_id),
      scope: config[:scope],
      redirect_uri: redirect_uri(config)
    }

    params = URI.encode_query(query, :rfc3986)

    "#{@auth_url}&#{params}"
  end

  def user_info(token) do
    case OAuthClient.user_info(token) do
      {:ok, resp_body} -> {:ok, resp_body}
      :error -> {:error, :get_google_user_info_error}
    end
  end

  def token(code, config \\ config()) do
    req_body =
      %{
        client_id: config[:client_id],
        client_secret: config[:client_secret],
        redirect_uri: redirect_uri(config),
        grant_type: "authorization_code",
        code: code
      }

    case OAuthClient.token(req_body) do
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
