class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable, :omniauthable

  field :provider
  field :uid
  field :name
  field :admin, type: 'Boolean'

  attr_accessible :provider, :uid, :name, :email, :password, :password_confirmation, :remember_me

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session[:omniauth]
        user.user_tokens.build(provider: data['provider'], uid: data['uid'])
      end
    end
  end

  def apply_omniauth(omniauth)
    #add some info about the user
    #self.name = omniauth['user_info']['name'] if name.blank?
    #self.nickname = omniauth['user_info']['nickname'] if nickname.blank?

    unless omniauth['credentials'].blank?
      user_tokens.build(provider: omniauth['provider'], uid: omniauth['uid'])
      #user_tokens.build(provider: omniauth['provider'],
      # uid: omniauth['uid'],
      # token: omniauth['credentials']['token'],
      # secret: omniauth['credentials']['secret'])
    else
      user_tokens.build(provider: omniauth['provider'], uid: omniauth['uid'])
    end
    #self.confirm!# unless user.email.blank?
  end

  def password_required?
    (user_tokens.empty? || !password.blank?) && super
  end

  #def self.create_with_omniomniauth(omniauth)
  #  begin
  #    create! do |user|
  #      user.provider = omniauth['provider']
  #      user.uid = omniauth['uid']
  #      if omniauth['user_info']
  #        user.name = omniauth['user_info']['name'] if omniauth['user_info']['name'] # Twitter, Google, Yahoo, GitHub
  #        user.email = omniauth['user_info']['email'] if omniauth['user_info']['email'] # Google, Yahoo, GitHub
  #      end
  #      if omniauth['extra']['user_hash']
  #        user.name = omniauth['extra']['user_hash']['name'] if omniauth['extra']['user_hash']['name'] # Facebook
  #        user.email = omniauth['extra']['user_hash']['email'] if omniauth['extra']['user_hash']['email'] # Facebook
  #      end
  #    end
  #  rescue Exception
  #    raise Exception, "cannot create user record"
  #  end
  #end

end
