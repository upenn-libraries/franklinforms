module ApplicationHelper
  # @param [Hash] record
  def article_request?(record)
    request_type(record) == 'article'
  end

  # @param [Hash] record
  def book_request?(record)
    request_type(record) == 'book'
  end

  # @param [Hash] record
  def scandelivery_request?(record)
    request_type(record) == 'scandelivery'
  end

  def explicit_bbm?
    params[:deliverytype] == 'bbm'
  end

  # Check record for the requesttype value, case insensitive
  # @param [Hash] record
  def request_type(record)
    record['requesttype']&.downcase
  end
end
