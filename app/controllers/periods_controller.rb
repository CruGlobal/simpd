class PeriodsController < HomeController

  # GET /periods/1
  def show
    @period = Period.find(params[:id])
		if !@period.can_view?(@sso)
			render 'shared/unauthorized'
			return
		end

		@new_group = Group.new
		@new_group.period = @period
		
		@new_team = Team.new
		@new_team.period = @period
		
		@new_admin = PeriodAdmin.new
		@new_admin.period = @period
  end

	# GET /periods/1/show_fields
	def show_fields
		@period = Period.find(params[:id])
		if !@period.can_view?(@sso)
			render 'shared/unauthorized'
			return
		end
	end

	# POST /periods/1/update_fields
	def update_fields
		@period = Period.find(params[:id])
		if !@period.can_edit?(@sso)
			render 'shared/unauthorized'
			return
		end

		flash.notice = params.inspect

		redirect_to :action => :show_fields, :id => params[:id]
	end

	# GET /periods/1/list
	def list
		@period = Period.find(params[:id])
		if !@period.can_view?(@sso)
			render 'shared/unauthorized'
			return
		end

		@assignments = @period.assignments
		@fields = params[:fields] || Hash.new
		@sort = params[:sort] || Hash.new

		if params[:commit] == 'Download Excel'
			@title = "#{@period.name} Complete List"
			render "list/show.xls", :content_type => "application/xls"
			return
		end

		respond_to do |format|
			format.html
			format.csv do
				CSV.generate do |csv|
				end
			end
			format.xls
		end
	end

end