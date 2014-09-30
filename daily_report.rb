# -*- coding: utf-8 -*-
require 'yaml'
require 'xmlrpc/client'
require 'date'
require 'hipchat'
require 'json'
require 'faraday'

settings = YAML.load_file("settings.yml")

confluence_settings = settings['confluence']
jira_settings = settings['jira']
hipcat_settings = settings['hipcat']

DOMAIN = settings['domain']

CONFLUENCE_URL = confluence_settings['api_url']
USER = confluence_settings['user']
PASS = confluence_settings['pass']
LABEL_ID = confluence_settings['label_id']

JIRA_URL = jira_settings['api_url']
USER_NAME = jira_settings['user_name']

SERVER_ID = jira_settings['server_id']

ROOMNAME = hipcat_settings['room_name']
HIP_CHAT_NAME = hipcat_settings['user_name']
MENTION = hipcat_settings['mention']
API_TOKEN = hipcat_settings['api_token']


def create_client
  server = XMLRPC::Client.new2(CONFLUENCE_URL)
  server.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)

  server.proxy('confluence2')
end

def login(client)
  client.login(USER, PASS)
end

def issues()
  client = Faraday.new
  client.basic_auth(USER, PASS)
  response = client.send(:get, JIRA_URL + '/search', {jql: "assignee= \"#{USER_NAME}\" order by updated", maxResults: 5, fields: 'summary'})
  json = JSON.parse(response.body.to_s)
  issues = []
  json['issues'].each do |issue|
    li = <<-EOS
    <li>
    <ac:structured-macro ac:name=\"jira\">
      <ac:parameter ac:name=\"server\">JIRA (#{DOMAIN})</ac:parameter>
      <ac:parameter ac:name=\"serverId\">#{SERVER_ID}</ac:parameter>
      <ac:parameter ac:name=\"key\">#{issue['key']}</ac:parameter>
    </ac:structured-macro>
    </li>
    EOS

    issues << li
  end

  issues

end

def post_blog(client, token)
  title = Date.today.strftime('%Y%m%d')

content = <<-EOS
<h3>今日やったこと</h3>
<ul>#{issues().join('')}</ul>
<h3>明日やること</h3>
<ul>
<li></li>
</ul>
EOS

  blog_param = {space: "~#{USER}", title: title, content: content}
  blog_entry = client.storeBlogEntry(token, blog_param)
  client.addLabelById(token, LABEL_ID, blog_entry['id'])
  blog_entry
end


def notify(url)
  client = HipChat::Client.new(API_TOKEN, api_version: 'v2')
  message = "#{MENTION} 日報の準備ができました。 (hipchat)  #{url}"

  room = client[ROOMNAME]
  room.send(HIP_CHAT_NAME, message, notify: true, color: 'green', message_format: 'text')
end

client = create_client
token = login client
blog = post_blog client, token

notify blog['url']
