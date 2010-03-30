begin
  # Set up load paths for the locked set of pre-resolved gems.
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on trying to resolve out of already-installed gems at runtime.
  require "rubygems"
  require "bundler"
  if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.5")
    raise RuntimeError, "Bundler incompatible.\n" +
      "Your bundler version is incompatible with Rails 2.3 and an unlocked bundle.\n" +
      "Run `gem install bundler` to upgrade or `bundle lock` to lock."
  else
    begin
      Bundler.setup
    rescue Bundler::GemNotFound
      raise Bundler::GemNotFound, "Bundler couldn't find some gems. Did you run `bundle install`?"
    end
  end
end
