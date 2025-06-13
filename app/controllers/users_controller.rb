class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      respond_to do |format|
        format.json { render json: @user, status: :created }
        format.any  { render json: @user, status: :created }
        format.html { redirect_to root_path, notice: "Registration completed successfully!" }
      end
    else
      respond_to do |format|
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.any  { render json: @user.errors, status: :unprocessable_entity }
        format.html { render :new }
      end
    end
  end

  private

  def user_params
    params[:user] ? params.require(:user).permit(:name, :email, :password) : params.permit(:name, :email, :password)
  end
end
