
namespace :warehouse do
  
  desc 'Sync all the repositories'
  task :sync do
    require 'warehouse/syncer'
    Warehouse::Syncer.process
  end

end