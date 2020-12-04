class LocalRequest
  include ActiveModel::Model

  attr_accessor :type, :delivery_method, :request_bib, :comments
  attr_accessor :name, :email, :affiliation
  attr_accessor :by, :for, :user # TODO: how to handle proxy?

  attr_accessor :title, :section_title, :section_author, :section_pages

  delegate :booktitle, :author, :edition, :publisher, :place,
           :year, :isbn, :source, :journal, :chaptitle,
           :rftdate, :volume, :issue, :pages, :article,
           to: :request_bib

  REQUEST_TYPES = [:book, :scan]

  # @param [AlmaUser] user
  # @param [Object] params
  # @return [LocalRequest]
  def initialize(params, user)
    self.user = user
    self.request_bib = RequestBib.new params
  end

  def submit
    # Submit via service
  end


end