Rails.application.routes.draw do
  mount SmsTrap::Engine => "/sms_trap"
end
