defmodule SimpleOAuth.Wechat.Client do
  alias SimpleOAuth.Utils
  defguardp is_2xx(term) when is_integer(term) and term >= 200 and term <= 299

  def user_info(params) do
    client()
    |> Req.get(url: "/userinfo" <> "?" <> URI.encode_query(params, :rfc3986))
    |> case do
      {:ok, %Req.Response{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
    end
  end

  def token(params) do
    client()
    |> Req.get(url: "/oauth2/access_token" <> "?" <> URI.encode_query(params, :rfc3986))
    |> case do
      {:ok, %Req.Response{status: status, body: body}} when is_2xx(status) -> {:ok, body}
      _ -> :error
    end
  end

  defp client() do
    [base_url: "https://api.weixin.qq.com/sns", retry: false]
    |> Utils.merge_req_mock_option(:wechat)
    |> Req.new()
  end
end
