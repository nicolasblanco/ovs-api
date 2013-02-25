require "grape"
require 'redis/persistence'
require "pry"

require File.expand_path("../config", __FILE__)
require File.expand_path("../models/event", __FILE__)

module OVSApi
  class API < Grape::API
    version 'v1', using: :header, vendor: "ovsapi"
    format :json

    resources :events do
      desc "Returns an event"
      get ":id" do
        OVSApi::Models::Event.find(params[:id])
      end

      desc "Returns all events ids"
      params do
        optional :date, type: String, desc: "Date of the events to retrieve (format YYYY-MM-DD)"
      end
      get "/" do
        header "Access-Control-Allow-Origin", "http://ovs-client.herokuapp.com"
        header "Access-Control-Allow-Methods", "OPTIONS, GET"
        header "Access-Control-Allow-Headers", "accept, origin, x-requested-with"

        ids = if params[:date]
          Redis::Persistence.config.redis.keys("ovs_api_models_events:#{params[:date]}-*").map do |k|
            k.gsub("ovs_api_models_events:", "")
          end
        else
          OVSApi::Models::Event.__all_ids
        end

        ids.sort.map { |id| OVSApi::Models::Event.find(id) }
      end
    end
  end
end
