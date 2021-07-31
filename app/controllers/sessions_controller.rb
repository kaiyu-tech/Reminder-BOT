require 'net/http'
require 'uri'
require 'json'

class SessionsController < ApplicationController

  def new
    disconnect
    render 'new', locals: { message: "Loading ..." }
  end

  def create
    user = User.search(line_id(params[:id_token]))

    if Rails.env.development?
      params[:all] = 'true'
      user = User.search(line_id("id_token_admin"))
      # user = User.search(line_id("id_token_user_1"))
    end

    if user&.activate?
      connect(user.id, params[:all])
      render :json => {'url' => events_url}
    else
      flash[:danger] = "Invalid user."
      render :json => {'url' => destroy_sessions_url(type: :login)}
    end
  end

  def destroy
    disconnect

    type = params[:type]
    if type == 'close'
      message = "Please close window."
    elsif type == 'session'
      message = "Please connect."
    elsif type == 'login'
      message = "Please register."
    elsif type == 'operation'
      message = "An incorrect operation has been detected."
    else
      message = "Unkown error."
    end

    render 'sessions/terminate', locals: { type: type, message: message }
  end

  private

    def line_id(id_token)
      unless Rails.env.production?
        line_id_hash = { "id_token_admin" => "line_id_admin",
                        "id_token_user_1" => "line_id_user_1",
                        "id_token_user_2" => "line_id_user_2",
                        "id_token_user_3" => "line_id_user_3",
                        "id_token_user_4" => "line_id_user_4",
                        "id_token_user_5" => "line_id_user_5",
                        "id_token_user_10" => "line_id_user_10",
                        "id_token_user_20" => "line_id_user_20",
                        "id_token_user_21" => "line_id_user_21" }
        return line_id_hash[id_token]
      end

      uri = URI.parse("https://api.line.me/oauth2/v2.1/verify")
      res = Net::HTTP.post_form(uri, {'id_token'=>id_token, 'client_id'=>ENV['LIFF_CHANNEL_ID']})
      JSON.parse(res.body)['sub']
    end
end
