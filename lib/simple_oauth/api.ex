defmodule SimpleOAuth.API do
  @callback get_user_info(code :: String.t()) :: {:ok, map()} | {:error, reason :: any()}
  @callback get_user_info(code :: String.t(), config: keyword()) ::
              {:ok, map()} | {:error, reason :: any()}
end
