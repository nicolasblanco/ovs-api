require "mechanize"
require "redis/persistence"
require "pry"

Redis::Persistence.config.redis = Redis.new

class Event
  include Redis::Persistence

  property :title
  property :body
  property :uri
end

EVENT_URI_REGEXP = /\A[A-Za-z\-\_]{3,}\-([0-9]{3,})\.html\z/

mechanize = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

puts "Loading OVS index page..."
index_page = mechanize.get "http://paris.onvasortir.com/"

forms = index_page.forms

if forms.any?
  puts "Trying to login into OVS..."
  raise "Please set OVS_LOGIN and OVS_PASSWORD env variable in order to login to OVS." unless ENV["OVS_LOGIN"] && ENV["OVS_PASSWORD"]

  login_form = forms.first
  login_form["Pseudo"], login_form["Password"] = ENV["OVS_LOGIN"], ENV["OVS_PASSWORD"]

  login_form.submit
end

1.upto(5) do |page_number|
  puts ""
  puts "Saving events from page #{page_number}..."
  events_page = mechanize.get "http://paris.onvasortir.com/vue_sortie_all.php?page=#{page_number}&f_quoi=&autre=&filtre_age=filtre1"

  raise "Could not login into OVS, check your env variables OVS_LOGIN and OVS_PASSWORD :(" if events_page.forms.any?

  events_page.links_with(href: EVENT_URI_REGEXP).each do |link|
    event = Event.new
    event.id = link.uri.to_s.slice(EVENT_URI_REGEXP, 1)
    event.title = link.text

    event.save
    print "."
  end
end
