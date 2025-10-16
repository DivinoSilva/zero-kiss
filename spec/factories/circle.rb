FactoryBot.define do
  factory :circle do
    association :frame
    center_x { frame.center_x }
    center_y { frame.center_y }
    diameter { 6.0 }
  end
end
