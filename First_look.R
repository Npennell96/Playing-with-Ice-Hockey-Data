## My own look at the data from Meghan Hall's talk and slides on Hockey data
## Link: https://meghan.rbind.io/talk/ucsas/

# Packages
  library(tidyverse) # data cleaning
  library(janitor) # data cleaning
  library(hockeyR) # hockey data
  library(sportyR) # good for plotting sports data
  
# get play by play data
  # downloading
    # pbp <- scrape_day(day = "2021-02-27")
  # save for future time save
    # save(pbp, file = 'pbp.Rda')
  # Load
    load('pbp.Rda')
    
# Get rosters 
  # downloading
    # roster <- get_rosters(team = "all", season = 2021)
  # save for future time save
    # save(roster, file = 'roster.Rda')
  # Load
    load('roster.Rda')
    
# Looking at pbp
  # Column names
    pbp %>% colnames()
  # Teams that played
    pbp$event_team %>% unique()
  # Who played who?
    pbp %>% distinct(home_name, .keep_all = TRUE) %>% distinct(away_name, .keep_all = TRUE) %>% select(c('home_name', 'away_name'))
    # a quick Google conforms it (https://www.google.com/search?channel=fs&client=ubuntu&q=nhl+february+27+2021) 
    # beware of dates, based on country games where 27/02 in Canada but for me would have been 26/02 in Australia

# Look ar roster
  # Column names
    roster %>% colnames()
  # How do they lisy Postions?
    roster$position %>% unique()
    # Poorly
  # How many and who plays 'D/RW'?
    roster %>% filter(position == 'D/RW')
    # Brent Burns who hasn't play RW Since joining San Jose
  # Up dating Brent Burns potions 
    roster[roster$player == 'Brent Burns', 'position'] <- 'D'
  # check
    roster[roster$player == 'Brent Burns', ]
  # How many players in 2021 had the same name?
    test <- roster %>% 
      filter(player %in%
        list(
          roster %>% distinct(player, .keep_all = FALSE)
        )
      )
    
    
# I'm just going to look at the one game Edmonton (EDM) Vs Toronto (TOR) (Go Leafs Go!!)
  # filter just take all events where home team is EDM 
    pbp_mini <- pbp %>% filter(home_abbreviation == 'EDM')
    
    
    
    
    
    
    