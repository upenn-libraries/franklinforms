class BibRecord

  def initialize(bib_data)
    @bib_data = bib_data
  end

  def title
    return @bib_data['bib']['title']
  end

  def author
    return @bib_data['bib']['author']
  end

  def call_number
    cn = @bib_data['bib']['record']['datafield'].select {|k| k['tag'] == '050'}.first
    return cn['subfield'].reduce('') {|left,right| left + right['__content__']}
  end

  def bibid
    return @bib_data['bib']['mms_id']
  end
end
