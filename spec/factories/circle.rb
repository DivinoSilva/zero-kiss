FactoryBot.define do
  factory :circle do
    association :frame
    center_x { 0.0 }
    center_y { 0.0 }
    diameter { 6.0 }
  end
end
