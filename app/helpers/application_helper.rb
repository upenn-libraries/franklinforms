module ApplicationHelper
  # @param [Hash] record
  # @return [TrueClass, FalseClass]
  def article_request?(record)
    request_type(record) == 'article'
  end

  # @param [Hash] record
  # @return [TrueClass, FalseClass]
  def book_request?(record)
    request_type(record) == 'book'
  end

  # @return [TrueClass, FalseClass]
  def borrowdirect_request?
    params[:bd] == 'true'
  end

  # @param [Hash] record
  # @return [TrueClass, FalseClass]
  def scandelivery_request?(record)
    request_type(record) == 'scandelivery'
  end

  # @return [TrueClass, FalseClass]
  def explicit_bbm?
    params[:deliverytype] == 'bbm'
  end


  # Check record for the requesttype value, case insensitive
  # @param [Hash] record
  def request_type(record)
    record['requesttype']&.downcase
  end
end
