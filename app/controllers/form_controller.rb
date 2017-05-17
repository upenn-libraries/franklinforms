class FormController < ApplicationController
  include PreProcessor
  include PostProcessor

  def view
    #begin
      locals = pre_process(params[:id], params)
      render params[:id], locals: locals
    #rescue
      #render 'error'
    #end
  end

  def submit
    locals = pre_process(params[:id], params)
    post_process(params[:id], locals)
    render :confirmation
  end

end
