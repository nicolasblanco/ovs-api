require "mechanize"
require "redis/persistence"
require "date"
require "pry"

require File.expand_path("../config", __FILE__)
require File.expand_path("../models/event", __FILE__)

EVENT_URI_REGEXP = /\A[A-Za-z\-\_]{3,}\-([0-9]{3,})\.html\z/

mechanize = Mechanize.new { |agent|
  agent.request_headers = { "Accept-Language" => "fr-FR",
                            "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.99 Safari/537.22"
                          }
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

5.times do |day_advance|
  current_date = Date.today + day_advance
  current_url = "http://paris.onvasortir.com/vue_sortie_day.php?y=#{current_date.year}&m=#{"%02d" % current_date.month}&d=#{"%02d" % current_date.day}"
  puts ""
  puts ""
  puts "Saving events from page #{current_url}..."
  events_page = mechanize.get(current_url)

  raise "Could not login into OVS, check your env variables OVS_LOGIN and OVS_PASSWORD :(" if events_page.forms.any?

  events_page.links_with(href: EVENT_URI_REGEXP).each do |link|
    puts "following event #{link.uri}..."
    event_page = link.click

    event = OVSApi::Models::Event.new
    event.id = "#{current_date}-#{link.uri.to_s.slice(EVENT_URI_REGEXP, 1)}"
    event.title = link.text
    event.date = current_date
    event.uri = link.uri.to_s
    main_table = event_page.search("td.background_centre div.PADpost_txt")[1].search("table tr")
    # binding.pry if event.uri == "grands-scientifiques-idees-recues-6327751.html"
    event.body = main_table.last.text.gsub("\t", "").gsub("\n", "<br />")
    event.starts_at = main_table.map { |c| c.text.gsub("\t", "").gsub("\n", "") }.detect { |t| t =~ /\A[0-9]{1,2}:[0-9]{1,2}( \(du matin\))?\z/ }.gsub(" (du matin)", "")
    event.id = "#{current_date}-#{event.starts_at.gsub(":", "")}-#{link.uri.to_s.slice(EVENT_URI_REGEXP, 1)}"

    event.save
  end
end
