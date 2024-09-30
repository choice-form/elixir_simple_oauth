defmodule SimpleOAuth.Utils do
  def merge_req_mock_option(opts, type) do
    mock_opts =
      :simple_oauth
      |> Application.get_env(:req_mocks, [])
      |> Keyword.get(type, [])

    Keyword.merge(opts, mock_opts)
  end
end
