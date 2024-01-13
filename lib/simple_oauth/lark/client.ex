defmodule SimpleOAuth.Lark.Client do
  use Tesla

  defguardp is_2xx(term) when is_integer(term) and term >= 200 and term <= 299

  def app_access_token(app_id, app_secret) do
    client()
    |> post("/auth/v3/app_access_token/internal", %{app_id: app_id, app_secret: app_secret})
    |> case do
      {:ok, %{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
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
