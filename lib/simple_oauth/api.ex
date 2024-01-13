defmodule SimpleOAuth.API do
  @callback get_user_info(code :: String.t()) :: {:ok, map()} | {:error, reason :: any()}
  @callback get_user_info(code :: String.t(), config: keyword()) ::
              {:ok, map()} | {:error, reason :: any()}

  @callback need_token_server() :: boolean()

  # NOTE when need_token_server/0 returns true, remember to implement this callback.
  @callback token_server_spec() :: Supervisor.child_spec()

  @optional_callbacks token_server_spec: 0
end
