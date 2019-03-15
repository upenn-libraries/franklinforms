class FormController < ApplicationController
  include PreProcessor
  include PostProcessor

  def view
    begin
      locals = pre_process(params[:id], params)
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      redirect_to '/'
    else
      render params[:id], locals: locals unless performed?
    end
  end

  def submit
    locals = pre_process(params[:id], params)
    post_process(params[:id], locals)
    render :confirmation
  end

  def redir
    referrer_params = CGI.parse(URI.parse(request.referrer || '').query || '')
    mmsid = referrer_params['rft.mms_id'].first || referrer_params['mmsId'].first

    # Reference: https://stackoverflow.com/a/16623769
    uri = URI(request.original_url)
    query = URI.decode_www_form(uri.query || '')
    query << ['bibid', mmsid] if params['bibid'].nil? && mmsid.present?
    uri.query = URI.encode_www_form(query)
    uri.path = uri.path.sub /^\/[^\/]*\//, '/forms/'

    redirect_to uri.to_s
  end

  def aeon
    openurl_params = Aeon::getOpenUrlParams(params[:bibid])
    addl_params = Aeon::getAdditionalParams(params[:bibid], params[:hldid])
    redirect_to 'https://aeon.library.upenn.edu/OpenURL?' + openurl_params.merge(addl_params).to_query
  end

  def ares
    ares_params = params.to_unsafe_h
    ares_params['Value'] = ares_params['genre'] == 'book' ? 'IRFOpenURLBookChapter' : 'IRFOpenURLArticle'
    ares_params.delete('action')
    ares_params.delete('controller')
    redirect_to 'https://reserves.library.upenn.edu/ares/ares.dll/OpenURL?' + ares_params.to_query
  end

  def help
    locals = {referrer: request.referrer}
    render :help, locals: locals
  end

end
