# Project Overview

## What the Application Does
This is a Flutter application called "pokeflutter" that serves as a Pokédex - a digital encyclopedia for Pokémon. The app displays a grid of Pokémon fetched from the PokéAPI, showing their names, types, and sprites. Users can browse through the list of Pokémon, with each item colored according to its primary type.

## Main Purpose
The primary purpose is to provide an interactive Pokédex experience on mobile devices, allowing users to explore Pokémon information in a visually appealing interface.

## Main Technologies Used
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **HTTP**: For API communication with PokéAPI
- **flutter_screenutil**: For responsive design
- **google_fonts**: For typography
- **flutter_svg**: For vector graphics (pokeball icons)

## Flutter Architecture Style
The application follows a basic Flutter architecture without advanced patterns like Clean Architecture, MVVM, or feature-based organization. It uses simple Stateful and Stateless widgets with setState for state management. The code is organized into basic folders (model, utils, views) but lacks clear separation between business logic and UI.