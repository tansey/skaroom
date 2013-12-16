class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if update_resource(resource, params[resource_name])
      sign_in resource_name, self.resource, :bypass => true
      render json: resource, status: :ok
    else
      clean_up_passwords resource
      render json: resource, status: :not_acceptable
    end
  end
end