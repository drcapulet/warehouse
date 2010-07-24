
namespace :warehouse do
  
  desc 'Sync all the repositories'
  task :sync, :path do |t, args|
    require 'warehouse/syncer'
    args[:path] ? Warehouse::Syncer.process(args[:path]) : Warehouse::Syncer.process
  end

end