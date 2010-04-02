
namespace :warehouse do
  
  desc 'Syncer all the repositories'
  task :sync do
    require 'warehouse/syncer'
    Warehouse::Syncer.process
  end

end