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
    let ingredients: [Ingredient]
    
    private enum CodingKeys: String, CodingKey {
        case idMeal, strMeal, strInstructions, strMealThumb
    }
    
    //https://matteomanferdini.com/swift-decode-json-dynamic-keys/
    //https://stackoverflow.com/questions/67924022/how-to-decode-json-that-has-dynamic-key-values-in-swift
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        idMeal = try container.decode(String.self, forKey: .idMeal)
        strMeal = try container.decode(String.self, forKey: .strMeal)
        strInstructions = try container.decode(String.self, forKey: .strInstructions)
        strMealThumb = try container.decode(String.self, forKey: .strMealThumb)
        
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        var ingredientsList: [Ingredient] = []
        
        var index = 1
        while let ingredientKey = DynamicCodingKeys(stringValue: "strIngredient\(index)"),
              let measureKey = DynamicCodingKeys(stringValue: "strMeasure\(index)"),
              dynamicContainer.contains(ingredientKey),
              dynamicContainer.contains(measureKey),
              let ingredient = try dynamicContainer.decodeIfPresent(String.self, forKey: ingredientKey),
              let measure = try dynamicContainer.decodeIfPresent(String.self, forKey: measureKey),
              !ingredient.isEmpty, !measure.isEmpty {
            ingredientsList.append(Ingredient(name: ingredient, measure: measure))
            index += 1
        }
        print("Parsed Ingredients: \(ingredientsList)")
        self.ingredients = ingredientsList
    }
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }
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
