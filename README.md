# Guide för att hantera GoogleService-Info.plist (och andra känsliga filer) på Github

Som många av er har märkt så kan github vara lite kinkig när det gäller vissa filersom innehåller känslig data som API nycklar mm. 
En sådan fil är GoogleService-Info.list. Denna fil behövs ju (eller?) för att vi ska kunna ansluta vår app till firebase.

I denna lilla guide tänkte jag gå igenom ett par sätt man kan hantera det på, samt vad man kan göra om skadan redan är skedd.

## Metod 1. Lägga till GoogleService filen i .gitignore

Detta är förmodligen den enklaste och vanligaste metoden är att helt enkelt lägga GoogleService-Info.list i .gitignore innan den hamnar på github.


1. Skapa ett nytt iOS projekt och lägg till firebase SDK.
2. Skapa en .gitignore fil i projektets rotmapp och lägg till de filer du vill ignorera
<details>
<summary> <B>Exempel på .gitignore för swift (kopiera gärna denna till era egna projekt)</B> </summary>
  
 ```gitgnore

# Xcode
DerivedData/
*.xcuserstate
*.xcworkspace
*.xcsettings
!default.xcworkspace
*.xcodeproj/project.xcworkspace/
*.xcodeproj/xcuserdata/
*.xcodeproj/xcshareddata/WorkspaceSettings.xcsettings
*.pbxuser
*.mode1v3
*.mode2v3
*.perspectivev3

# SwiftPM
.build/
Package.resolved

# User-specific
*.swp
*.lock
*.DS_Store
*.idea/
*.moved-aside
*.xcuserdatad/
*.orig

# Playgrounds
timeline.xctimeline
playground.xcworkspace

# CocoaPods
Pods/
Podfile.lock

# Carthage
Carthage/Build/

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output

# Firebase / Hemligheter
Secrets.plist
GoogleService-Info.plist

# XCFrameworks
*.xcframework

# SPm artifact cache
.swiftpm/xcode/package-artifacts/

# Asset catalog compilations
*.xcassets

# Environment files
.env
*.env

# Simulator logs and caches
coreSimulator/

  
```
  
</details>

3. skapa/hitta ett firebase projekt du vill ansluta din iOS app till.
4. Ladda ner GoogleService-Info.plist filen och lägg i rotmappen på ditt projekt
5. initiera git i xcode (eller via terminalen)
6. lägg till remote och pusha upp till github
<details>
<summary> <B>GoogleService-Info.plist hamnar ändå på github?!</B> </summary>
  <b>Varför blir det så?</b><br>
  Git trackar (spårar) filerna i vårat repo för att kunna lyssna efter ändringar i våra filer. Gitignore-filen talar om för git att "dessa filer vill jag inte spåra". <br> Men om en fil redan spåras av git så spelar det ingen roll att vi lagt den i .gitignore, den trackas ändå. 
  Ibland, särskilt när vi lägger till externa filer som ex. drag-drop en GoogleService-Info.plist från filsystemet in i projektet, så blir det ett synkningsfel mellan gits spårning och vår .gitignore så att git börjar spåra filen innan .gitignore har hunnit säga ifrån.
  Om du märker att filen spåras (filen syns när du kör git status eller att du ser att xcode vill stagea filen) så behöver du explicit tala om för git att sluta spåra INNAN du commitar och pushar upp till github.

  
  Detta gör du via terminalen: 
  
  <ul>
    <li> öppna terminalen/bash i projektets rotmapp.</li>
    <li> kör följande git kommando:
  
   ```bash
   git rm --cached GoogleService-Info.plist
   ```
--cached gör så att filen tas bort från gits spårning, men finns fortfarande kvar på själva datorn 
</li>
<li>se till så filen ligger korrekt i .gitignore:
  
   ```bash
   GoogleService-Info.plist
   ```
eller om den inte ligger i roten utan i en undermapp:

   ```bash
   MinMapp/GoogleService-Info.plist
   ```
</li>
<li> gör sen en commit, annars kommer inte ändringen gälla.
  
```bash
  git commit -m "Remove GoogleService-Info.plist from repo"
```
</li>
<li> Nu bör du kunna pusha upp till github utan att filen följer med</li>
  </ul>
  
</details>

---
## Metod 2. konfigurera firebase utan GoogleService-Info.plist
Ett annat sätt att slippa oroa sig för GoogleService-Info.plist är att inte ha nån över huvud taget. Man kan köra konfigurationen programmtiskt istället. Kodexempel för det finner du i projektet ovan, men jag lägger de viktiga bitarna här.

1. Skapa ett nytt iOS projekt och lägg till firebase SDK.
2. Skapa en fil där du vill lagra hemliga varibler. I exemplet har jag skapat en Secrets.plist, men det går att t.ex använda en strukt eller klass istället.
3. Skapa en .gitignore fil i projektets rotmapp och lägg till de filer du vill ignorera (dvs där vi kommer ha våra hemliga variabler)
4. skapa/hitta ett firebase projekt du vill ansluta din iOS app till.
5. Ladda ner GoogleService-Info.plist filen men lägg INTE till den i ditt projekt. Istället öppnar du den och extraherer de värden du behöver och lägger in i dina hemliga variabler (secrets.exempel.plist listar de som jag använt i exemplet ovan)
6. följ instruktioner på firebase med kodexemplen du behöver för att konfigurera firebase i swiftUI
7.
```swift
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {         
          FirebaseApp.configure()
          return true
  }
```
raden FirebaseApp.configure() letar efter GoogleService-Info.plist och använder den för konfiguration. Vi kan byta ut den mot en funktion där vi skapar ett FirebaseOptions objekt som vi kan använda istället.
Vi skapar en ny funtion i AppDelegate:

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
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


        //nu kan vi skicka in våra options när vi anropar FirebaseApp.configure()
        FirebaseApp.configure(options: options)
    }
}
```

8. <B>OBS!</B> Vissa firebasefunktioner som exempelvis Google Analytics vill fortfarande ha en GoogleService-Info.plist, så denna metod funkar inte i dessa fall   
