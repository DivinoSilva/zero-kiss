FactoryBot.define do
  factory :frame do
    center_x { 10.0 }
    center_y { 10.0 }
    width    { 20.0 }
    height   { 30.0 }

    trait :square do
      width  { 40.0 }
      height { 40.0 }
    end

    trait :wide do
      width  { 100.0 }
      height { 40.0 }
    end
  end
end
