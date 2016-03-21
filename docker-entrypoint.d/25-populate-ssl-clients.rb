#!/usr/bin/env ruby
#
# Example usage:
#
#    GITHUB_USER='some_user' GITHUB_PASSWORD='p@sSw0rD' \
#      GITHUB_TEAMS='team1,team2' GITHUB_USERS='foo,bar' \
#      AUTHORIZED_KEYS='/home/foo/.ssh/authorized_keys' \
#      ./05-generate-authorized_keys.rb

require 'github_api'
require 'tempfile'

org = ENV['GITHUB_ORG'] || 'camptocamp'
users = (ENV['GITHUB_USERS'] || '').split(',')
teams = (ENV['GITHUB_TEAMS'] || '').split(',')
ssldir = '/etc/puppetlabs/mcollective/clients'

github = Github.new oauth_token: ENV['GITHUB_TOKEN']

teams.each do |t|
  github.orgs.teams.list(org: org).each do |tt|
    if tt.name == t
      github.orgs.teams.list_members(tt.id).each do |u|
        users << u.login
      end
    end
  end
end

users.uniq.each do |u|
  github.users.keys.list(user: u).each do |k|
    # Use a tempfile, as using stdin fails
    tmp = Tempfile.new("#{u}_#{k[:id]}")
    begin
      tmp.puts(k[:key])
      tmp.close
      File.open(File.join(ssldir, "#{u}_#{k[:id]}.pem"), 'w') do |f|
        f.puts %x{ssh-keygen -f #{tmp.path} -e -m pem}
      end
    ensure
      tmp.unlink
    end
  end
end
