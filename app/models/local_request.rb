class LocalRequest
  include ActiveModel::Model

  class RequestFailed < StandardError; end

  attr_accessor :delivery_method, :comments, :pickup_location
  attr_accessor :user, :requestor_email
  attr_accessor :section_title, :section_author, :section_pages, :section_volume, :section_issue
  attr_accessor :item_pid, :mms_id, :holding_id
  attr_accessor :confirmation

  attr_reader :status

  validates_presence_of :requestor_email, :delivery_method
  validates_presence_of :bib_item, message: I18n.t('forms.local_request.messages.bib_item_validation')
  validates_inclusion_of :delivery_method, in: :delivery_options, if: :bib_item_present?
  validates_presence_of :section_title, :section_author, if: :scandeliver_request?

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

  def identifiers
    { mms_id: mms_id, holding_id: holding_id, item_pid: item_pid }
  end

  # Get Item record from Alma based on accumulated identifiers
  # TODO: handle no item_pid case
  # @return [Alma::BibItem]
  def bib_item
    @bib_item ||= AlmaApiClient.new.find_item_for identifiers
  rescue StandardError => e
    raise ArgumentError, e.message
  end

  def requestor_affiliation
    user.organization
  end

  def requestor_name
    user.name
  end

  # @return [Symbol]
  def target_system
    if delivery_method.in? %w[booksbymail scandeliver]
      :illiad
    elsif delivery_method.in? %w[pickup]
      :alma
    end
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
      confirmation: confirmation,
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
    case delivery_method
    when 'booksbymail'
      # map data to old-style bib_data values
      bib_data = HashWithIndifferentAccess.new({
        proxied_for: user.id,
        author: bib_item['bib_data']['author'],
        booktitle: bib_item['bib_data']['title'],
        publisher: bib_item['bib_data']['publisher_const'],
        place: bib_item['bib_data']['place_of_publication'],
        rftdate: bib_item['bib_data']['date_of_publication'],
        year: bib_item['bib_data']['date_of_publication'],
        edition: bib_item['bib_data']['complete_edition'],
        isbn: bib_item['bib_data']['isbn'],
        pmid: nil, # TODO: this appears to never be set in Illiad.bib_data
        comments: comments,
      })
      Illiad.book_request_body user, bib_data, delivery_method
    when 'scandeliver'
      bib_data = HashWithIndifferentAccess.new({
        title: bib_item['bib_data']['title'],
        volume: section_volume,
        issue: section_issue,
        pmonth: '',
        rftdate: bib_item['bib_data']['date_of_publication'],
        year: '',
        pages: section_pages,
        issn: '',
        isbn: bib_item['bib_data']['isbn'],
        pmid: '',
        author: bib_item['bib_data']['author'],
        chaptitle: section_title,
        comments: comments,
        sid: ''
      })
      Illiad.scandelivery_request_body user, bib_data
    when 'pickup'
      Illiad.book_request_body user, to_h, delivery_method
    end
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
