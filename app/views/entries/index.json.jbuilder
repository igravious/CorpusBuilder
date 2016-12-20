json.array!(@entries) do |entry|
  json.extract! entry, :id, :dictionary_id, :label, :body
  json.url entry_url(entry, format: :json)
end
