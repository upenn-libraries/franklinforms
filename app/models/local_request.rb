class LocalRequest
  include ActiveModel::Model

  attr_accessor :type, :delivery_method, :request_bib, :comments
  attr_accessor :name, :email, :affiliation
  attr_accessor :by, :for, :user # TODO: how to handle proxy?

  delegate :booktitle, :author, :edition, :publisher, :place,
           :year, :isbn, :source, :journal, :chaptitle,
           :rftdate, :volume, :issue, :pages, :article,
           to: :request_bib

  # TODO: are these different?
  REQUEST_TYPES =      [:pickup, :mail, :scan]
  REQUEST_FORM_TYPES = [:article, :book, :scan]

  # @param [User] user
  # @param [Object] params
  # @return [LocalRequest]
  def initialize(params, user)
    self.type = request_type_mapping params
    self.user = user
    self.request_bib = RequestBib.new params
  end

  def submit
    # Submit via service
  end

  # maps 'requesttype' values to more limited list
  def request_type_mapping(params)
    # prefer new style over old, while maintaining support
    type_param = params[:request_type] || params[:requesttype]
    case type_param&.to_sym
    when :ScanDelivery
      :scan
    when *REQUEST_FORM_TYPES
      type_param.to_sym
    else # default to book request form
      :book
    end
  end

  private

  def request_type_from_bib_params
    # Use the book request form for unknown genre types
    # TODO: do this is LocalRequest, or whatever
    # if (params['genre'].presence || params['rft.genre'].presence || '').downcase == 'unknown' then
    #   bib_data['requesttype'] = 'Book'
    # else
    #   bib_data['requesttype'] = params['genre'].presence || params['Type'].presence || params['requesttype'].presence || params['rft.genre'].presence || 'Article'
    #   bib_data['requesttype'] = 'Article' if bib_data['requesttype'] == 'issue'
    #   bib_data['requesttype'].sub!(/^(journal|bookitem|book|conference|article|preprint|proceeding).*?$/i, '\1')
    #   if ['article', 'book'].member?(bib_data['requesttype'])
    #     bib_data['requesttype'][0] = bib_data['requesttype'][0].upcase
    #   end
    # end
  end

  def comments_wat
    # bib_data['comments'] = params['UserId'].presence || params['comments'].presence || ''
  end

end