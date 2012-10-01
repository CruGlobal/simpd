class HomeController < ApplicationController
	#	CAS railtie
	#before_filter RubyCAS::Filter
	before_filter :fake_cas

	def index
	end

	def login
		@user = User.new
	end

	def do_login
		@user = User.new(params[:user])

		if newuser = User.find_by_account_number(@user.account_number)
			session[:username] = @user.account_number
			redirect_to :action => :index
		else
			flash.now[:alert] = "No user has the account number: #{@user.account_number}"
			render :login
		end
	end

	def logout
		session[:username] = nil
		redirect_to :action => :index
	end

	def unauthorized
	end

	private
	def fake_cas
		if session[:username] == nil
			@sso = nil
		else
			@sso = User.find_by_account_number(session[:username])
		end
	end

	def admin_only
		if @sso.nil? or !@sso.is_admin
			render :partial => 'shared/unauthorized'
			return false
		end
		return true
	end

end