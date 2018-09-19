# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# INGREDIENTS

butter = Ingredient.create(name: "Butter", emoji: "butter")
sugar = Ingredient.create(name: "Sugar", emoji: "sugar")
egg = Ingredient.create(name: "Egg", emoji: "egg")
flour = Ingredient.create(name: "Flour", emoji: "flour")

chocolate = Ingredient.create(name: "Chocolate", emoji: "chocolate_bar")
peanut_butter = Ingredient.create(name: "Peanutbutter", emoji: "peanuts")


# RECIPES

chocochip_recipe = CookieRecipe.create(name: "Chocolate Chip", emoji: "cookie")
# add recipe ingredients to chocolate chip recipe
chocochip_recipe.recipe_ingredients.create(ingredient_id: butter.id, count: 2)
chocochip_recipe.recipe_ingredients.create(ingredient_id: sugar.id, count: 2)
chocochip_recipe.recipe_ingredients.create(ingredient_id: egg.id, count: 2)
chocochip_recipe.recipe_ingredients.create(ingredient_id: flour.id, count: 3)
chocochip_recipe.recipe_ingredients.create(ingredient_id: chocolate.id, count: 1)

peanut_butter_recipe = CookieRecipe.create(name: "Peanut Butter", emoji: "pbcookie")
# add recipe ingredients to peanut butter recipe
peanut_butter_recipe.recipe_ingredients.create(ingredient_id: butter.id, count: 2)
peanut_butter_recipe.recipe_ingredients.create(ingredient_id: sugar.id, count: 3)
peanut_butter_recipe.recipe_ingredients.create(ingredient_id: egg.id, count: 2)
peanut_butter_recipe.recipe_ingredients.create(ingredient_id: flour.id, count: 3)
peanut_butter_recipe.recipe_ingredients.create(ingredient_id: peanut_butter.id, count: 1)

sugar_cookie_recipe = CookieRecipe.create(name: "Sugar", emoji: "sugarcookie")
# add recipe ingredients to sugar cookie recipe
sugar_cookie_recipe.recipe_ingredients.create(ingredient_id: butter.id, count: 2)
sugar_cookie_recipe.recipe_ingredients.create(ingredient_id: sugar.id, count: 5)
sugar_cookie_recipe.recipe_ingredients.create(ingredient_id: egg.id, count: 2)
sugar_cookie_recipe.recipe_ingredients.create(ingredient_id: flour.id, count: 3)