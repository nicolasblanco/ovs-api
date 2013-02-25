module OVSApi
  module Models
    class Event
      include Redis::Persistence

      property :title
      property :body
      property :uri
      property :date
      property :starts_at
    end
  end
end
