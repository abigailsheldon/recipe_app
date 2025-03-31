# Recipe App

A Flutter-based mobile application that helps users browse and manage recipes, view detailed recipe information, and create grocery lists—all with a retro pixel-art aesthetic.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture & Code Structure](#architecture--code-structure)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Testing](#testing)
- [Future Enhancements](#future-enhancements)
- [Team](#team)
- [License](#license)

## Overview

The Recipe App is designed to simplify the process of finding, saving, and preparing recipes. It allows users to:
- Browse a list of recipes loaded from an Excel file into an SQLite database.
- Filter recipes by category (supports multiple tags, e.g., "keto, paleo").
- View detailed recipe information including a grocery list.
- Mark recipes as favorites and quickly access them.
- Check off individual ingredients and add them to a global grocery list.

The app features a unique pixel-art user interface and uses Provider for state management.

## Features

- **Main Menu:**  
  Navigate between different sections: Recipe Menu, Grocery List, and Favorite Recipes.

- **Recipe Menu:**  
  - Browse a list of recipes presented in a pixel-art style.
  - Filter recipes by category (with support for multiple comma-separated tags).
  - Mark/unmark recipes as favorites.
  - Tap on a recipe to view detailed information.

- **Recipe Details:**  
  - Display full details of a selected recipe, including category, description, and date.
  - Navigate to the grocery list for that recipe.

- **Grocery List:**  
  - View ingredients for a selected recipe.
  - Check off individual ingredients or use an “Add All” option.
  - Manage a global list of ingredients across recipes.

- **Favorite Recipes:**  
  - View all recipes marked as favorites.
  - Tap a recipe to see its full details.

## Architecture & Code Structure

The project is structured as follows:

- **main.dart:**  
  Entry point of the application. Initializes the database and global providers for the app.

- **db_helper.dart:**  
  Manages the SQLite database operations. Loads recipes from an Excel file, performs CRUD operations, and handles duplicate checks.

- **grocery_list_model.dart:**  
  A ChangeNotifier model that maintains the list of selected grocery ingredients, updating the UI whenever changes occur.

- **UI Pages:**  
  - **recipe_menu.dart:** Displays the list of recipes with filtering options and navigation to details.
  - **recipe_details.dart:** Shows complete details for a selected recipe.
  - **grocery_list.dart:** Renders a list of ingredients with checkboxes for selection.
  - **collected_grocery_list.dart:** Aggregates and displays the global grocery list.
  - **favorite_menu.dart:** Displays recipes marked as favorites.
  - **pixel_recipe_card.dart:** Custom widget for rendering a recipe preview in a pixel-art style.
  - **styles.dart:** Contains shared styling constants used across the application.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- A device or emulator for running Flutter apps
- An Excel file (named `Recipe_table.xlsx`) placed in the assets folder containing your recipe data

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/abigailsheldon/recipe_app.git
   cd recipe_app
