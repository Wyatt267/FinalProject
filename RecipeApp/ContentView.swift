//
//  ContentView.swift
//  RecipeApp
//
//  Created by Wyatt Denham on 4/27/24.
//

import SwiftUI

// Define an enum for the top 7 allergens
enum Allergen: String, CaseIterable {
    case cheese
    case milk
    case eggs
    case peanuts
    case treeNuts
    case shellfish
    case soy
    case wheat
}

// Define a struct for a recipe
struct Recipe: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let ingredients: [String]
    let instructions: [String]
    let isFavorite: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Sample data for recipes
let sampleRecipes: [Recipe] = [
    Recipe(name: "Spaghetti Carbonara",
              ingredients: ["Pasta", "Eggs", "Bacon", "Cheese"],
              instructions: ["Cook pasta according to package instructions.", "In a separate pan, fry bacon until crispy.", "In a bowl, whisk together eggs and grated Parmesan cheese.", "Toss cooked pasta with bacon and egg mixture until coated.", "Serve hot with additional grated Parmesan cheese."],
              isFavorite: false),
       Recipe(name: "Chicken Parmesan",
              ingredients: ["Chicken Breast", "Tomato Sauce", "Cheese", "Breadcrumbs"],
              instructions: ["Preheat oven to 375°F (190°C).", "Bread chicken breasts with breadcrumbs.", "Bake chicken in preheated oven for 20 minutes.", "Top chicken with tomato sauce and mozzarella cheese.", "Bake for an additional 10 minutes or until cheese is melted and bubbly."],
              isFavorite: false),
       Recipe(name: "Caesar Salad",
              ingredients: ["Romaine Lettuce", "Croutons", "Cheese", "Caesar Dressing"],
              instructions: ["Wash and chop romaine lettuce.", "Toss lettuce with Caesar dressing.", "Top with croutons and shaved Parmesan cheese.", "Serve immediately."],
              isFavorite: false),
       Recipe(name: "Beef Stir Fry",
              ingredients: ["Beef", "Bell Peppers", "Broccoli", "Soy Sauce"],
              instructions: ["Slice beef thinly against the grain.", "Heat a pan over medium-high heat and add beef slices.", "Stir-fry until beef is browned.", "Add bell peppers and broccoli to the pan.", "Continue to stir-fry until vegetables are tender.", "Add soy sauce and stir to combine.", "Serve hot."],
              isFavorite: false),
       Recipe(name: "Chocolate Chip Cookies",
              ingredients: ["Flour", "Butter", "Sugar", "Chocolate Chips"],
              instructions: ["Preheat oven to 350°F (175°C).", "In a bowl, cream together butter and sugar until light and fluffy.", "Mix in flour until well combined.", "Fold in chocolate chips.", "Drop spoonfuls of dough onto a baking sheet.", "Bake for 8-10 minutes or until edges are golden brown."],
              isFavorite: false)
]

// Define a view model to manage the app's data and state
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = sampleRecipes
    @Published var userAllergens: [Allergen] = []
    @Published var favoriteRecipes: [Recipe] = []

    // Function to filter recipes based on user's allergens
    func filterRecipes() -> [Recipe] {
        return recipes.filter { recipe in
            !recipe.ingredients.contains { ingredient in
                let allergen = Allergen(rawValue: ingredient.lowercased())
                return allergen != nil && userAllergens.contains(allergen!)
            }
        }
    }

    // Function to add a recipe to favorites
    func addToFavorites(_ recipe: Recipe) {
        if !favoriteRecipes.contains(where: { $0.id == recipe.id }) {
            favoriteRecipes.append(recipe)
        }
    }

    // Function to remove a recipe from favorites
    func removeFromFavorites(_ recipe: Recipe) {
        favoriteRecipes.removeAll { $0.id == recipe.id }
    }
}

