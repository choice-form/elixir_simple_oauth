defmodule SimpleOAuth.Lark.Client do
  defguardp is_2xx(term) when is_integer(term) and term >= 200 and term <= 299

  def app_access_token(app_id, app_secret) do
    client()
    |> Req.post(
      url: "/auth/v3/app_access_token/internal",
      json: %{app_id: app_id, app_secret: app_secret}
    )
    |> case do
      {:ok, %Req.Response{status: status, body: %{"code" => 0} = body}} when is_2xx(status) ->
        {:ok, body}

      {:ok, %Req.Response{body: body}} ->
        {:error, body}

      _ ->
        :error
    end
  end

  def token(body, headers) do
    client()
    |> Req.post(url: "/authen/v1/oidc/access_token", json: body, headers: headers)
    |> case do
      {:ok, %Req.Response{status: status, body: %{"code" => 0, "data" => body}}}
      when is_2xx(status) ->
        {:ok, body}

      {:ok, %Req.Response{body: body}} ->
        {:error, body}

      _ ->
        :error
    end
  end

  def user_info(token) do
    client()
    |> Req.get(url: "/authen/v1/user_info", headers: %{"authorization" => "Bearer #{token}"})
    |> case do
      {:ok, %Req.Response{status: status, body: %{"code" => 0, "data" => body}}}
      when is_2xx(status) ->
        {:ok, body}

      {:ok, %Req.Response{body: body}} ->
        {:error, body}

      _ ->
        :error
    end
  end

  def client do
    Req.new(base_url: "https://open.feishu.cn/open-apis", retry: false)
  end
end
