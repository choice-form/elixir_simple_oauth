# SimpleOAuth

The following platform logins are supported:

- Google

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

## Usage

`SimpleOAuth.get_user_info(provider, code, runtime_config \\ compile_config)`

### Supported providers

- google
