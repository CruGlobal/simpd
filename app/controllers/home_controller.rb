class HomeController < ApplicationController

  # GET /
  def index
  end

  # GET /login
  def login
  end

  # POST /do_login
  def do_login
    if newuser = User.find_by_id(params[:login][:id])
      session[:user_id] = newuser.id
      redirect_to :action => :index
    else
      flash.now[:alert] = 'No user found'
      render :login
    end
  end

  # GET /logout
  def logout
    if Rails.env.production?
      RubyCAS::Filter.logout(self)
    else
      session[:user_id] = nil
      session[:sudo_id] = nil
      redirect_to :action => :index
    end
  end

  # POST /full_update
  def full_update
    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end

    # Manually perform system-wide data update
    Sitrack.update_all
    redirect_to :back
  end

  # POST /view_user
  def view_user
    # Only admins can see this tool, but it just redirects to a user's page, so we don't need to check security
    if !params[:view_user] or !user = User.find_by_id(params[:view_user][:id])
      render 'shared/not_found'
      return
    end

    redirect_to user
  end

  # GET /list
  # POST /list
  def list
    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end

    @list_title = "SIMPD Complete List"
    @list_type = 'complete'
    @fields = params[:fields]
    if !@fields
      @fields = Hash.new
      @fields[:account_number] = '1'
      @fields[:guid] = '1'
      @fields[:roles] = '1'
      @fields[:last_login] = '1'
      @fields[:real_user] = '1'
    end

    @users = User.all.sort_by{|u| u.sort_name}

    if params[:commit] == 'Download Excel'
      render 'list.xml', :content_type => 'application/xls'
      return
    end

    if params[:commit] == 'Clear'
      # Clear selections
      @fields = Hash.new
    end

    render :layout => 'list'
  end

  # GET /backdoor?code=[action]
  #
  # Ok, so it's not really a backdoor
  def backdoor
    if !current_user.is_admin?
      render 'shared/forbidden'
      return
    end

    flash.alert = 'What were you trying to do?'

    if params[:code] == 'delete_everything'
      # Delete all periods but #1 and all users but #1-#3
      # Replicates a db:migrate:redo, db:seed
      for p in Period.all
        if p.id != 1
          p.destroy # And all child objects
        end
      end
      for u in User.all
        if u.id > 3
          u.destroy # And all child objects
        end
      end

      flash.alert = 'Deleted everything'
    end

    if params[:code] == 'remove_duplicate_admins'
      # Fixes a bug that I introduced where all coaches were being added as admins
      for p in Period.all
        uniq_admins = p.admins.uniq
        for pa in p.period_admins
          pa.destroy
        end
        for user in uniq_admins
          p.period_admins.build(:user_id => user.id)
        end
        p.save
      end

      flash.alert = 'Removed duplicate admins'
    end

    redirect_to root_path
  end

  def not_found
    if params[:format].blank? or params[:format] == 'html'
      render 'shared/not_found', :status => :not_found
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
