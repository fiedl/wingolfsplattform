class WingolfsblaetterController < ApplicationController
  
  def index
    authorize! :index, :wingolfsblaetter_dashboard
    
    @global_officers = Group.find_by_flag(:global_officers)
    @issues_count = Issue.unresolved.count
    @abonnenten = Group.find_by_flag :wbl_abo
    @eisenberg = User.where(last_name: "Eisenberg", first_name: "Reinke").first
    @statistics_preset = 'aktivitates_join_and_persist_statistics'
    @philister = Group.alle_philister

    @wbl_page = Page.where(title: "Wingolfsblätter").first
    @wbl_blog_post = @wbl_page.blog_entries.reorder(:created_at).last
    if @wbl_blog_post.attachments.count >= 4
      @last_year = @wbl_blog_post.title.match(/20[0-9][0-9]/)[0]
      @new_year = (@last_year.to_i + 1).to_s
      @wbl_blog_post = @wbl_page.blog_entries.create
      @wbl_blog_post.title = "Wingolfsblätter #{@new_year}"
      @wbl_blog_post.content = "Wingolfsblätter des Jahres #{@new_year}."
      @wbl_blog_post.save
    end
    
    set_current_title I18n.t(:wingolfsblaetter)
  end
  
end