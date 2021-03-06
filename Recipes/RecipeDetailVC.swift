//
//  RecipeDetailVC.swift
//  Recipes
//
//  Created by Marc Marlotte on 11/26/17.
//  Copyright © 2017 Marc Marlotte. All rights reserved.
//

import UIKit
import SafariServices

class RecipeDetailVC: UIViewController {
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeIngredients: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var defaultsData = UserDefaults.standard
    var recipeNamee: String?
    var recipeIngredient: [String] = []
    var recipeImageURL: String?
    var recipeIngredientString = ""
    var recipeInstructionWebsite: String?
    var favoritesArray: [String] = []
    
    var favRecipe = [FavRecipe]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlPicture()
        recipeName.text = recipeNamee
        self.navigationItem.title = self.recipeNamee
        printRecipeIngredients()
        recipeIngredients.text = recipeIngredientString
        loadLocations()
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func printRecipeIngredients() {
        for index in 0...recipeIngredient.count-1 {
            recipeIngredientString += "\(recipeIngredient[index])\n"
        }
    }
    
    //Set up picture using URL from JSON
    func urlPicture() {
        let imageURL = URL(string: recipeImageURL!)
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: imageURL!) { (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self.recipeImage.image = image
                        }
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume()
    }
    
    func saveDefaultsData() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(favRecipe) {
            defaultsData.set(encoded, forKey: "favRecipe")
        } else {
            print("ERROR: Saving encoded did not work")
        }
    }
    
    func loadLocations() {
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "favRecipe") as? Data else {
            print("**** Could not load locationsArray data from UserDefaults")
            return
        }
        let decoder = JSONDecoder()
        if let favRecipe = try? decoder.decode(Array.self, from: locationsEncoded) as [FavRecipe] {
            self.favRecipe = favRecipe
        } else {
            print("ERROR: Couldn't decode data")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddFavoritesSegue" {
            if let navController = segue.destination as? UINavigationController {
                if let childvc = navController.topViewController as? FavoriteRecipesVC {
                    childvc.favRecipeVC = favRecipe
                }
            }
        } else {
            print("Hello")
            }
        }
    
    @IBAction func viewInstructionsPressed(_ sender: UIButton) {
        let svc = SFSafariViewController(url: URL(string: recipeInstructionWebsite!)!)
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        self.favoriteButton.setTitle("Favorite", for: .normal)
        self.favoriteButton.tintColor = UIColor.init(red: 245/255, green: 105/255, blue: 35/255, alpha: 1.0)
        favRecipe.append(FavRecipe(recipeName: self.recipeNamee!, recipeIngredients: self.recipeIngredientString, recipeURL: self.recipeImageURL!, recipeImageURL: self.recipeImageURL!, recipeInstructionsURL: self.recipeInstructionWebsite!, randomRecipeChosenName: self.recipeNamee!))
        saveDefaultsData()
    }
    
}
