defmodule SimpleOAuth do
  @supported_provider_adapters %{
    # %{provider => {adapter, module}}
    "google" => {:google, SimpleOAuth.Google},
    "wechat_app" => {:wechat_app, SimpleOAuth.Wechat},
    "wechat_web" => {:wechat_web, SimpleOAuth.Wechat},
    "qq" => {:qq, SimpleOAuth.QQ},
    "sgm" => {:sgm, SimpleOAuth.SGM},
    "lark" => {:lark, SimpleOAuth.Lark}
  }

  @supported_providers Map.keys(@supported_provider_adapters)

  def config!(adapter_name) when is_atom(adapter_name) do
    Application.fetch_env!(:simple_oauth, adapter_name)
  end

  def get_user_info(provider, code, config \\ nil)
      when provider in @supported_providers and is_binary(code) do
    {adapter, module} = @supported_provider_adapters[provider]
    config = config || config!(adapter)
    module.get_user_info(code, config)
  end

  def token_server_childrens do
    @supported_provider_adapters
    |> Enum.filter(fn {_provider, {adapter_name, adapter_module}} ->
      has_config?(adapter_name) and adapter_module.need_token_server
    end)
    |> Enum.map(fn {_provider, {_adapter_name, adapter_module}} ->
      adapter_module.token_server_spec()
    end)
  end

  def has_config?(adapter_name) do
    !!Application.get_env(:simple_oauth, adapter_name)
  end
end
