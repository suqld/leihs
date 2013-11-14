class Manage::VisitsController < Manage::ApplicationController
    
  def index
    @visits = Visit.filter params, current_inventory_pool
    set_pagination_header(@visits) unless params[:paginate] == "false"
  end

  def destroy
    visit = current_inventory_pool.visits.hand_over.find params[:visit_id]
    unless visit.blank?
      contract = visit.user.get_unsubmitted_contract(current_inventory_pool)
      contract.remove_lines(visit.lines, current_user.id)
    end
    render :status => :no_content, :nothing => true
  end
end
