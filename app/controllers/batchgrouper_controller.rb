class BatchgrouperController < ApplicationController
  respond_to :html, :json
  
  def index
    @batchgrouper = Batchgrouper.new()
  end
  
  def group
    @batchgrouper = Batchgrouper.new(params[:batchgrouper])
    respond_to do |format|
      if params[:batchgrouper][:file]
        format.json { render :json => { :result => "It worked!" }}
        send_file @batchgrouper.group
      else
        format.json { render :json => { :result => @batchgrouper.group_line(@batchgrouper.single_group) }}
      end
    end
  end
end
