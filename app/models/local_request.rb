class LocalRequest
  include ActiveModel::Model

  attr_accessor :name, :email, :affiliation, :delivery_method
  attr_accessor :booktitle, :author, :edition, :publisher, :place,
                :year, :isbn, :source

  def initialize(params)
    # TODO:
  end

end