class MessagesController < ApplicationController
  def new; end

  def create
    SmsTrap::Connector.new.send_message(
      from: params[:from],
      to: params[:to],
      text: params[:text]
    )

    redirect_to new_message_path, notice: "Sent. Check it out in SmsTrap."
  end
end
