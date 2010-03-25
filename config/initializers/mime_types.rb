# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register 'text/plain', :diff

CSS_CLASSES = {}
%w(.rb).each { |e| CSS_CLASSES[e] = :script }
%w(.png .jpg .jpeg .gif .ico ).each { |e| CSS_CLASSES[e] = :image }

