class LocalRequest
  include ActiveModel::Model

  attr_accessor :type, :delivery_method
  attr_accessor :name, :email, :affiliation
  attr_accessor :booktitle, :author, :edition, :publisher, :place,
                :year, :isbn, :source, :journal, :chaptitle,
                :rftdate, :volume, :issue, :pages, :comments

  REQUEST_TYPES = [:pickup, :mail, :scan]

  def initialize(params)
    self.type = params[:request_type].to_sym
  end

  def submit
    # Submit via appropriate service
  end

end