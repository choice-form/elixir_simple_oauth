defmodule SimpleOAuth.QQ.Client do
  defguardp is_2xx(term) when is_integer(term) and term >= 200 and term <= 299

  def user_info(params) do
    client()
    |> Req.get(url: "/user/get_user_info" <> "?" <> URI.encode_query(params, :rfc3986))
    |> case do
      {:ok, %Req.Response{status: status, body: %{"ret" => 0} = body}} when is_2xx(status) ->
        {:ok, body}

      _ ->
        :error
    end
  end

  def openid(params) do
    client()
    |> Req.get(url: "/oauth2.0/me" <> "?" <> URI.encode_query(params, :rfc3986), decode_body: false)
    |> case do
      {:ok, %Req.Response{status: status, body: body}} when is_2xx(status) ->
        openid =
          body
          |> String.slice(10..-5//1)
          |> Jason.decode!()
          |> Map.fetch!("openid")

        {:ok, openid}

      _ ->
        :error
    end
  end

  def token(params) do
    client()
    |> Req.get(url: "/oauth2.0/token" <> "?" <> URI.encode_query(params, :rfc3986), decode_body: false)
    |> case do
      {:ok, %Req.Response{status: status, body: body}} when is_2xx(status) ->
        token =
          body
          |> String.split("&")
          |> Enum.find(&String.starts_with?(&1, "access_token"))
          |> String.split("=")
          |> List.last()

        {:ok, token}

      _ ->
        :error
    end
  end

  defp client() do
    Req.new(base_url: "https://graph.qq.com", retry: false)
  end
end
