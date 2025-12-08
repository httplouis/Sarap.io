# Sarap.io

**Author:** Rosales, Jose Louis D.  
**Course:** M065-ITWM105

## About

Sarap.io is a recipe application designed to provide users with an extensive collection of recipes, social interaction, and personalized cooking assistance. The app connects to a Supabase backend for database storage and integrates TheMealDB API to fetch recipes dynamically. It features an AI chatbot that aids users in searching recipes via keywords with a fallback mechanism if the API fails. The app enhances user experience by reading recipes aloud with adjustable voice speed, allowing hands-free operation. It also includes a social media feed for users to share and explore recipes from others, a profile page for user statistics, and settings for customization.

## Project Scope and Limitations

### Core Functionalities

The app covers core functionalities such as:

- Viewing and managing a personal recipe collection
- Searching and fetching external recipes from TheMealDB API
- AI chatbot for recipe search with a keyword-based fallback
- Voice read aloud functionality when viewing recipes and ingredients
- Social feed to upload and view recipes from other users
- User profile with stats and customization options like voice speed
- Notification system and ability to add new recipes

### Limitations

Limitations include:

- **Offline Use:** Limited since fetching recipes depends a lot on the availability of the API, so without internet, new recipes can't be loaded
- **AI Chatbot:** Works well with predefined keywords for searching recipes as a fallback, but it can't fully understand all user questions yet
- **Authentication & Social Features:** User authentication and social features in the app are basic and simulated, so they aren't fully secure or packed with all possible social functions
- **Voice Settings:** The voice read aloud speed adjustment only works inside the app itself and doesn't affect other system-wide voice settings

## Features

### Home Screen / Recipe List
Displays a list of available recipes with search and filtering options such as under 30 minutes, vegetarian, favorites, region, and cuisine tags.

### Recipe Detail View
Shows detailed recipe information including ingredients, cooking steps, photos, and interactive favorite/unfavorite buttons.

### AI Chatbot Screen
Enables users to type recipe-related questions like "how to cook adobo", triggering either an API fetch or keyword-based responses displaying relevant recipes.

### Voice Read Aloud Feature
When viewing recipe ingredients or steps, the app reads the text aloud with adjustable speed, enhancing hands-free cooking convenience.

### Social Feed Screen
Users can scroll through posts with images, captions, likes, comments, and ratings shared by other users, with an option to add a new post.

### Profile Page
Displays user statistics such as number of recipes added, followers, and following count with user profile picture.

### Settings Page
Allows users to customize app preferences including the speed of voice read aloud.

### Add Recipe Screen
Form where users can input new recipes including title, ingredients, steps, cooking time, cuisine, and upload photos.

### Search Recipes
This feature lets users search for recipes by sending queries to TheMealDB API. It provides a variety of recipes from different cuisines, displayed with images and basic info, giving users more options beyond the local data.

### Notification System
Notifies users about relevant app updates or social interactions.

## Learning Reflection

### What I Learned from This Course

During this course, I learned a lot about building apps with SwiftUI. I got hands-on experience managing app data using ObservableObject, connecting to APIs, and working with real-time databases like Supabase. One thing I really liked about SwiftUI is how smooth and beautiful the animations are. It makes the app feel polished and easy to use. Since I have an iOS phone, I could easily relate to the platform and appreciate these design touches. This experience felt much more natural compared to my previous work with Kotlin, which didn't offer the same smoothness or ease of designing user interfaces.

### Challenges I Faced

One of the hardest parts was handling API calls that happen asynchronously, especially making sure the AI chatbot could still work even if the API failed. It was also tricky to keep the app data synced with the cloud backend smoothly. I've encountered a lot of errors in making my app.

### How I Addressed or Resolved These Challenges

To fix these problems, I first tried to understand what was causing them. I researched the issues online and learned more about the errors I was getting. After that, I added a keyword-based fallback for the chatbot to make sure it always gives some response. I also used ObservableObject to keep the app's UI updated automatically, and I connected the app to Supabase to handle data reliably.

### Areas I Still Need to Improve or Skills I Want to Learn

I want to get better at working with APIs and making smarter chatbots that are not just keyword-based. I also hope to learn more about secure user logins, social features, and improving voice features for accessibility. I'm interested in exploring more of what Swift can do because I really like how smooth and powerful iOS apps feel. Learning more about Swift and iOS development in general is important to me, since I love using my iPhone and want to create even better apps in the future. I have made my very first iOS application now.

## Technologies Used

- **SwiftUI** - Modern UI framework for iOS development
- **Supabase** - Backend database and real-time data synchronization
- **TheMealDB API** - External recipe data source
- **OpenAI API** - AI chatbot functionality
- **AVFoundation** - Voice read aloud feature

## Repository

Source: [https://github.com/httplouis/Sarap.io](https://github.com/httplouis/Sarap.io)

---

*Note: This is not the final and updated working system. Updated version will be provided later.*
