Warehouse::Hooks.discover
WH_CONFIG = (YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + "/../../config/warehouse.yml")).result)[RAILS_ENV]).symbolize_keys