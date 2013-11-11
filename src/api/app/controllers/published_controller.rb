class PublishedController < ApplicationController

  def index
    valid_http_methods :get, :post

    prj = Project.get_by_name(params[:project]) if params[:project]

    if prj 
      # This is no security feature as documented
      if prj.disabled_for?('binarydownload', params[:repository], params[:arch]) and not @http_user.can_download_binaries?(prj)
        render_error :status => 403, :errorcode => "download_binary_no_permission",
        :message => "No permission for binaries from project #{params[:project]}"
        return
      end
      pass_to_backend
      return
    end

    reqpath = request.path
    reqpath.slice!(0, root_path.length-1) if reqpath.start_with?(root_path)
    answer = Suse::Backend.get(reqpath)
    data=REXML::Document.new(answer.body.to_s)
    if answer
      render :text => data.to_s, :content_type => "text/xml"
    end
  end
end
