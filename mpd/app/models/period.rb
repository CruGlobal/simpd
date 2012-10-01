class Period < ActiveRecord::Base
  attr_accessible :end, :name, :start

	has_many :groups, :order => "name"
	has_many :teams, :order => "name"
	has_many :period_admins
	has_many :admins, :through => :period_admins, :source => :user, :order => "last_name, first_name"

	scope :active, lambda { where('(start is null or ? >= start) and (end is null or ? <= end)', Date.today, Date.today ) }
	scope :past, lambda { where('? > end', Date.today ) }
	scope :future, lambda { where('? < start', Date.today ) }

end