defmodule SimpleOAuth.Lark do
  @moduledoc """
  暂只支持使用企业自建应用登录。
  """

  @behaviour SimpleOAuth.API

  # NOTE https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/reference/authen-v1/login-overview

  @impl true
  def need_token_server, do: true

  @impl true
  def token_server_spec do
    module = __MODULE__.TokenServer
    %{id: module, start: {module, :start_link, [config()]}}
  end

  @impl true
  def get_user_info(_code, _config \\ config()) do
  end

  def oauth_url(config \\ config()) do
    query = %{
      app_id: Keyword.fetch!(config, :app_id),
      redirect_uri: redirect_uri(config),
      scope: config[:scope],
      state: config[:state]
    }

    query =
      query
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> URI.encode_query(:rfc3986)

    base_url = "https://open.feishu.cn/open-apis/authen/v1/authorize"
    base_url <> "?" <> query
  end

  defp redirect_uri(config) do
    Keyword.fetch!(config, :host) <> config[:callback_path]
  end

  @doc false
  def config(config \\ SimpleOAuth.config!(:lark)) do
    Keyword.merge(default_config(), config)
  end

  defp default_config do
    [callback_path: "oauth/lark/callback"]
  end
end
