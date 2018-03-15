class Aeon

  @locCodeMap = {'KislakCntr' => 'KISLAK',
                 'KatzLib' => 'KATZ',
                 'FisherFAL' => 'FISHER'
  }

  @sublocNameMap = {
    'finecage' => 'Fine Arts Cage',
    'finelock' => 'Fine Locked Case',
    'finemaps' => 'Fine Map Coll.',
    'finerare' => 'Fine Rare Book',
    'fineraremp' => 'Fine Rare Maps',
    'finerarept' => 'Fine Rare Print',
    'cjsraram' => 'RB Americana',
    'cjsambx' => 'Arc Americana',
    'cjsmar' => 'Margolis',
    'cjsrar' => 'RB Room',
    'cjsspec' => 'Special',
    'cjsths' => 'Stacks Thesis',
    'cjsmemor' => 'Memorial',
    'cjsrarfol' => 'RB Folio',
    'cjsrarover' => 'RB Oversize',
    'cjsrargiga' => 'RB Giant',
    'cjsrarmini' => 'RB Miniature',
    'cjsincun' => 'RB Incunabula',
    'cjsrarms' => 'RB Ms.',
    'cjsgf' => 'Genizah',
    'cjsartif' => 'Artifacts',
    'cjsarc' => 'Arc Room',
    'cjsarcms' => 'Arc Room Ms.',
    'cjsgrc' => 'Arc Graphics',
    'cjsrarbx1' => 'RB Box 1',
    'cjsrarbx2' => 'RB Box 2',
    'cjsrarbx3' => 'RB Box 3',
    'cjsrarbx4' => 'RB Box 4',
    'cjsarcbox1' => 'Arc Box 1',
    'cjsarcths' => 'Arc Thesis',
    'cjshur' => 'Hurowitz',
    'scsmith' => 'Smith',
    'scfurn' => 'Furness',
    'sclea' => 'Lea',
    'scrare' => 'RBC',
    'screfe' => 'Reference',
    'sccurt' => 'Curtis',
    'scdech' => 'Dechert',
    'scelz' => 'Elzevier',
    'scforr' => 'Forrest',
    'scfoun' => 'Founders',
    'scinc' => 'Incunables',
    'scmss' => 'Manuscripts',
    'scpspa' => 'PSPA',
    'scsing' => 'Singer-Mendenhall',
    'scteer' => 'Teerink',
    'scyarn' => 'Yarnall',
    'scwhit' => 'Whitman',
    'newbrare' => 'Fairman-Rogers',
    'storlimit' => 'LIBRA Limited',
    'storrare' => 'LIBRA Rare',
    'storspec' => 'LIBRA Special',
    'scmst' => 'Ms. Storage',
    'scfreed' => 'Freedman',
    'scfast' => 'Fast LIBRA',
    'scstor' => 'RBC Storage',
    'sc1100c' => '1100c LIBRA',
    'scsmithst' => 'Smith Storage LIBRA',
    'scfurnst' => 'Furness Storage LIBRA',
    'scdreis' => 'Dreiser LIBRA',
    'scelias' => 'Swift Reading',
    'scparts' => 'Books in Parts',
    'scdrey' => 'Dreyfus',
    'scbyron' => 'Byron',
    'sccomics' => 'Comics',
    'scblank' => 'Blank',
    'screfestor' => 'Ref Storage',
    'screading' => 'Reading Room Ref',
    'scgull' => 'Gulliver',
    'scg123' => 'scg123',
    'scmap' => 'scmap',
    'scmsw' => 'scmsw',
    'scdethou' => 'De Thou',
    'sccanvas' => 'Canvassing',
    'scvilain' => 'Vilain-Wieck',
    'scschimmel' => 'Schimmel',
    'sctehon' => 'Tehon',
    'scadams' => 'Adams',
    'scartbk' => 'Artists',
    'musebrin' => 'Museum Brinton',
    'muselock' => 'Museum Locked'
  }

  def self.getOpenUrlParams(mmsid)

    url = "https://upenn.alma.exlibrisgroup.com/view/uresolver/01UPENN_INST/openurl?rft.mms_id=#{mmsid}&svc_dat=CTO"
    #param_map = {'rft.format' => 'format', 'rft.au' => 'au', 'rft.creator' => 'creator', 'rft.title' => 'title', 'rft.edition' => 'edition', 'rft.place' => 'place', 'rft.pub' => 'pub', 'rft.date' => 'date', 'rft.isbn' => 'isbn', 'rft.issn' => 'issn', 'rft.identifier' => 'ReferenceNumber'}
    #result = {'format' => '', 'au' => '', 'creator' => '', 'title' => '', 'edition' => '', 'place' => '', 'pub' => '', 'date' => '', 'isbn' => '', 'issn' => '', 'ReferenceNumber' => ''};
    result = {'rft.format' => '', 'rft.au' => '', 'rft.genre' => '', 'rft.creator' => '', 'rft.title' => '', 'rft.edition' => '', 'rft.place' => '', 'rft.pub' => '', 'rft.date' => '', 'rft.isbn' => '', 'rft.issn' => ''};

    open(url) { |f|
      xml = Nokogiri::XML(f.read).remove_namespaces!
      xml.xpath('//context_object/keys/key').each { |k| 
       #result[param_map[k.values.first]] &&= k.children.text
       result[k.values.first] &&= k.children.text
      }
    }

    result
  end

  def self.getAdditionalParams(mmsid, hldid)

    result = Alma::Bib.resources.almaws_v1_bibs.mms_id.get(Alma::Bib.query_merge(mms_id: mmsid))
    xml = Nokogiri::XML(result.to_xml)

    addl_params = {}
    addl_params['ItemIssue'] = xml.xpath(".//datafield[tag=773]/subfield/subfield[code='g']/__content__/text()").to_s

    result = Alma::Bib.resources.almaws_v1_bibs.mms_id_holdings_holding_id.get(Alma::Bib.query_merge(mms_id: mmsid, holding_id: hldid))
    xml = Nokogiri::XML(result.to_xml)

    addl_params['CallNumber'] = ['k','h','i','j','l','m'].map { |code|
      xml.xpath(".//datafield[tag=852]/subfield/subfield[code='#{code}']/__content__/text()")
    } .flatten.compact.join(' ')

    addl_params['Location'] = xml.xpath(".//datafield[tag=852]/subfield/subfield[code='c']/__content__/text()").to_s
    addl_params['SubLocation'] = @sublocNameMap[addl_params['Location']]
    addl_params['Site'] = @locCodeMap[xml.xpath(".//datafield[tag=852]/subfield/subfield[code='b']/__content__/text()").to_s]
    addl_params['ReferenceNumber'] = mmsid

    #addl_params['CallNumber'] = result.dig 'items', 'item', 'holding_data', 'call_number'
    #addl_params['Location'] = result.dig 'items', 'item', 'item_data', 'location', '__content__'
    #addl_params['SubLocation'] = result.dig 'items', 'item', 'item_data', 'location', 'desc'
    #addl_params['Site'] = result.dig 'items', 'item', 'item_data', 'library', '__content__'
    #addl_params['ItemNumber'] = result.dig 'items', 'item', 'item_data', 'barcode'
    #addl_params['ReferenceNumber'] = result.dig 'items', 'item', 'bib_data', 'mms_id'

    result = Alma::Bib.resources.almaws_v1_bibs.mms_id_holdings_holding_id_items.get(Alma::Bib.query_merge(mms_id: mmsid, holding_id: hldid))
    xml = Nokogiri::XML(result.to_xml)

    addl_params['ItemNumber'] = xml.xpath(".//item-data/barcode/text()").map(&:to_s).join(', ')
    addl_params['ItemISxN'] = xml.xpath(".//item-data/inventory-number/text()").map(&:to_s).join(', ')

    addl_params
  end
end
