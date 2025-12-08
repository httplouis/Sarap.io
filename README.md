# Sarap.io 🍳

A comprehensive recipe application designed to provide users with an extensive collection of recipes, social interaction, and personalized cooking assistance.

**Author:** Rosales, Jose Louis D. | **Course:** M065-ITWM105

![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-blue?style=flat-square&logo=swift)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green?style=flat-square&logo=supabase)
![iOS](https://img.shields.io/badge/iOS-17.0+-lightgrey?style=flat-square&logo=apple)

---

## 📱 Overview

Sarap.io is a modern iOS recipe application that connects to a Supabase backend for database storage and integrates TheMealDB API to fetch recipes dynamically. The app features an AI chatbot that aids users in searching recipes via keywords with a fallback mechanism, voice read-aloud functionality with adjustable speed for hands-free operation, and a social media feed for users to share and explore recipes.

## ✨ Key Features

- 🏠 **Recipe Collection** - View and manage your personal recipe collection with search and filtering options
- 🔍 **Smart Search** - Search and fetch external recipes from TheMealDB API with AI-powered chatbot assistance
- 🤖 **AI Chatbot** - Recipe search with keyword-based fallback mechanism for reliable responses
- 🔊 **Voice Read Aloud** - Hands-free cooking with adjustable voice speed when viewing recipes and ingredients
- 👥 **Social Feed** - Upload and view recipes from other users with likes, comments, and ratings
- 👤 **User Profile** - Track your statistics including recipes added, followers, and following count
- ⚙️ **Customization** - Adjust app preferences including voice speed and other settings
- 📝 **Add Recipes** - Create and share your own recipes with photos, ingredients, and cooking steps
- 🔔 **Notifications** - Stay updated with relevant app updates and social interactions

## 🛠️ Technology Stack

- **Frontend:** SwiftUI 5.0, Swift 5.9
- **Backend:** Supabase (PostgreSQL) for database storage and real-time synchronization
- **APIs:** TheMealDB API for external recipe data, OpenAI API for AI chatbot functionality
- **Voice:** AVFoundation for text-to-speech and voice read-aloud features
- **Platform:** iOS 17.0+

## 📋 Project Scope

### Core Functionalities

- ✅ Viewing and managing a personal recipe collection
- ✅ Searching and fetching external recipes from TheMealDB API
- ✅ AI chatbot for recipe search with keyword-based fallback
- ✅ Voice read-aloud functionality when viewing recipes and ingredients
- ✅ Social feed to upload and view recipes from other users
- ✅ User profile with stats and customization options
- ✅ Notification system and ability to add new recipes

### Limitations

- ⚠️ **Offline Use:** Limited since fetching recipes depends on API availability
- ⚠️ **AI Chatbot:** Works with predefined keywords but can't fully understand all user questions yet
- ⚠️ **Authentication:** Basic and simulated user authentication and social features
- ⚠️ **Voice Settings:** Speed adjustment only works within the app, not system-wide

## 🎓 Learning Reflection

### What I Learned

During this course, I learned a lot about building apps with SwiftUI. I got hands-on experience managing app data using ObservableObject, connecting to APIs, and working with real-time databases like Supabase. One thing I really liked about SwiftUI is how smooth and beautiful the animations are. It makes the app feel polished and easy to use. Since I have an iOS phone, I could easily relate to the platform and appreciate these design touches. This experience felt much more natural compared to my previous work with Kotlin.

### Challenges Faced

One of the hardest parts was handling API calls that happen asynchronously, especially making sure the AI chatbot could still work even if the API failed. It was also tricky to keep the app data synced with the cloud backend smoothly. I've encountered a lot of errors in making my app.

### How I Resolved These Challenges

To fix these problems, I first tried to understand what was causing them. I researched the issues online and learned more about the errors I was getting. After that, I added a keyword-based fallback for the chatbot to make sure it always gives some response. I also used ObservableObject to keep the app's UI updated automatically, and I connected the app to Supabase to handle data reliably.

### Areas for Improvement

I want to get better at working with APIs and making smarter chatbots that are not just keyword-based. I also hope to learn more about secure user logins, social features, and improving voice features for accessibility. I'm interested in exploring more of what Swift can do because I really like how smooth and powerful iOS apps feel. Learning more about Swift and iOS development in general is important to me, since I love using my iPhone and want to create even better apps in the future. **I have made my very first iOS application now.**

## 📸 Screenshots

*Screenshots will be added in the updated version*

## 🔗 Repository

**Source:** [https://github.com/httplouis/Sarap.io](https://github.com/httplouis/Sarap.io)

---

> **Note:** This is not the final and updated working system. Updated version will be provided later.
