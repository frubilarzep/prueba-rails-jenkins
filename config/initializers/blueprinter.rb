Blueprinter.configure do |config|
  # Keep keys in the order they are declared in each blueprint instead of
  # sorting them alphabetically, so the JSON matches the docs and specs.
  config.sort_fields_by = :definition
end
