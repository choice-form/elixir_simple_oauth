defmodule SimpleOAuth.Wechat.Client do
  use Tesla

  defguardp is_2xx(term) when is_integer(term) and term >= 200 and term <= 299

  def user_info(params) do
    client()
    |> get("/userinfo" <> "?" <> URI.encode_query(params, :rfc3986))
    |> case do
      {:ok, %{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
    end
  end

  def token(params) do
    client()
    |> get("/oauth2/access_token" <> "?" <> URI.encode_query(params, :rfc3986))
    |> case do
      {:ok, %{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
    end
  end

  defp client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.weixin.qq.com/sns"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end
end
