//
//  ContentView.swift
//  fetch_recipes
//
//  Created by 温嘉宝 on 11.06.2024.
//

import SwiftUI



struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            
            List(viewModel.desserts, id: \.self) { dessert in
                NavigationLink(destination: DetailView(dessert: dessert, viewModel: viewModel)) {
                    HStack {
                        if let url = URL(string: dessert.strMealThumb) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        Text(dessert.strMeal).padding(.leading, 8)
                    }
                }
            }
            .navigationTitle("Desserts")
            .onAppear {
                viewModel.fetchMeals()
            }
        }
    }
    
}

struct DetailView: View {
    let dessert: Dessert
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let meal = viewModel.selectedMealDetail {
                    HStack {
                        Spacer()
                        Text(meal.strMeal)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                        Spacer()
                    }
                    
                    if let url = URL(string: dessert.strMealThumb) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .padding()
                    }
                    
                    Text("Instructions").font(.headline).padding(.horizontal)
                    Text(meal.strInstructions).padding(.horizontal)
                    Spacer()
                    Spacer()
                    Text("Ingredients").font(.headline).padding(.horizontal)
                    
                    ForEach(meal.ingredients, id: \.self) {
                        Ingredient in Text("\(Ingredient.name): \(Ingredient.measure)").padding(.horizontal)
                    }
                    
                    Spacer()
                } else {
                    ProgressView().onAppear {
                        viewModel.fetchMealDetail(by: dessert.idMeal)
                    }
                }
            }
            .padding(.horizontal)
            .onAppear {
                viewModel.fetchMealDetail(by: dessert.idMeal)
            }
       
        }
    }
}

#Preview {
    ContentView()
}
