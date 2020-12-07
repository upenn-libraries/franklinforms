class LocalRequest
  include ActiveModel::Model

  attr_accessor :type, :delivery_method, :comments
  attr_accessor :name, :email, :affiliation
  attr_accessor :user # TODO: how to handle proxy?

  attr_accessor :title, :section_title, :section_author, :section_pages
  attr_accessor :holding, :item

  REQUEST_TYPES = [:book, :scan]

  # @param [AlmaUser] user
  # @param [Object] params
  # @return [LocalRequest]
  def initialize(params, user)
    self.user = user
  end

  def submit
    # Submit via service
  end


end