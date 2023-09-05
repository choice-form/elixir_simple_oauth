defmodule SimpleOAuth do
  @supported_provider_adapters %{
    # %{provider => {adapter, module}}
    "google" => {:google, SimpleOAuth.Google},
    "wechat_app" => {:wechat_app, SimpleOAuth.Wechat},
    "wechat_web" => {:wechat_web, SimpleOAuth.Wechat},
    "qq" => {:qq, SimpleOAuth.QQ},
    "sgm" => {:sgm, SimpleOAuth.SGM}
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
end
