json.array!(@texts) do |text|
  json.extract! text, :id, :name, :original_year, :edition_year
  json.url text_url(text, format: :json)
end
