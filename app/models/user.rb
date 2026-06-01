class User < ApplicationRecord
    has_many :products
    has_one :orders
end
