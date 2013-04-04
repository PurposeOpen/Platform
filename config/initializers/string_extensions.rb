class String
  def html_linebreaks(force_https=false)
    linebreaks = self.gsub("\n", "<br/>")
    if force_https
      linebreaks = linebreaks.gsub(/src=(["'])?http/, "src=\\1https")
    end
    linebreaks
  end
  
  def is_numeric?
    true if Float(self) rescue false
  end
end
