//
//  test.swift
//  AI View Test
//
//  Created by admin on 03.05.2025.
//

import SwiftUI

struct test : View {
    var body: some View {
        List {
            ForEach(0..<3) { section in
                Section(header:
                            CustomHeader(
                                name: "Section Name",
                                color: Color.yellow
                            )
                        ) {
                    ForEach(0..<3) { row in
                        Text("Row")
                    }
                }
            }
        }
    }
}

struct CustomHeader: View {
    let name: String
    let color: Color

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(name)
                Spacer()
            }
            Spacer()
        }
        .padding(0).background(FillAll(color: color))
    }
}

struct FillAll: View {
    let color: Color
    
    var body: some View {
        GeometryReader { proxy in
            self.color.frame(width: proxy.size.width * 1.3, height: 40).fixedSize()
                .padding(.leading, -20)
        }
    }
}
#Preview {
    test()
}
