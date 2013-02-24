module OVSApi
  module Models
    class Event
      include Redis::Persistence

      property :title
      property :body
      property :uri
      property :starts_on
    end
  end
end
