module RepositoriesHelper
  def service_active?(cond)
    cond ? (cond.service_active? ? "service_active" : "service_inactive") : "service_inactive"
  end
end
