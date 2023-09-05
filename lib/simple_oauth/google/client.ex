defmodule SimpleOAuth.Google.Client do
  use Tesla

  defguardp is_2xx(term) when is_integer(term) and term >= 200 and term <= 299

  def user_info(token) do
    params = URI.encode_query(%{access_token: token}, :rfc3986)

    client_v3()
    |> get("/userinfo" <> "?" <> params)
    |> case do
      {:ok, %{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
    end
  end

  def token(body) do
    client()
    |> post("/token", body)
    |> case do
      {:ok, %{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
    end
  end

  defp client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://oauth2.googleapis.com"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  defp client_v3() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://www.googleapis.com/oauth2/v3"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end
end
