class DeviseMailer < Devise::Mailer
  default from: email_address_with_name('bestrip2024@gmail.com', 'BesTrip')

  def invitation_instructions(record, token, opts = {})
    opts[:subject] = "#{User.find(record.invited_by_id).name}さんがあなたを招待しています"

    super
  end
end
