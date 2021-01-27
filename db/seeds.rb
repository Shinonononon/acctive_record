require "csv"

ADDRESSES = CSV.foreach(
    "./lib/master_data/13tokyo.csv",
    encoding: "Shift_JIS:UTF-8",
    headers: true
  )
  .entries
  .reject{|address| address["字丁目"].blank? }

def random_address
  address = ADDRESSES.delete_at(rand(0..ADDRESSES.size)) # 重複しないように一度使ったら消す
  FactoryBot.build(
    :address,
    prefecture: address["都道府県"],
    city: address["市区町村"],
    line_1: address["町域"],
    line_2: address["字丁目"],
    postalcode: address["郵便番号"]
  )
end

def setup_shop
  shop = FactoryBot.create(:shop, name: Faker::Restaurant.unique.name)
  rand(1..3).times{ shop.addresses << random_address }
  rand(1..10).times do
    FactoryBot.create(
      "#{["japanese","chinese","italian"].sample}_food",
      shop: shop,
      name: "#{Faker::Creature::Animal.name}の#{Faker::Restaurant.type}",
      price: 300.step(by:100, to:1900).to_a.sample + 90
    )
  end
end

def setup_customer
  customer = FactoryBot.create(:customer, name: Faker::Name.unique.name)
  rand(1..3).times{ customer.addresses << random_address }
  rand(1..10).times do
    FactoryBot.create(
      :order,
      customer: customer,
      address: customer.addresses.sample
    )
  end
  customer.orders.each do |order|
    shop = Shop.all.sample
    rand(1..10).times do
      FactoryBot.create(
        :order_food,
        order: order,
        food: shop.foods.sample
      )
    end
  end
end

100.times do
  setup_shop
  setup_customer
end