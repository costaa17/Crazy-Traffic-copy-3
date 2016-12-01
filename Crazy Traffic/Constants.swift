//
//  Constants.swift
//  Crazy Traffic
//
//  Created by Daniel Weber on 4/1/16.
//  Copyright © 2016 Ana Vitoria do Valle Costa. All rights reserved.
//

import UIKit

let DEBUG_MODE: Bool = false

let FONT_NAME = "Lane - Narrow"
let FONT_NAME_BOLD = "Lane - Bold"

let FONT_SIZE_XL: CGFloat =  80.0   // Level num, Game Over text
let FONT_SIZE_L: CGFloat =   28.0   // Required points
let FONT_SIZE_M: CGFloat =   18.0   // Tutorial text, score
let LEVELS_PER_EPISODE: Int = 20
let MAX_EPISODE: Int = 3

// Colors
var DARK_COLOR = UIColor(hex: "#12110D")
var LIGHT_COLOR = UIColor(hex: "#FFFFFF")

var TUTORIAL_TEXT_COLOR = UIColor.white
var ROAD_COLOR = LIGHT_COLOR
var WALK_COLOR = UIColor.lightGray
let TIRE_TRACKS_COLOR = DARK_COLOR
var LEVEL_SELECT_COLOR = UIColor.darkGray
let LIFE_COLOR = UIColor.white
var PEDESTRIAN_COLOR = UIColor.white
var LEVEL_INTRO_COLOR = UIColor.black

 // Black Car
 var CAR_1_COLOR_BODY   = DARK_COLOR
 var CAR_1_COLOR_TOP    = UIColor.white
 var CAR_1_COLOR_WINDOW = UIColor.lightGray
 var CAR_1_COLOR_WHEEL  = DARK_COLOR
 var CAR_1_COLOR_STROKE = DARK_COLOR
 
 // White Car
 var CAR_2_COLOR_BODY   = LIGHT_COLOR
 var CAR_2_COLOR_TOP    = DARK_COLOR
 var CAR_2_COLOR_WINDOW = UIColor.lightGray
 var CAR_2_COLOR_WHEEL  = DARK_COLOR
 var CAR_2_COLOR_STROKE = DARK_COLOR


let FAST_CAR_MULT: CGFloat = 4.0
let SLOW_CAR_MULT: CGFloat = 0.0

let START_TIME_UPPER_BOUND: UInt32 = 3
let INTERVAL_MAX: UInt32 = 15
let INTERVAL_MIN: UInt32 = 5
let GARBAGE_INTERVAL_UPPER_BOUND = 20

// Z positions
let Z_LEVEL_VIEW: CGFloat               = 10.0 // Main level view that drops down
let Z_SCORE_LABEL: CGFloat              = 99.0 // The score, ped score, and high score labels (subnode of view)
let Z_TOGGLE_LEVEL_INFO_BUTTON: CGFloat = 20.0 // The level info button (subnode of view)
let Z_ROAD_PATH: CGFloat                = 30.0
let Z_WALK_PATH: CGFloat                = 40.0
let Z_CROSSWALK: CGFloat                = 50.0
let Z_TIRE_TRACKS: CGFloat              = 60.0
let Z_LEVEL_INFO_BACKGROUND: CGFloat    = 70.0 // The background for the level num, tutorial text, etc.
let Z_LEVEL_INFO_ITEM: CGFloat          = 71.0 // Exit button, level num, level goal, tutorial on level info screen
let Z_PATH_FOLLOWER: CGFloat            = 100.0 // Cars, people
let Z_GAMEOVER_VIEW: CGFloat            = 999.0

//Lives
let TIME_TO_LIFE = 10

//Facebook
let APP_LINK_URL = "https://fb.me/1851582171794942"
let APP_INVITE_IMAGE_URL = "https://scontent.fsnc1-1.fna.fbcdn.net/t31.0-8/14525082_551606115030443_8580495270661062994_o.png"

var friend = [Int]()
func maxLifeForEpisode(_ episode: Int) -> Int{
    switch episode {
    case 1:
        return 15
    case 2:
        return 20
    default:
        return 0
    }
}

func episodeTutorial(_ episode: Int) -> String{
    switch episode {
    case 1:
        return "Good jod! Seems like you learned how to play. For this episode you will have 7 lives and will get lives every 15 minutes. Use them carefully!"
    case 2:
        return "Did you know marine turtles die because they eat plastic bags thinking they are a jelly fishes? Although there are no turtles in the city, try to keep it clean. If you see a plastic bag tap it for an extra point. You will have a maximum of 20 lives for this episode."
        
    default:
        return ""
    }
}

func changeTheme(theme: String){
    switch theme {
    case "Halloween":
        DARK_COLOR = UIColor(hex: "#12110D")
        LIGHT_COLOR = UIColor(hex: "#f4ca86")
        WALK_COLOR = UIColor(hex: "#f4ca86")
        ROAD_COLOR = UIColor.orange
        LEVEL_SELECT_COLOR = UIColor.orange
        PEDESTRIAN_COLOR = UIColor.orange
        LEVEL_INTRO_COLOR = LEVEL_SELECT_COLOR
        TUTORIAL_TEXT_COLOR = UIColor.orange

        CAR_1_COLOR_BODY   = UIColor(hex: "#f4ca86")
        CAR_1_COLOR_TOP    = UIColor.black
        CAR_1_COLOR_WINDOW = UIColor.orange
        CAR_1_COLOR_WHEEL  = UIColor.black
        CAR_1_COLOR_STROKE = UIColor.black

        CAR_2_COLOR_BODY   = UIColor.black
        CAR_2_COLOR_TOP    = UIColor(hex: "#f4ca86")
        CAR_2_COLOR_WINDOW = UIColor.white
        CAR_2_COLOR_WHEEL  = UIColor.black
        CAR_2_COLOR_STROKE = UIColor.black
    default:
        DARK_COLOR = UIColor(hex: "#12110D")
        LIGHT_COLOR = UIColor(hex: "#FFFFFF")
        ROAD_COLOR = LIGHT_COLOR
        WALK_COLOR = UIColor.lightGray
        LEVEL_SELECT_COLOR = UIColor.darkGray
        PEDESTRIAN_COLOR = UIColor.white
        LEVEL_INTRO_COLOR = UIColor.black
        TUTORIAL_TEXT_COLOR = UIColor.white
        
        CAR_1_COLOR_BODY   = DARK_COLOR
        CAR_1_COLOR_TOP    = UIColor.white
        CAR_1_COLOR_WINDOW = UIColor.lightGray
        CAR_1_COLOR_WHEEL  = DARK_COLOR
        CAR_1_COLOR_STROKE = DARK_COLOR
        
        CAR_2_COLOR_BODY   = LIGHT_COLOR
        CAR_2_COLOR_TOP    = DARK_COLOR
        CAR_2_COLOR_WINDOW = UIColor.lightGray
        CAR_2_COLOR_WHEEL  = DARK_COLOR
        CAR_2_COLOR_STROKE = DARK_COLOR
    }
}

