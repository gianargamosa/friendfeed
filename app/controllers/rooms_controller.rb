class RoomsController < ApplicationController
  before_action :authenticate_user!
  def show
    # @messages = Message.all
    @messages = current_user.all_message.reverse
  end
end
