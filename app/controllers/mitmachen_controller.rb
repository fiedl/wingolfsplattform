class MitmachenController < ApplicationController

  def index
    authorize! :use, :mitmachen
    set_current_title "Mitmachen"
  end

  def create
    authorize! :use, :mitmachen

    ActionMailer::Base.mail(to: BaseMailer.default_params[:from], subject: "Mitmachen", body: params.to_s).deliver
  end

end