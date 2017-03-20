class AlmaBib

  class << self

    bib_wadl = File.expand_path("../bib.wadl", __FILE__)
    @@bibs = EzWadl::Parser.parse(bib_wadl)[0].almaws_v1_bibs

    def apikey
      'l7xx4b67e6a2058742829425f1fad819871b'
    end

    def getBibRecord(bib_id)
      BibRecord.new(@@bibs.mms_id.get(query: { apikey: apikey, mms_id: bib_id, expand: 'p_avail' }))
    end

  end

end
