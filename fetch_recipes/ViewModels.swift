//
//  ViewModels.swift
//  fetch_recipes
//
//  Created by 温嘉宝 on 11.06.2024.
//

import Foundation
import SwiftUI
import Combine



class ViewModel: ObservableObject {
    @Published var desserts: [Dessert] = []
    @Published var selectedMealDetail: MealDetail?
    private var cancellables = Set<AnyCancellable>()
    private let service = MealService()
    
    func fetchMeals() {
        guard let publisher = service.fetchMeals() else {
            print("Failed to create publisher")
            return
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to fetch meals: \(error.localizedDescription)")
                }
            }, receiveValue: { desserts in
                self.desserts = desserts.filter { !$0.strMeal.isEmpty }
                self.desserts.sort { $0.strMeal < $1.strMeal }
            })
            .store(in: &cancellables)
    }
    
    func fetchMealDetail(by id: String) {
        guard let publisher = service.fetchMealDetail(by: id) else {
            print("Failed to create publisher")
            return
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to fetch meal detail: \(error.localizedDescription)")
                }
            }, receiveValue: { MealDetail in
                self.selectedMealDetail = MealDetail
            })
            .store(in: &cancellables)
    }
}
