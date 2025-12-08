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
