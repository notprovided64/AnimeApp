//
//  CategoryView.swift
//  AnimeApp
//
//  Created by Preston Clayton on 4/11/24.
//

import SwiftUI

struct CategoryView: View {
    var body: some View {
        List {
            ForEach(Category.allCases, id: \.rawValue) { category in
                NavigationLink {
                    CategoryRowView(category: category)
                } label: {
                    Text(category.getTitle())
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Categories")
    }
}

#Preview {
    CategoryView()
}
