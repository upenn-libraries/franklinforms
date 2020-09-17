module ApplicationHelper
  def application_name
    'Franklin'
  end

  def flash_class(level)
    case level
    when :notice then 'alert alert-info'
    when :success then 'alert alert-success'
    when :error then 'alert alert-error'
    when :alert then 'alert alert-error'
    else
      'alert alert-warning'
    end
  end
end
