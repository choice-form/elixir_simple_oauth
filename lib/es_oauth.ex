defmodule SimpleOAuth do
  def config!(adapter_name) when is_atom(adapter_name) do
    Application.fetch_env!(:simple_oauth, adapter_name)
  end
end
