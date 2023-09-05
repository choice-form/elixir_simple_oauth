# SimpleOAuth

The following platform logins are supported:

- Google
- Wechat(APP/Web)
- QQ
- SGM

## Configurations

Setup runtime configuration.

```elixir
config :simple_oauth, [keyword configurations]
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
