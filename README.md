daily_report
============

日報

## Description
confluene + jira + hipchat


## Requirement
* ruby
* bundler

## Install
```
$ git clone git@github.com:yshimada0330/daily_report.git
$ cd daily_report/
$ bundle install --path=vendor/bundle/
$ cp settings_sample.yml settings.yml
$ vim settings.yml
```

#### settings.yml

| group | key | discription | example |
| ------------ | ------------- | ------------ |------------ |
| - | domain  | confluence domain |  hoge.atlassian.net |
| hipcat | api_token  | [api token](https://coconala.hipchat.com/account/api) | xxxxxx |
| - | room_name  | [rooms](https://coconala.hipchat.com/rooms) | '00001' |
| - | user_name  | - |  'hoge' |
| - | mention  | - |  '@hoge' |
| confluence | api_url  | - |  https://hoge.atlassian.net/wiki/rpc/xmlrpc |
| - | user  | - |  taro.yamada |
| - | pass  | - |  hogehoge |
| - | label_id  | - |  '123456' |
| jira | api_url  | - |  https://hoge.atlassian.net/rest/api/2 |
| - | user_name  | - |  'taro yamada' |
| - | server_id  | - |  1234-567-abc |



## Usage

```
$ bundle exec ruby daily_report.rb
```
