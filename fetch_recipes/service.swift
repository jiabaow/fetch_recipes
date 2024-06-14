//
//  service.swift
//  fetch_recipes
//
//  Created by 温嘉宝 on 11.06.2024.
//

import Foundation
import Combine

struct Dessert: Hashable, Codable {
    let strMeal: String
    let idMeal: String
    let strMealThumb: String
}

struct MealResponse: Codable {
    let meals: [Dessert]
}

struct Ingredient: Hashable {
    let name: String
    let measure: String
}

struct MealDetail: Codable {
    let idMeal: String
    let strMeal: String
    let strInstructions: String
    let strMealThumb: String
    
    var ingredients: [Ingredient] {
        var ingredientsList: [Ingredient] = []
        
        for i in 1...20 {
            if let ingredient = self.value(forKey: "strIngredient\(i)") as? String,
               let measure = self.value(forKey: "strMeasure\(i)") as? String,
               !ingredient.isEmpty, !measure.isEmpty {
                ingredientsList.append(Ingredient(name: ingredient, measure: measure))
            }
        }
        print("Parsed Ingredients: \(ingredientsList)")
        return ingredientsList
    }
    
    private enum Codingkeys: String, CodingKey {
        case idMeal, strMeal, strInstructions, strMealThumb
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
             strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
             strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15,
             strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
             strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
             strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15,
             strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }
    
    fileprivate func value(forKey key: String) -> Any? {
        return Mirror(reflecting: self).children.first { $0.label == key }?.value
    }
}

struct MealDetailResponse: Codable {
    let meals: [MealDetail]
}

class MealService {
    func fetchMeals() -> AnyPublisher<[Dessert], Error>? {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
                print("Invalid URL")
                return nil
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: MealResponse.self, decoder: JSONDecoder())
            .map{ $0.meals }
            .eraseToAnyPublisher()
    }
    
    func fetchMealDetail(by id: String) -> AnyPublisher<MealDetail, Error>? {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            print("Invalid URL")
            return nil
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: MealDetailResponse.self, decoder: JSONDecoder())
            .compactMap { $0.meals.first }
            .eraseToAnyPublisher()
    }
    
}
