
class BibRecord

  attr_accessor :data

  def initialize(bib_data)
    @data = bib_data || Hash.new
  end

  def title
    return @data.dig('title')
  end

  def author
    return @data.dig('author')
  end

  def call_number
    cn = @data.dig('record','datafield')&.select {|k| k['tag'] == '050'}&.first
    return [cn.dig('subfield')].flatten.reduce('') {|left,right| left + right['__content__']} unless cn.nil?
  end

  def bibid
    return @data.dig('mms_id')
  end
end
