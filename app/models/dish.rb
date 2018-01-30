class Dish < ApplicationRecord
  scope :get_n_pages, -> (n){where('id <= ?', n*25)}
end