// Recipe list view
struct RecipeListView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @State private var selectedRecipe: Recipe?

    var body: some View {
        NavigationView {
            List(viewModel.filterRecipes(), id: \.self) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe), tag: recipe, selection: $selectedRecipe) {
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

// Recipe detail view
struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: RecipeViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack {
                            // Image at the top
                            Image(recipe.name) // Assuming the image name is the same as the recipe name
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(10)
                                .shadow(radius: 5)
                    
                            
                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    viewModel.addToFavorites(recipe)
                                                }) {
                                                    Image(systemName: viewModel.favoriteRecipes.contains(where: { $0.id == recipe.id }) ? "heart.fill" : "heart")
                                                        .foregroundColor(.red)
                                                        .padding()
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                        .shadow(radius: 5)
                                }
                                .padding(.trailing, 20) // Add padding to the button
                            }
                            .padding(.top, 20)
                            
                            Text(recipe.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding()
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Ingredients:")
                                    .font(.headline)
                                ForEach(recipe.ingredients, id: \.self) { ingredient in
                                    Text("• \(ingredient)")
                                }
                            }
                            .padding()
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Cooking Instructions:")
                                    .font(.headline)
                                ForEach(recipe.instructions.indices, id: \.self) { index in
                                    Text("\(index + 1). \(recipe.instructions[index])")
                                        .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                                }
                            }
                            .padding()
                            
                            Spacer()
                        }
                    }
                    
                    // Bottom navigation tabs
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: FavoriteRecipesView()) {
                        Image(systemName: "heart.fill")
                            .padding(.horizontal)
                    }
                }
                .navigationTitle("Recipe Details")
    }
}

// Recipe row view
struct RecipeRow: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: RecipeViewModel

    var body: some View {
        HStack {
            Image(recipe.name)
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 50, height: 50)
                           .cornerRadius(10)
                           .shadow(radius: 5)
            Button(action: {
                viewModel.addToFavorites(recipe)
            }) {
                Image(systemName: viewModel.favoriteRecipes.contains(where: { $0.id == recipe.id }) ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
            Text(recipe.name)
            Spacer()
        }
        .padding(.horizontal)
    }
}

// Profile view
struct ProfileView: View {
    @EnvironmentObject var viewModel: RecipeViewModel

    var body: some View {
        VStack {
            Text("Manage Allergens")
                .font(.title)
                .padding()
            AllergenSelectionView()
        }
    }
}

// Allergen selection view
struct AllergenSelectionView: View {
    @EnvironmentObject var viewModel: RecipeViewModel

    var body: some View {
        VStack {
            ForEach(Allergen.allCases, id: \.self) { allergen in
                Toggle(allergen.rawValue.capitalized, isOn: Binding(
                    get: {
                        viewModel.userAllergens.contains(allergen)
                    },
                    set: { newValue in
                        if newValue {
                            viewModel.userAllergens.append(allergen)
                        } else {
                            viewModel.userAllergens.removeAll { $0 == allergen }
                        }
                    }
                ))
                .padding()
            }
        }
    }
}

// Main app view
struct ContentView: View {
    var body: some View {
        TabView {
            // Favorites view
            FavoriteRecipesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
            // Recipe list view
            RecipeListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Recipes")
                }
            // Profile view
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}

// Favorites view
// Favorites view
struct FavoriteRecipesView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @State private var selectedRecipe: Recipe?
    
    var body: some View {
        NavigationView {
            List(viewModel.favoriteRecipes) { recipe in
                Button(action: {
                    selectedRecipe = recipe
                }) {
                    HStack {
                        // Display the recipe photo on the left side
                        Image(recipe.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        Text(recipe.name)
                    }
                }
                }
                .navigationTitle("Favorites")
                .sheet(item: $selectedRecipe) { recipe in
                    RecipeDetailView(recipe: recipe)
                }        }
        }
    }
    
    @main
    struct RecipeApp: App {
        @StateObject var viewModel = RecipeViewModel()
        
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(viewModel)
            }
        }
    }
    

