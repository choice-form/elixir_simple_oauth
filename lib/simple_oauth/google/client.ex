defmodule SimpleOAuth.Google.Client do
  alias SimpleOAuth.Utils
  defguardp is_2xx(term) when is_integer(term) and term >= 200 and term <= 299

  def user_info(token) do
    params = URI.encode_query(%{access_token: token}, :rfc3986)

    client_v3()
    |> Req.get(url: "/userinfo" <> "?" <> params)
    |> case do
      {:ok, %Req.Response{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
    end
  end

  def token(body) do
    client()
    |> Req.post(url: "/token", json: body)
    |> case do
      {:ok, %Req.Response{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
    end
  end

  defp client() do
    [base_url: "https://oauth2.googleapis.com", retry: false]
    |> Utils.merge_req_mock_option(:google)
    |> Req.new()
  end

  defp client_v3() do
    [base_url: "https://www.googleapis.com/oauth2/v3", retry: false]
    |> Utils.merge_req_mock_option(:google)
    |> Req.new()
  end
end
