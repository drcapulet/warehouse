
namespace :warehouse do
  
  task :sync do
    require 'warehouse/syncer'
    Warehouse::Syncer.process
  end

end