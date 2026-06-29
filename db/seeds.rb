# db/seeds.rb

puts "--- Cleaning Database ---"
# Destroy items in reverse order of dependencies to avoid foreign key violations
OrderItem.destroy_all
Order.destroy_all
Product.destroy_all
Brand.destroy_all
User.destroy_all

puts "--- Creating Users ---"
# Creating an Admin user for catalog management testing
admin = User.create!(
  full_name: "Alex Brewer",
  email: "admin@brewhub.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)
puts "Created Admin: #{admin.email}"

# Creating a regular customer for checkout/order testing
customer = User.create!(
  full_name: "Jane Doe",
  email: "customer@gmail.com",
  password: "password123",
  password_confirmation: "password123",
  role: "customer"
)
puts "Created Customer: #{customer.email}"


puts "--- Creating Brands & Products ---"

# 1. Beer Brand
sierranevada = Brand.create!(
  name: "Sierra Nevada Brewing Co.",
  country_of_origin: "USA",
  category: "beer"
)
Product.create!([
  { name: "Pale Ale", sku: "SN-PALE-01", price_cents: 399, alcohol_by_volume: 5.6, stock_quantity: 150, brand: sierranevada },
  { name: "Hazy Little Thing IPA", sku: "SN-HAZY-02", price_cents: 449, alcohol_by_volume: 6.7, stock_quantity: 8, brand: sierranevada } # Low stock to trigger alert worker
])

# 2. Wine Brand
chateau_margaux = Brand.create!(
  name: "Château Margaux",
  country_of_origin: "France",
  category: "wine"
)
Product.create!([
  { name: "Premier Grand Cru Classé 2015", sku: "CM-CRU-15", price_cents: 85000, alcohol_by_volume: 13.5, stock_quantity: 12, brand: chateau_margaux },
  { name: "Pavillon Rouge du Château Margaux", sku: "CM-ROUGE-01", price_cents: 22000, alcohol_by_volume: 13.2, stock_quantity: 24, brand: chateau_margaux }
])

# 3. Spirits Brand
macallan = Brand.create!(
  name: "The Macallan Distillery",
  country_of_origin: "Scotland",
  category: "spirits"
)
Product.create!([
  { name: "Double Cask 12 Years Old", sku: "MAC-DC-12", price_cents: 7500, alcohol_by_volume: 43.0, stock_quantity: 40, brand: macallan },
  { name: "Sherry Oak 18 Years Old", sku: "MAC-SO-18", price_cents: 35000, alcohol_by_volume: 43.0, stock_quantity: 5, brand: macallan } # Low stock
])

# 4. Soft Drink Brand
fevertree = Brand.create!(
  name: "Fever-Tree",
  country_of_origin: "UK",
  category: "soft_drink"
)
Product.create!([
  { name: "Premium Indian Tonic Water", sku: "FT-TONIC-01", price_cents: 199, alcohol_by_volume: 0.0, stock_quantity: 500, brand: fevertree },
  { name: "Ginger Beer", sku: "FT-GINGER-02", price_cents: 229, alcohol_by_volume: 0.0, stock_quantity: 0, brand: fevertree } # Out of stock to test failure validation
])

# 5. Juice Brand
innocent = Brand.create!(
  name: "Innocent Drinks",
  country_of_origin: "UK",
  category: "juice"
)
Product.create!([
  { name: "Strawberry & Banana Smoothie", sku: "INN-SB-01", price_cents: 349, alcohol_by_volume: 0.0, stock_quantity: 85, brand: innocent },
  { name: "100% Pure Squeezed Orange Juice", sku: "INN-OJ-02", price_cents: 299, alcohol_by_volume: 0.0, stock_quantity: 120, brand: innocent }
])

puts "Created #{Brand.count} brands and #{Product.count} products."


puts "--- Creating a Historical Seed Order ---"
# Creating a dummy order for testing GET /orders/:id out of the box
order = Order.create!(
  user: customer,
  status: "confirmed",
  total_cents: 0 # Calculated below
)

item_1 = OrderItem.create!(
  order: order,
  product: Product.find_by!(sku: "SN-PALE-01"),
  quantity: 2,
  unit_price_cents: 399
)

item_2 = OrderItem.create!(
  order: order,
  product: Product.find_by!(sku: "FT-TONIC-01"),
  quantity: 4,
  unit_price_cents: 199
)

# Sync the order total
order.update!(total_cents: (item_1.quantity * item_1.unit_price_cents) + (item_2.quantity * item_2.unit_price_cents))

puts "Created reference order ##{order.id} for customer with total $#{order.total_cents / 100.0}"
puts "--- Database Seeding Complete! ---"