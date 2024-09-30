import Config

config :simple_oauth,
  req_mocks: [
    qq: [plug: {Req.Test, SimpleOAuth.QQClient}],
    google: [plug: {Req.Test, SimpleOAuth.GoogleClient}],
    sgm: [plug: {Req.Test, SimpleOAuth.SGMClient}],
    lark: [plug: {Req.Test, SimpleOAuth.LarkClient}],
    wechat: [plug: {Req.Test, SimpleOAuth.WechatClient}]
  ]

config :simple_oauth, distributed: true
