class LocalRequest
  include ActiveModel::Model

  class RequestFailed < StandardError; end

  attr_accessor :delivery_method, :comments, :pickup_location
  attr_accessor :user, :requestor_email
  attr_accessor :section_title, :section_author, :section_pages, :section_volume, :section_issue
  attr_accessor :item_pid, :mms_id, :holding_id
  attr_accessor :bib_item, :confirmation
  attr_reader :status

  validates_presence_of :requestor_email, :delivery_method
  validates_inclusion_of :delivery_method, in: :delivery_options, if: :bib_item_present?
  with_options if: :scandeliver_request? do
    validates_presence_of :section_title, :section_author
  end

  # @param [AlmaUser] user
  # @param [Object] params
  # @return [LocalRequest]
  def initialize(user, params = {})
    self.user = user
    data = params[:local_request] || params
    self.mms_id = data[:mms_id]
    self.requestor_email = data[:requestor_email]
    self.comments = data[:comments]
    # NOTE: In COVID times, pickup location is always VanP
    # self.pickup_location = data[:pickup_location] || 'VanPeltLib'
    self.pickup_location = 'VanPeltLib'
    self.delivery_method = data[:delivery_method]
    self.holding_id = data[:holding_id]
    self.item_pid = data[:item_pid]
    self.section_title = data[:section_title]
    self.section_author = data[:section_author]
    self.section_pages = data[:section_pages]
    self.section_volume = data[:section_volume]
    self.section_issue = data[:section_issue]
  end

  def requestor_affiliation
    user.organization
  end

  def requestor_name
    user.name
  end

  # @return [TrueClass, String, nil]
  def submit
    confirmation = if delivery_method == 'pickup'
                     # AlmaApiClient.new.create_item_request self # raises exception on error
                     puts "Submitted to Alma: #{self}"
                     'alma1234'
                   else
                     # IlliadApiClient.new.transaction self.for_illiad # raises exception on error
                     puts "Submitted to ILLiad: #{self.for_illiad}"
                     'ill5678'
                   end
    self.confirmation = confirmation
  rescue StandardError => e
    raise RequestFailed, e.message
  end

  # @return [Hash{Symbol->String}]
  def to_h
    data = {
      requestor_name: requestor_name,
      requestor_email: requestor_email,
      requestor_affiliation: requestor_affiliation,
      mms_id: mms_id,
      holding_id: holding_id,
      item_pid: item_pid,
      delivery_method: delivery_method,
      pickup_location: pickup_location,
      comments: comments,
      status: status,
      has_errors: errors.any?
    }
    if scandeliver_request?
      data.merge!({
        section_title: section_title,
        section_author: section_author,
        section_pages: section_pages,
        section_volume: section_volume,
        section_issue: section_issue
      })
    end
    data
  end

  def for_illiad
    # TODO: hash for use by ILL API method
    to_h
  end

  # @return [TrueClass, FalseClass]
  def scandeliver_request?
    delivery_method == 'scandeliver'
  end

  private

  def bib_item_present?
    self.bib_item.present?
  end

  def delivery_options
    self.bib_item.delivery_options.map(&:to_s)
  end
end