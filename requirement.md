# 🚀 Caply – AI Caption & Bio Generator (Flutter App)

Build a complete Flutter mobile application using Dart for an AI-powered app called **"Caply" (Caption & Bio Generator)**.

---

## ⚠️ Core Requirements

- Do NOT implement authentication (no login/signup)
- Do NOT store any user data (no database, no backend persistence)
- Keep the app lightweight and simple
- Focus only on UI + API-based generation
- Use **Groq API** for AI generation
- Store generated captions/bios **locally on device only when user clicks heart icon**
- Code should be **modular and production-ready**
- Use **advanced Dart features**

---

## 🎨 UI Instructions (IMPORTANT)

- Pull UI mockups from Stitch MCP server:  
  https://stitch.withgoogle.com/projects/9922308711618571341
- UI screens should **exactly match Stitch design**
- UI must be **adaptive & responsive**:
  - Small devices
  - Medium devices
  - Large devices
  - Tablets
- Use latest and best Flutter packages
- App name: **Caply**
- Package name: `com.vedica.labs.caply`

---

## 🎨 Design System

- Create a **global design system**
- Support:
  - Light Mode
  - Dark Mode
- Ensure consistency across all screens
- Use **Material Design 3 (Material You)**

---

## 📱 Screens to Implement

### 1. HomeScreen
- App title
- Buttons:
  - Generate Caption
  - Generate Bio
- Platform selector (chips)

---

### 2. InputScreen
- TextField (user input)
- Optional image picker (basic or UI only)
- Style selector (chips):
  - Professional
  - Funny
  - Aesthetic
- Generate button

---

### 3. LoadingScreen
- CircularProgressIndicator
- Text: **"Generating…"**

---

### 4. ResultScreen
- Display 2–3 generated captions/bios
- Each inside a Card widget  

**Actions:**
- Copy to clipboard  
- Regenerate  
- ❤️ Save locally (on heart click)

---

### 5. SettingsScreen
- Toggle switches:
  - Light/Dark Mode  
  - Haptic Feedback  

---

## 🧱 Architecture Requirements

Use clean folder structure:

lib/  
 ├── main.dart  
 ├── core/  
 │    ├── theme/  
 │    ├── utils/  
 ├── features/  
 │    ├── home/  
 │    ├── input/  
 │    ├── result/  
 │    ├── settings/  
 ├── widgets/  

- Use **Provider** or **Riverpod** for state management  
- Use **Navigator 2.0** or named routes  

---

## 🌐 AI Integration

Create a service file:  
`ai_service.dart`

### API: Groq AI

**Input:**
- User text  
- Platform  
- Style  

**Output:**
- 2–3 generated captions/bios  

---

## 🎨 Theme Requirements

- Implement:
  - `lightTheme`  
  - `darkTheme`  
- Use Material 3 color scheme  
- Enable dynamic theme switching  

---

## 📦 Packages to Use

- provider / flutter_riverpod  
- http or dio  
- flutter/services.dart (clipboard)  
- image_picker (optional)  
- google_fonts (optional)  

---

## ⚡ UX Requirements

- Smooth navigation  
- Minimal animations  
- Clean UI  
- Fast performance  

---

## 📐 Final Output

- Complete runnable Flutter app  
- Clean, well-commented code  
- Reusable widgets  
- Responsive UI across all devices  