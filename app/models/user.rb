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
 end
