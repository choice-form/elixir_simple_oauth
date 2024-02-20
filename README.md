# SimpleOAuth

The following platform logins are supported:

- Google
- Wechat(APP/Web)
- QQ
- SGM
- Lark

## Configurations

Setup runtime configuration.

```elixir
config :simple_oauth, [keyword configurations]

# global config, for token server broadcast
config :simple_oauth,
  cluster_prefix: "",
  # default to false
  # if distributed, use hlc clock in cluster to keep token updated
  distributed: {boolean}
```

### Lark

```elixir
config :simple_oauth,
  [
    lark: [
      app_id: {client_id},
      app_secret: {client_secret},
      host: {host},
      callback_path: {callback_path}, default: "/oauth/lark/callback"
    ]
  ]
```
### Google

```elixir
config :simple_oauth,
  [
    google: [
      client_id: {client_id},
      client_secret: {client_secret},
      host: {host},
      scope: {scope}, # optional, default: "profile email"
      callback_path: {callback_path}, default: "/oauth/google/callback"
    ]
  ]
```

### QQ

```elixir
config :simple_oauth,
  [
    qq: [
      client_id: {client_id},
      client_secret: {client_secret},
      host: {host},
      callback_path: {callback_path}, default: "/oauth/qq/callback"
    ]
  ]
```

### SGM

```elixir
config :simple_oauth,
  [
    sgm: [
      client_id: {client_id},
      client_secret: {client_secret},
      host: {host},
      callback_path: {callback_path}, default: "/oauth/sgm/callback"
    ]
  ]
```

### Wechat

```elixir
config :simple_oauth,
  [
    wechat_web: [
      appid: {appid},
      secret: {secret}
    ]
  ]

  [
    wechat_app: [
      appid: {appid},
      secret: {secret}
    ]
  ]
```

## Usage

`SimpleOAuth.get_user_info(provider, code, runtime_config \\ compile_config)`

### Supported providers

- google
- wechat_app
- wechat_web
- qq
- sgm
- lark
