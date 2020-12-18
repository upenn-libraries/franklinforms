class LocalRequest
  include ActiveModel::Model

  attr_accessor :delivery_method, :comments
  attr_accessor :user, :name, :email, :affiliation
  attr_accessor :section_title, :section_author, :section_pages
  attr_accessor :item_pid, :mms_id, :holding_id

  REQUEST_TYPES = [:book, :scan]

  # @param [Object] params
  # @param [AlmaUser] user
  # @return [LocalRequest]
  def initialize(user, params = {})
    self.user = user
    data = params[:local_request] || {}
    self.mms_id = data[:mms_id]
    self.email = data[:email]
    self.comments = data[:comments]
    self.delivery_method = data[:delivery_method]
    self.holding_id = data[:holding_id]
    self.item_pid = data[:item_pid]
    self.section_title = data[:section_title]
    self.section_author = data[:section_author]
    self.section_pages = data[:section_pages]
  end

  def submit
    # Submit via service
  end


end