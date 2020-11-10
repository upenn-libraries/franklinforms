module ApplicationHelper
  def article_request?
    request_type == 'article'
  end

  def book_request?
    request_type == 'book'
  end

  def scandelivery_request?
    request_type == 'scandelivery'
  end

  def explicit_bbm?
    params[:deliverytype] == 'bbm'
  end

  def request_type
    params[:requesttype]&.downcase
  end
end
