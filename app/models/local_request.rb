class LocalRequest
  include ActiveModel::Model

  attr_accessor :type, :delivery_method
  attr_accessor :name, :email, :affiliation
  # attr_accessor :by, :for, :user, # TODO: how to handle proxy?
  attr_accessor :booktitle, :author, :edition, :publisher, :place,
                :year, :isbn, :source, :journal, :chaptitle,
                :rftdate, :volume, :issue, :pages, :comments, :article

  REQUEST_TYPES = [:pickup, :mail, :scan]

  # @param [User] user
  # @param [Object] params
  # @return [LocalRequest]
  def initialize(params, user)
    self.type = params[:request_type].to_sym
    self.user = user
  end

  def submit
    # Submit via appropriate service
  end

end