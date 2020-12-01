class RequestBib

  # OpenURL case?
  attr_accessor :booktitle, :author, :edition, :publisher, :place,
                :year, :isbn, :source, :journal, :chaptitle,
                :rftdate, :volume, :issue, :pages, :article

  # Alma case
  attr_accessor :mms_id, :bib_id, :holding_id

  # @param [Object] params
  def initialize(params)
    author_last_name = params['rft.aulast'].presence || params['aulast'].presence || nil
    self.author = if author_last_name
                    "#{author_last_name}#{params['rft.aufirst'].presence&.prepend(',')}"
                  else
                    params['Author'].presence || params['author'].presence || params['aau'].presence ||
                        params['au'].presence || params['rft.au'].presence || bib_data['author'].presence || ''
                  end
    self.chaptitle = params['chaptitle'].presence
    self.booktitle = params['title'].presence || params['Book'].presence || params['bookTitle'].presence || params['booktitle'].presence || params['rft.title'].presence || ''
    self.edition = params['edition'].presence || params['rft.edition'].presence || ''
    self.publisher = params['publisher'].presence || params['Publisher'].presence || params['rft.pub'].presence   || ''
    self.place = params['place'].presence || params['PubliPlace'].presence || params['rft.place'].presence || ''
    self.journal = params['Journal'].presence || params['journal'].presence || params['rft.btitle'].presence || params['rft.jtitle'].presence || params['rft.title'].presence || params['title'].presence || ''
    self.article = params['Article'].presence || params['article'].presence || params['atitle'].presence || params['rft.atitle'].presence || ''
    self.rftdate = params['rftdate'].presence || params['rft.date'].presence
    self.year = params['Year'].presence || params['year'].presence || params['rft.year'] || params['rft.pubyear'].presence || params['rft.pubdate'].presence
    self.volume = params['Volume'].presence || params['volume'].presence || params['rft.volume'].presence || ''
    self.issue = params['Issue'].presence || params['issue'].presence || params['rft.issue'].presence || ''
    self.isbn = params['isbn'].presence || params['ISBN'].presence || params['rft.isbn'].presence || ''
    self.source = params['source'].presence || 'direct'
    self.bib_id = params['record_id'].presence || params['id'].presence || params['bibid'].presence || ''


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
end