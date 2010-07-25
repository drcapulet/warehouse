module RepositoriesHelper
  def service_active?(cond)
    cond ? (cond.service_active? ? "service_active" : "service_inactive") : "service_inactive"
  end
  
  def hook_installed?(repo)
    File.exists?(hook_file(repo.path))
  end
  
  def hook_latest?(repo)
    f = File.new(hook_file(repo.path), 'r')
    f.gets; f.gets;
    f.gets.match(/[0-9].+/).to_s == ::CURRENT_HOOK_VERSION
  end
  
  def hook_file(path)
    if File.exist?(File.join(path, '.git'))
      p = File.join(path, '.git', 'hooks')
    elsif File.exist?(path) && (path =~ /\.git$/)
      p = File.join(path, 'hooks')
    else
    end
    File.join(p, 'post-receive')
  end
end
