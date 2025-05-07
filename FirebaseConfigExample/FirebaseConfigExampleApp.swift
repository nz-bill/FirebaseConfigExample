//
//  FirebaseConfigExampleApp.swift
//  FirebaseConfigExample
//
//  Created by Bill Palmestedt on 2025-05-07.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
      configureFirebase()
    return true
  }
    
    func configureFirebase() {
        
        // gör om vår secrets.plist till en dictionary för att enkelt komma åt datan
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("Kunde inte läsa Secrets.plist")
        }
        
        // vi skapar ett FirebaseOptionsObjekt.
        //denna kan användas ist för GoogleService-Info.plist när vi sen konfigurerar firebase
        // vi sätter värdena från vår nyligen skapade dictionary
        let options = FirebaseOptions(
            googleAppID: dict["APP_ID"] as! String,
            gcmSenderID: dict["GCM_SENDER_ID"] as! String
        )
        options.apiKey = dict["API_KEY"] as? String
        options.projectID = dict["PROJECT_ID"] as? String
        options.storageBucket = dict["STORAGE_BUCKET"] as? String
//        eventuellt fler fält. om du exempelvis använder google sign-in, lägger du till:
//        options.clientID = dict["CLIENT_ID"] as? String


        //nu kan vi skicka in våra options när vi anropar .configure
        FirebaseApp.configure(options: options)
    }
}

@main
struct FirebaseConfigExampleApp: App {
    let persistenceController = PersistenceController.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
//    init() {
//            configureFirebase()
//        }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    
}
