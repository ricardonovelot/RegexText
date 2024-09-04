//
//  ContentView.swift
//  RegexText
//
//  Created by Ricardo on 03/09/24.
//

import SwiftUI
import RegexBuilder

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModifier()
    
    var body: some View {
        NavigationStack {
            Form{
                Section{
                    TextField("Text", text: $viewModel.inputText, axis: .vertical)
                        .onChange(of: viewModel.inputText) { _, _ in
                            viewModel.clearResults()
                            viewModel.generateHastags()
                            viewModel.generateMentions()
                        }
                        .lineLimit(3...)
                }  footer: {
                    Text("Recognize @mentions and #hashtags")
                }
                
                Section{
                    List(viewModel.results){ result in
                        HStack{
                            Image(systemName: result.text)
                                .foregroundStyle(Color(uiColor: .tintColor))
                            Text(result.text)
                        }
                    }
                } header: {
                    Text("Results")
                }
                
            }
            .toolbar{
                Button {
                    viewModel.generateRandomSample()
                } label: {
                    Image(systemName: "repeat")
                }

            }
            .contentMargins(.top, 16)
            .navigationTitle("RegexText")
        }
    }
}

struct Result: Identifiable{
    var id = UUID()
    var text: String
}



extension ContentView{
    class ContentViewModifier: ObservableObject{
        @Published var inputText = ""
        @Published var summaryText = ""
        @Published var hastagsDetected = ""
        @Published var results: [Result] = []
        var lastIndex: Int? = nil
        
        
        let sampleInputTexts = [
            "#FamilyTime at the beach with @john! #Sunset #Ocean #Relax",
            "Celebrating my birthday with @alice and @tom! #HappyBirthday #Cake #Party",
            "Throwback to our epic road trip! #TBT #Adventure #Travel #Friends",
            "This is my favorite book! #Reading #Bookworm #CozyEvening",
            "Had a blast at the concert last night! #LiveMusic #RockOn #GoodVibes",
            "New recipe turned out amazing! #Cooking #HomeChef #Yummy",
            "Enjoying a quiet moment with @jane. #TeaTime #Relaxation #Peaceful",
            "First snow of the season! #WinterWonderland #SnowDay #Cozy"
        ]
        
        init(){
            generateRandomSample()
            generateHastags()
            generateMentions()
        }
        
        func clearResults(){
            results.removeAll()
        }
        
        
        func generateRandomSample(){
            let index = Int.random(in: 0...sampleInputTexts.count-1)
            if lastIndex == index {
                generateRandomSample()
            } else {
                lastIndex = index
                inputText = sampleInputTexts[index]
            }
        }
        
        func generateHastags(){
            let regex = "#[[:alnum:]]+"
            let matches = matches(for: regex, in: inputText)
            
            for match in matches {
                results.append(Result(text: match))
            }
        }
        
        func generateMentions(){
            let regex = "@[[:alnum:]]+"
            let matches = matches(for: regex, in: inputText)
            
            for match in matches {
                results.append(Result(text: match))
            }
        }
        
        
        func matches(for regex: String, in text: String) -> [String] {
            do {
                let regex = try NSRegularExpression(pattern: regex)
                let results = regex.matches(in: text,
                                            range: NSRange(text.startIndex..., in: text))
                return results.map {
                    String(text[Range($0.range, in: text)!])
                }
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
                return []
            }
        }

    }
}



#Preview {
    ContentView()
}

