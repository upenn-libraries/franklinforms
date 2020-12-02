class RequestBib

  # OpenURL case?
  attr_accessor :booktitle, :author, :edition, :publisher, :place,
                :year, :isbn, :source, :journal, :chaptitle,
                :rftdate, :volume, :issue, :pages, :article

  # Alma case
  attr_accessor :mms_id, :bib_id, :holding_id

  # @param [Object] params
  def initialize(params)
    @params = params
    author_last_name = value_at %w[rft.aulast aulast]
    self.author = if author_last_name
                    "#{author_last_name}#{params['rft.aufirst'].presence&.prepend(',')}"
                  else
                    value_at ['Author', 'author', 'aau', 'au', 'rft.au'], ''
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


    # TODO: what to do with these? they never appear in a form
    # bib_data['sid'] = params['sid'].presence || params['rfr_id'].presence || ''
    # bib_data['pid'] = params['pid'].presence || ''
    # bib_data['issn'] = params['issn'].presence || params['ISSN'].presence || params['rft.issn'].presence ||''
    # bib_data['pmonth'] = params['pmonth'].presence || params['rft.month'].presence ||''
    # bib_data['an'] = params['AN'].presence || ''
    # bib_data['py'] = params['PY'].presence || ''
    # bib_data['pb'] = params['PB'].presence || ''

    # Handles IDs coming like pmid:numbersgohere
    # unless params['rft_id'].presence.nil?
    #   parts = params['rft_id'].split(':')
    #   bib_data[parts[0]] = parts[1]
    # end

    # *** Relais/BD sends dates through as rft.date but it may be a book request ***
    # if(bib_data['sid'] == 'BD' && bib_data['requesttype'] == 'Book')
    #   bib_data['year'] = params['date'].presence || bib_data['rftdate']
    # end

    ## Lookup record in Alma on submit?

    # *** Make the bookitem booktitle the journal title ***
    # bib_data['journal'] = params['bookTitle'].presence || bib_data['journal'] if bib_data['requesttype'] == 'bookitem';

    # *** scan delivery uses journal title || book title, which ever we have ***
    # *** we should only have one of them ***
    # bib_data['title'] = bib_data['booktitle'].presence || bib_data['journal'].presence;

    # *** Make a non-inclusive page parameter ***
    # bib_data['spage'] = params['Spage'].presence || params['spage'].presence || params['rft.spage'].presence || '';
    # bib_data['epage'] = params['Epage'].presence || params['epage'].presence || params['rft.epage'].presence || '';

    # if(!params['Pages'].presence.nil? && bib_data['spage'].empty?)
    #   bib_data['spage'], bib_data['epage'] = params['Pages'].split(/-/);
    # end

    # if(params['pages'].presence.nil?)
    #   bib_data['pages'] = bib_data['spage'];
    #   bib_data['pages'] += "-#{bib_data['epage']}" unless bib_data['epage'].empty?
    # else
    #   bib_data['pages'] = params['pages'].presence
    # end

    # bib_data['pages'] = 'none specified' if bib_data['pages'].empty?

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
end