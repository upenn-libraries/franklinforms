class BibRecord

  def initialize(bib_data)
    @bib_data = bib_data || Hash.new
  end

  def title
    return @bib_data.dig('title')
  end

  def author
    return @bib_data.dig('author')
  end

  def call_number
    cn = @bib_data.dig('record','datafield')&.select {|k| k['tag'] == '050'}&.first
    return cn.dig('subfield').reduce('') {|left,right| left + right['__content__']} unless cn.nil?
  end

  def bibid
    return @bib_data.dig('mms_id')
  end
end
