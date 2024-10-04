//
//  UnboardingView.swift
//  Version Finale
//
//  Created by Tiago Alves on 17.08.2024.
//

import SwiftUI


struct UnboardingView: View {
    @Binding var shouldShowOnBoarding: Bool
    var body: some View {
        
        TabView{
            
            WelcomeView(bool: $shouldShowOnBoarding)
            
            FausseImageView(nomImage: "listeVide", text: "Ceci est la toute première étape! Il faut créer votre première liste.")
            
            FausseExempleView(nomImage: "ListeavcGraphique", text: "Après avoir créer votre premier liste et y ajouter le premier mot ceci est votre vue! Vous pouvez ajouter d'autres mots, étudier la liste ou après quelques études, regarder les statistiques!")
            
            FausseNvoMotSheetView(nomImage: "Nouveau mot", color: Color(.systemGray6), text: "Ceci est votre vue pour ajouter de nouveaux mots! Vous pouvez aussi ajouter des mots à partir d'un texte, mais cela sera expliqué lorsque vous cliquerez sur ce bouton ;) !")
            
            FausseImageSheetView(nomImage: "Calendrier", color: .white, text: "Ceci est le calendrier. Ici vous pourrez choisir la date de fin d'études et vous recevrez une notification quotidiennement jusqu'à cette date")
            
            FausseImageSheetView(nomImage: "TypeEtudes", color: Color(.systemGray6), text: "Grâce à cette vue vous pourrez choisir votre mode d'étude.")
            
            FausseCarteView()
            
            FausseImageView(nomImage: "Félicitations", text: "Voici ce qui s'affiche à la fin de chacune de vos études! Vous pouvez mettre encore plus de confettis ou regarder les statistques de votre étude! ")
            
            EndView(bool: $shouldShowOnBoarding)
                    
        }.ignoresSafeArea()
        .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

#Preview {
    UnboardingView(shouldShowOnBoarding: .constant(true))
    
}


struct WelcomeView: View {
    @Binding var bool: Bool
    var body: some View {
        ZStack{
            Color(.icon)
                .ignoresSafeArea()
            VStack{
                
                Text("Version finale")
                    .font(.system(size: 55))
                    .fontWeight(.bold)
                    .padding()
                
                Text("Nous allons faire un court tutoriel")
                    
                Image("Icon")
                Button("Passer le tutoriel"){
                    bool = false
                }
                .frame(width: 150,height: 50)
                .background(Color(.systemGray6))
                .foregroundStyle(.icon)
                .cornerRadius(10)
                Spacer()
                Text("Glissez vers la droite pour continuer le tutoriel")
                    .font(.caption)
                    
            }
            
            .foregroundStyle(Color(.systemGray6))
        }
    }
}
    
struct FausseNvoMotSheetView: View {
    var nomImage: String
    var color: Color
    var text: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Affiche l'image plein écran
                Image(nomImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(edges: .all)
              Text(text)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 1.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.icon)
                VStack {
                    // Rectangle blanc en haut
                    Color(color)
                        .frame(height: 90)
                        .ignoresSafeArea(edges: .top)
                    
                    Spacer() // Espace restant de l'écran
                    
                    // Rectangle blanc en bas
                    Color(color)
                        .frame(height: max(geometry.safeAreaInsets.bottom, 100))
                        .ignoresSafeArea(edges: .bottom)
                }
                
            }
        }
    }
}

struct FausseImageSheetView: View {
    var nomImage: String
    var color: Color
    var text: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Affiche l'image plein écran
                Image(nomImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(edges: .all)
              Text(text)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 1.1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.icon)
                VStack {
                    // Rectangle blanc en haut
                    Color(color)
                        .frame(height: 90)
                        .ignoresSafeArea(edges: .top)
                    
                    Spacer() // Espace restant de l'écran
                    
                    // Rectangle blanc en bas
                    Color(color)
                        .frame(height: max(geometry.safeAreaInsets.bottom, 100))
                        .ignoresSafeArea(edges: .bottom)
                }
                
            }
        }
    }
}


struct FausseImageView: View {
    var nomImage: String
    var text: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Affiche l'image plein écran
                Image(nomImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(edges: .all)
               Text(text)
                      .position(x: geometry.size.width / 2, y: geometry.size.height / 4)
                      .multilineTextAlignment(.center)
                      .foregroundStyle(.icon)
                VStack {
                    // Rectangle blanc en haut
                    Color(.systemGray6)
                        .frame(height: geometry.safeAreaInsets.top)
                        .ignoresSafeArea(edges: .top)
                    
                    Spacer() // Espace restant de l'écran
                    
                    // Rectangle blanc en bas
                    Color(.systemGray6)
                        .frame(height: max(geometry.safeAreaInsets.bottom, 100))
                        .ignoresSafeArea(edges: .bottom)
                }
                
            }
        }
    }
}
struct FausseExempleView: View {
    var nomImage: String
    var text: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Affiche l'image plein écran
                Image(nomImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(edges: .all)
               Text(text)
                      .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                      .multilineTextAlignment(.center)
                      .foregroundStyle(.icon)
                VStack {
                    // Rectangle blanc en haut
                    Color(.systemGray6)
                        .frame(height: geometry.safeAreaInsets.top)
                        .ignoresSafeArea(edges: .top)
                    
                    Spacer() // Espace restant de l'écran
                    
                    // Rectangle blanc en bas
                    Color(.systemGray6)
                        .frame(height: max(geometry.safeAreaInsets.bottom, 100))
                        .ignoresSafeArea(edges: .bottom)
                }
                
            }
        }
    }
}


struct FausseCarteView: View {
    @State private var Answer: Bool = false
    
    var body: some View {
        ZStack {
            // Background for the entire view
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Texte supplémentaire en haut qui ne déplace pas la carte
                if Answer {
                    VStack {
                        Text("Bien joué! Ceci est la méchanique de base pour apprendre vos mots!")
                        
                    }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.icon)
                    .padding(.bottom,60)
                    .padding() // Ajoute un peu d'espace autour des textes
                    .background(Color(.systemGray6)) // Optionnel : Ajoute un fond blanc pour la lisibilité
                }else{
                    Spacer()
                }
                
                
                
                // Carte
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.black)
                        .frame(width: 320, height: 420)
                        .shadow(radius: 4)
                    
                    VStack {
                        Text("Démonstration")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .bold()
                            .padding(.bottom, 20)
                        
                        if Answer {
                            Text("Bien joué!")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                }
                .onTapGesture {
                    Answer.toggle()
                }
                
                Spacer() // Espace entre la carte et le texte en bas
                
                // Texte en bas
                Text("Cliquez sur la carte pour montrer la traduction!")
                    .padding()
                    .foregroundStyle(.icon)
            }
        }
    }
}

struct EndView: View {
   @Binding var bool: Bool
    var body: some View {
        ZStack{
            Color(.icon)
                .ignoresSafeArea()
            VStack{
                Text("Voilà, vous venez de finir le tutoriel! Nous vous laissons découvrir encore les autres fonctionnalités! Bonnes études!")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(.systemGray6))
                    .padding()
                Button("Cliquer pour finir le tutoriel"){
                    bool = false
                }
                .frame(width: 150,height: 50)
                .background(Color(.systemGray6))
                .foregroundStyle(.icon)
                .cornerRadius(10)
                .padding()
            }.padding()
        }
    }
}
#Preview {
    UnboardingView(shouldShowOnBoarding: .constant(true))
}
