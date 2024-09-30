import Config

config :simple_oauth,
  req_mocks: [
    qq: [],
    google: [],
    sgm: [],
    lark: [],
    wechat: []
  ]

if "#{Mix.env()}.exs" |> Path.expand(__DIR__) |> File.exists?() do
  import_config "#{Mix.env()}.exs"
end

if "#{Mix.env()}.secret.exs" |> Path.expand(__DIR__) |> File.exists?() do
  import_config "#{Mix.env()}.secret.exs"
end
