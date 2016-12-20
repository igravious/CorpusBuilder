json.array!(@files) do |file|
  json.extract! file, :id, :URL, :what, :strip_start, :strip_end
  json.url file_url(file, format: :json)
end
