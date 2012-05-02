# A Visit is an event on a particular date, on which a specific
# customer should come to pick up or return items - or from the other perspective:
# when an inventory pool manager should hand over some items to or get them back from the customer.
#
# 'action' says if we want to have hand_overs or take_backs. action can be either of those two:
# * "hand_over"
# * "take_back"
#
# Reading a MySQL View
class Visit < ActiveRecord::Base
  # TODO define as readonly ??
  
  self.primary_key = :id
  
  belongs_to :user
  belongs_to :inventory_pool
  
  has_many :visit_lines
  has_many :contract_lines, :through => :visit_lines
  alias :lines :contract_lines

#  def line_ids
#    contract_line_ids.split(',').map(&:to_i)
#  end
#  def contract_lines
#    @contract_lines ||= ContractLine.includes(:model).find(line_ids)
#  end

  #######################################################
  
  scope :hand_over, lambda { where(:status_const => Contract::UNSIGNED) }
  scope :take_back, lambda { where(:status_const => Contract::SIGNED) }

  #######################################################

  def self.search2(query)
    return scoped unless query

    # TODO search on contract_lines' models and items
    sql = joins(:user)

    w = query.split.map do |x|
      s = []
      s << "CONCAT_WS(' ', users.login, users.firstname, users.lastname, users.badge_id) LIKE '%#{x}%'"
      "(%s)" % s.join(' OR ')
    end.join(' AND ')
    sql.where(w)
  end

  #######################################################

  # compares two objects in order to sort them
  # def <=>(other)
    # self.date <=> other.date
  # end  

  def is_overdue
    date < Date.today
  end

end
