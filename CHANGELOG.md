# Changelog

本文档格式见 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) 。

## [Unreleased]

## 0.5.1 - 2024-02-20

### Added

- [TokenServer] 增加独立节点模式，不再进行 hlc clock 的处理。

## 0.5.0 - 2024-02-20

### Changed

- [TokenServer] 基础的分布式 token 缓存机制。

## 0.4.0 - 2024-01-14

### Added

- [Lark] 增加飞书登录。
- [TokenServer] 支持一些拥有有效期的 token ，减少 api 请求次数。

## 0.3.0 - 2023-09-05

### Added

- [SGM] 增加上汽登录。

## 0.2.0 - 2023-09-05

### Added

- [Wechat] 增加微信网页登录。
- [Wechat] 增加微信应用登录。
- [QQ] 增加 QQ 登录。

### Changed

- [API] `SimpleOAuth.get_user_info/3`

## 0.1.1 - 2023-08-14

### Changed

- [Deps] `hackney` 不再是必须的依赖。

## 0.1.0 - 2023-08-14

### Added

- [Google] 支持 Google 登录。
