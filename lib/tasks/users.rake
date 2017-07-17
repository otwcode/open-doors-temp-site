namespace :users do

  desc "Create a user"
  task :create_user, [:name, :email, :password] => :environment do |_t, args|
    u = User.find_or_create_by(email: args[:email])
    u.update(name: args[:name], email: args[:email], password: args[:password], password_confirmation: args[:password])
    u.save!
  end
end
