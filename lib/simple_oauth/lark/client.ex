defmodule SimpleOAuth.Lark.Client do
  use Tesla

  defguardp is_2xx(term) when is_integer(term) and term >= 200 and term <= 299

  def app_access_token(app_id, app_secret) do
    client()
    |> post("/auth/v3/app_access_token/internal", %{app_id: app_id, app_secret: app_secret})
    |> case do
      {:ok, %{status: status, body: %{"code" => 0} = body}} when is_2xx(status) -> {:ok, body}
      {:ok, %{body: body}} -> {:error, body}
      _ -> :error
    end
  end

  def token(body, headers) do
    client()
    |> post("/authen/v1/oidc/access_token", body, headers: headers)
    |> case do
      {:ok, %{status: status, body: %{"code" => 0, "data" => body}}} when is_2xx(status) ->
        {:ok, body}

      {:ok, %{body: body}} ->
        {:error, body}

      _ ->
        :error
    end
  end

  def user_info(token) do
    client()
    |> get("/authen/v1/user_info", headers: [{"authorization", "Bearer #{token}"}])
    |> case do
      {:ok, %{status: status, body: %{"code" => 0, "data" => body}}} when is_2xx(status) ->
        {:ok, body}

      {:ok, %{body: body}} ->
        {:error, body}

      _ ->
        :error
    end
  end

  def client do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://open.feishu.cn/open-apis"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end
end
