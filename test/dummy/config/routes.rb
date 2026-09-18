Rails.application.routes.draw do
  root to: "messages#new"
  get "/messages/new", to: "messages#new", as: :new_message
  post "/messages", to: "messages#create", as: :messages

  mount SmsTrap::Engine => "/sms_trap"
end
