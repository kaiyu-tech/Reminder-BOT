class UsersController < ApplicationController
  before_action :connected_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    users = current_user_admin? ? User.all : User.where(id: current_user_id)
    @users = users.order(:created_at).paginate(page: params[:page])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Successfully updated."
      redirect_to edit_user_url(@user)
    else
      flash.now[:danger] = "Failed to update."
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    unless user.admin?
      user.destroy
      flash[:success] = "Successfully deleted."
      if current_user_admin?
        redirect_to users_url
      else
        redirect_to destroy_sessions_url(type: :close)
      end
    else
      flash[:danger] = "Incorrect operation."
      redirect_to destroy_sessions_url(type: :operation)
    end
  end

  private

    def user_params
      if current_user_admin? && not(@user.admin?)
        user = params.require(:user).permit(:activate, :notify_token, :expires_in)
      else
        user = params.require(:user).permit(:notify_token)
      end

      notify_token = user.delete(:notify_token)
      user[:notify_token_encrypt] = User.encrypt(notify_token)

      user
    end

    def connected_user
      unless connected?
        flash[:danger] = "Invalid session."
        redirect_to destroy_sessions_url(type: :session)
      end
    end

    def correct_user
      unless current_user_id?(params[:id].to_i) || current_user_admin?
        flash[:danger] = "Invalid session."
        redirect_to destroy_sessions_url(type: :session)
      end;
    end
end
