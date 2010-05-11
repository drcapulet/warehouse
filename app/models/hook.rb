class Hook < ActiveRecord::Base
  WH_HOOKS = Warehouse::Hooks.list.collect { |k,v| k }
  ALL_HOOKS = WH_HOOKS # %w(post_receive)
  belongs_to :repository
  serialize :options, Hash
  
  validates_presence_of :repository_id, :name
  named_scope :active, :conditions => { :active => true }
  named_scope :disabled, :conditions => { :active => false }
  named_scope :not_post_recieve, :conditions => 'name NOT In ("post_receive")'
  
  def plugin_name
    name
  end
  
  def service_active?
    (options != {}) && active?
  end
  
  def options
    read_attribute(:options) || write_attribute(:options, {})
  end
  
  def options=(value)
    value ||= {}
    self.active = value.delete(:active) if value.key?(:active)
    self.label  = value.delete(:label)  if value.key?(:label)
    write_attribute :options, value.to_hash
  end
  
  ALL_HOOKS.each do |h|
    class_eval "def self.#{h}; first(:conditions => { :name => '#{h}' }); end"
    class_eval "def self.#{h}_new; c = self.#{h}; c ? c : self.new(:name => '#{h}'); end"
    # class_eval "def self.#{h}_new; c = self.#{h}; c ? c += [self.new(:name => '#{h}')] : c = [self.new(:name => '#{h}')]; return c; end"
  end
  
  def hook_options
    Warehouse::Hooks[name].options_info
  end
  
  def hook_options_html
    Warehouse::Hooks[name].options_html
  end
  
  def runnit(payload)
    h = Warehouse::Hooks[name].new(self, payload)
    h.run!
  end
  
  protected
    # def method_missing(method_id, *arguments, &block)
    #   if self.options && self.options.has_key?(method_id)
    #     options[method_id]
    #   else
    #     super
    #   end
    # end
end
