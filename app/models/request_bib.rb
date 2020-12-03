class RequestBib

  # Form fields
  attr_accessor :booktitle, :author, :edition, :publisher, :place,
                :year, :isbn, :source, :journal, :chaptitle,
                :rftdate, :volume, :issue, :pages, :article

  # Other OpenURL fields?
  attr_accessor :pmonth, :sid, :spage, :epage, :pages, :issn, :title

  # Alma case
  attr_accessor :mms_id, :bib_id, :holding_id

  # Take raw OpenURL or whatever params and build a RequestBib object
  # TODO: build object from an Alma::Bib??
  # @param [Object] params
  def initialize(params)
    @params = params
    author_last_name = value_at %w[rft.aulast aulast]
    self.author = if author_last_name
                    "#{author_last_name}#{params['rft.aufirst'].presence&.prepend(',')}"
                  else
                    value_at %w[Author author aau au rft.au], ''
                  end
    self.chaptitle = value_at 'chaptitle'
    self.booktitle = value_at %w[title Book bookTitle booktitle rft.title], ''
    self.edition = value_at %w[edition rft.edition], ''
    self.publisher = value_at %w[publisher Publisher rft.pub], ''
    self.place = value_at %w[place PubliPlace rft.place], ''
    self.journal = value_at %w[Journal journal rft.btitle rft.jtitle rft.title title], ''
    self.article = value_at %w[Article article atitle rft.atitle], ''
    self.rftdate = value_at %w[rftdate rft.date]
    self.year = value_at %w[Year year rft.year rft.pubyear rft.pubdate]
    self.volume = value_at %w[Volume volume rft.volume], ''
    self.issue = value_at %w[Issue issue rft.issue], ''
    self.isbn = value_at %w[isbn ISBN rft.isbn], ''
    self.source = value_at 'source', 'direct'

    self.bib_id = value_at %w[record_id id bibid], ''

    # Not in forms but used elsewhere
    self.pmonth = value_at %w[pmonth rft.month], ''
    self.sid = value_at %w[sid rfr_id], ''
    self.issn = value_at %w[issn ISSN rft.issn], ''

    # Handles IDs coming like pmid:numbersgohere
    # TODO: test
    if params['rft_id']
      parts = params['rft_id'].split(':')
      self.send parts[0], parts[1]
    end

    # Relais/BD sends dates through as rft.date but it may be a book request
    # TODO: wat
    if sid == 'BD' && params['requesttype'] == 'Book'
      self.year = params['date'].presence || rftdate
    end

    # Make the bookitem booktitle the journal title
    # TODO: wat
    self.journal ||= params['bookTitle'].presence  if params['requesttype'] == 'bookitem'

    # scan delivery uses journal title or book title, which ever we have
    # we should only have one of them
    self.title = booktitle || journal

    # PAGE HANDLING

    # Make a non-inclusive page parameter
    self.spage = value_at %w[Spage spage rft.spage], '';
    self.epage = value_at %w[Epage epage rft.epage], '';

    # look at the subtlety between 'Pages' versus 'pages' param handling
    # TODO: why so picky? different sources? try and make this clear
    # this seems...optimistic
    if params['Pages'] && spage.empty?
      page_range = params['Pages'].split(/-/)
      self.spage = page_range[0]
      self.epage = page_range[1]
    end

    if params['pages'].blank?
      self.pages = spage
      self.pages += "-#{epage}" if epage.present?
    else
      self.pages = params['pages'].presence
    end

    self.pages = 'none specified' if pages.empty?


    # TODO: what to do with these? they never appear in a form or elsewhere in code
    # bib_data['an'] = params['AN'].presence || '' # never referenced elsewhere
    # bib_data['py'] = params['PY'].presence || '' # never referenced elsewhere
    # bib_data['pb'] = params['PB'].presence || '' # never referenced elsewhere
    # bib_data['pid'] = params['pid'].presence || '' # never referenced elsewhere

    ## Lookup record in Alma on submit? # wat why?
  end

  # return the @params value from keys (preference descending order)
  # or the default
  # @param [String, Array<String>] preferred_keys
  # @return [String]
  def value_at(preferred_keys, default = nil)
    values = Array.wrap(preferred_keys).reverse.map do |key|
      @params.dig key
    end
    values.compact.pop || default
  end

  # nice to have
  def to_h
    values_hash = HashWithIndifferentAccess.new
    instance_variables.each do |var|
      values_hash[var[1..-1]] = self.instance_variable_get var
    end
    values_hash
  end
end