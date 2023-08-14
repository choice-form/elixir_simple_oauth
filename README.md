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

### Google

There are 3 main context apis (under `SimpleOAuth.Google`):

1. `oauth_url/0`/`oauth_url/1` - login google account and google will call the callback api;
2. `token/0`/`token/1` - get token (include `access_token`) by the callback request;
3. `user_info/1` - get user info (include email/name/avatar and ect.) by `access_token`.

To get user info by the callback api request (`code` is the parameter):

```elixir
    {:ok, token} = SimpleOAuth.Google.token(code)
    {:ok, profile} = SimpleOAuth.Google.user_info(token["access_token"])
```
