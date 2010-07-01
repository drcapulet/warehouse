class WarehouseFormBuilder < Formtastic::SemanticFormBuilder
  def input(method, options = {})
    if options.key?(:selected) || options.key?(:checked) || options.key?(:default)
      ::ActiveSupport::Deprecation.warn(
        "The :selected, :checked (and :default) options are deprecated in Formtastic and will be removed from 1.0. " <<
        "Please set default values in your models (using an after_initialize callback) or in your controller set-up. " <<
        "See http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html for more information.", caller)
    end
    
    options[:required] = method_required?(method) unless options.key?(:required)
    options[:as]     ||= default_input_type(method, options)

    html_class = [ options[:as], (options[:required] ? :required : :optional) ]
    html_class << 'error' if @object && @object.respond_to?(:errors) && !@object.errors[method.to_sym].blank?

    wrapper_html = options.delete(:wrapper_html) || {}
    wrapper_html[:id]  ||= generate_html_id(method)
    wrapper_html[:class] = (html_class << wrapper_html[:class]).flatten.compact.join(' ')
    (wrapper_html[:id] = (options.delete(:id_prefix) + "_" + wrapper_html[:id])) if options[:id_prefix]

    if options[:input_html] && options[:input_html][:id]
      options[:label_html] ||= {}
      options[:label_html][:for] ||= options[:input_html][:id]
    end

    input_parts = @@inline_order.dup
    input_parts = input_parts - [:errors, :hints] if options[:as] == :hidden

    list_item_content = input_parts.map do |type|
      send(:"inline_#{type}_for", method, options)
    end.compact.join("\n")

    list_item_content += (options[:extra_html] + "\n") if options[:extra_html]
    return template.content_tag(:li, list_item_content, wrapper_html)
  end
end
