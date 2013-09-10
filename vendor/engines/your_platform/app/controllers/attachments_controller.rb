class AttachmentsController < ApplicationController
  
  load_and_authorize_resource
  
  def index
  end

  def create
    #@attachment = Attachment.new(params[:attachment])
    #@attachment.save
    @attachment = Attachment.create
    @attachment.update_attributes(params[:attachment])
  end


  # PUT /attachments/1
  # PUT /attachments/1.json
  def update
    @attachment = Attachment.find(params[:id])

    respond_to do |format|
      if @attachment.update_attributes(params[:attachment])
        format.html { redirect_to @attachment, notice: 'Attachment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
  end

  # This action allows to download a file, which is not in the public/ directory
  # but at a secured location. That way, access control for uploaded files cannot
  # be circumvented by downloading files directly from the public folder.
  #
  # https://github.com/carrierwaveuploader/carrierwave/wiki/How-To%3A-Secure-Upload
  #
  def download
    path = ""
    if params[:version]
      if @attachment.file.versions[params[:version].to_sym]
        path = @attachment.file.versions[params[:version].to_sym].current_path
      end
    else
      path = @attachment.file.current_path
    end
    send_file path, x_sendfile: true
  end

end
