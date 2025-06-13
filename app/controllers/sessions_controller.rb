class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    user = User.find_by(email: session_params[:email])
    if user&.authenticate(session_params[:password])
      session[:user_id] = user.id
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Login successful!" }
        format.json { render json: { message: "Login successful!" }, status: :ok }
        format.any  { render json: { message: "Login successful!" }, status: :ok }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "Invalid e-mail or password."
          render :new, status: :unauthorized
        end
        format.json { render json: { error: "Invalid e-mail or password." }, status: :unauthorized }
        format.any  { render json: { error: "Invalid e-mail or password." }, status: :unauthorized }
      end
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logout successful!"
  end
end

private

def session_params
  params[:session] ? params.require(:session).permit(:email, :password) : params.permit(:email, :password)
end
