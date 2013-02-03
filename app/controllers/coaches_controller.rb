class CoachesController < HomeController
	
	# POST /groups/1/coaches
	def create
		@group = Group.find(params[:group_id])
		if !@group.can_edit_coaches?(@cas_user)
			render 'shared/unauthorized'
			return
		end
		
		if params[:add_coach].nil?
			flash.alert = 'Coach not added'
			redirect_to @group
			return
		end

		# Adding a new user
		if params[:add_coach][:new] == '1'
			if params[:add_coach][:account_number] =~ /^\s*(\d+)\s*$/
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
							'add_coach[new]' => '0',
							'add_coach[user_id]' => user.id
							)
						)
					return
				else
					user_id = user.id
					# Fall through to existing user
				end
			else
				flash.notice = 'Coach not added'
				redirect_to @group
				return
			end

		# Adding an existing user
		else
			user_id = $1 if params[:add_coach][:user_id] =~ /^(\d+)$/
		end

		if user_id.nil?
			flash.alert = 'No member selected'
		else
			@coach = @group.group_coaches.build(:user_id => user_id)

			if @coach.user.nil?
				flash.alert = 'No user found'
			elsif @group.coaches.select{ |u| u.id == @coach.user_id }.count > 0
				flash.notice = 'Coach already exists'
			elsif @coach.save
				flash.notice = 'Coach added'
			else
				flash.alert = 'Coach not added'
			end
		end

		redirect_to @group
	end

	# DELETE /coaches/1?return=url
	def destroy
		@coach = GroupCoach.find(params[:id])
		if !@coach.group.can_edit_coaches?(@cas_user)
			render 'shared/unauthorized'
			return
		end

		@coach.destroy

		if params[:return]
			redirect_to params[:return]
		else
			redirect_to @coach.group
		end
	end

end
