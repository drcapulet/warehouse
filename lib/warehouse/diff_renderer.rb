class Warehouse::DiffRenderer < Diff::Renderer::Base
  def render(data)
    @counter = [0, 0]
    super
  end
  
  def headerline(line)
  end

  def unmodline(line)
    row nil, line
  end

  def remline(line)
    row :delete, line
  end
  
  def addline(line)
    row :insert, line
  end

protected
  def row(css_class, line)
    line.gsub!(/&/n,  '&amp;')
    line.gsub!(/\"/n, '&quot;')
    line.gsub!(/>/n,  '&gt;')
    line.gsub!(/</n,  '&lt;')
    line.gsub!(/ /,   "&nbsp;")
    %(<tr><td class="ln">#{line.old_number || "&nbsp;"}</td><td class="ln">#{line.new_number || "&nbsp;"}</td><td class="code#{css_class ? " #{css_class}" : nil}">&nbsp;#{line}</td></tr>)
  end
end