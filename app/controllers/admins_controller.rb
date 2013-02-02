class AdminsController < HomeController
	
	# POST /periods/1/admins
	def create
		@period = Period.find(params[:period_id])
		if !@period.can_edit_admins?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		if params[:add_admin].nil?
			flash.alert = 'Admin not added'
			redirect_to @period
			return
		end

		# Adding a new user
		if params[:add_admin][:new] == '1'
			if params[:add_admin][:account_number] =~ /^\s*(\d+)\s*$/
				if !user = User.find_by_account_number($1)
					user = User.new
					user.account_number = $1

					# TODO: Verify with sitrack

					user.save
					redirect_to(
						:controller => :users,
						:action => :confirm,
						:id => user.id,
						:continue => url_for(
							:action => :create,
							'add_admin[new]' => '0',
							'add_admin[user_id]' => user.id
							)
						)
					return
				else
					user_id = user.id
					# Fall through to existing user
				end
			else
				flash.notice = 'Admin not added'
				redirect_to @period
				return
			end

		# Adding an existing user
		else
			user_id = $1 if params[:add_admin][:user_id] =~ /^(\d+)$/
		end
			
		if user_id.nil?
			flash.alert = 'No member selected'
		else
			@admin = @period.period_admins.build(:user_id => user_id)

			if @admin.user.nil?
				flash.alert = 'No user found'
			elsif @period.admins.select{ |u| u.id == @admin.user_id}.count > 0
				flash.notice = 'Admin already exists'
			elsif @admin.save
				flash.notice = 'Admin added'
			else
				flash.alert = 'Admin not added'
			end
		end

		redirect_to @period
	end

	# DELETE /admins/1?return=url
	def destroy
		@admin = PeriodAdmin.find(params[:id])
		if !@admin.period.can_edit_admins?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@admin.destroy

		if params[:return]
			redirect_to params[:return]
		else
			redirect_to @admin.period
		end
	end

end
