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
  # How do they list positions?
    roster$position %>% unique()
    # Poorly
  # How many and who plays 'D/RW'?
    roster %>% filter(position == 'D/RW')
    # Brent Burns who hasn't play RW Since joining San Jose
  # Up dating Brent Burns potions 
    roster[roster$player == 'Brent Burns', 'position'] <- 'D'
  # check
    roster[roster$player == 'Brent Burns', ]
  # Who are the forwards (f)?  
    roster %>% filter(position == 'F')
    # kind of weird, what makes them get F rather than positions, there hockeydb have them as potions. My guess would be the frequency
    # at which they play across all the forward postions.
    
  # lets find the players that where traded during the year. They should be the ones to show up more than once
    traded <- roster %>% get_dupes(player)
  # but what if players share a name (we know this is the case from the sample code)
    traded %>% group_by(player) %>% 
      mutate(n_distinct = n_distinct(birth_date, height, weight)) %>% # changes of players having the same name, birth day, height and weight are very small
      filter(n_distinct == 2) %>% select(!n_distinct)
  # shows two players share the name Sebastian Aho, let remove it from the traded subset as if we didn't know the name
  # or if there might be more
    traded <- traded %>% filter(player != traded %>% group_by(player) %>% 
                                          mutate(n_distinct = n_distinct(birth_date, height, weight)) %>% 
                                          filter(n_distinct == 2) %>% select(player) %>% unique() %>% as.character()
                        )
  # was any one traded more than once? would show up more than twice.
    traded %>% group_by(player) %>% count() %>% filter(n > 2) %>% select(player)
  # Greg Pateryn, checek elite propects he had a busy travel year, https://www.eliteprospects.com/player/15526/greg-pateryn#transactions
    
    
    
# Now I'm just going to look at the one game Edmonton (EDM) Vs Toronto (TOR) (Go Leafs Go!!)
  # filter just take all events where home team is EDM 
    pbp_mini <- pbp %>% filter(home_abbreviation == 'EDM')
  # and where players are just from EDM or TOR
    teams <- c("EDM", "TOR")
    roster_mini <- roster %>% filter(team_abbr %in% teams)
  # how many players did each team use for the year?
    roster_mini %>% group_by(team_name) %>% count()
  # you can only use 20 on a given night (including a backup goalie who might not play). 
  # So who where the players for the data we have?
    # players
      players <- pbp_mini %>% select(grep('home_on|away_on|home_goalie|away_goalie', pbp_mini %>% colnames(), value = TRUE)) %>%
                  gather(value = 'player') %>% select(player) %>% unique() %>% na.omit()
    # for fun lets join with position, team and number for roster mini
      # format up roster_mini
        roster_mini <- roster_mini %>% select(player, team_name, position, number)
      # from the sample code roster mini to be same as player names in pbp (from sample code)
        roster_mini <- roster_mini %>% mutate(player = str_replace_all(player, " ", "."),
                                              player = str_replace_all(player, "-", "."),
                                              player = str_replace_all(player, "'", "."))
      # join to players to just get the player who played this game (from sample code we also know names we'll be different)
        # see players with miss match names
          players %>% left_join(roster_mini, by = 'player') %>% filter(is.na(number))
        # we get 'TJ.Brodie' and 'Mitchell.Marner'        
        # find them in roster_mini, with some kdogle we know both play for Toronto and there numbers are 16 and 78
          roster_mini %>% filter(team_name == 'Toronto Maple Leafs') %>% filter(number == '16' | number == '78')
        # gives 'T.J..Brodie' and Mitch.Marner. For Marner they used Mitch for roster but play by play use Mitchell easy fix
          roster_mini <- roster_mini %>% mutate(player = case_when(player == "Mitch.Marner" ~ "Mitchell.Marner", TRUE ~ player))
        # For Brodie we can do the same but be fore i would like to see if we can change string rplacing to work.
        # the problem would be with other players with the same or similar naming convocation, like TJ oshie
        # Oshie 77 for the Washington Capitals, lets find him in the roster list
          roster %>% filter(number == '77' & team_name == 'Washington Capitals')
        # save this and put the same formate as we did above
          Oshie <- roster %>% filter(number == '77' & team_name == 'Washington Capitals')
          Oshie <- Oshie %>% mutate(player = str_replace_all(player, " ", "."),
                                    player = str_replace_all(player, "-", "."),
                                    player = str_replace_all(player, "'", "."))
          Oshie$player
        # finding how his name is on pbp (quickiest way to to simple search for Oshie in the viewer), as an exercise we'll code it
          pbp %>% filter(if_any(home_on_1:away_on_7, ~ str_detect(.,'Oshie'))) %>% head(1) %>% select(home_on_1:away_on_7) %>%
            select_if( ~ any(str_detect(.,"Oshie"))) %>% as.character()
        # creating a little data.frame to better view
          TJs <- data.frame (pbp_name  = c(pbp %>% filter(if_any(home_on_1:away_on_7, ~ str_detect(.,'Oshie'))) %>% head(1) 
                                            %>% select(home_on_1:away_on_7) %>%
                                            select_if( ~ any(str_detect(.,"Oshie"))) %>% as.character(),
                                           players %>% filter(str_detect(player, 'Brodie')) %>% as.character()),
                             roster_name = c(roster %>% filter(number == '77' & team_name == 'Washington Capitals') %>% 
                                               select(player) %>% as.character(),
                                             roster %>% filter(number == '78' & team_name == 'Toronto Maple Leafs') %>% 
                                               select(player) %>% as.character()))
          # seems to be no constancy Oshie's pbp removes the space and adds the period
          # Brodie's pbp removes the period's from the TJ section and still removes the space and adds the period
          # In the future may look at other names like this and if its the same each game
          
        # Back to fixing up the roster dataframe
          roster_mini <- roster_mini %>% mutate(player = case_when(player == "T.J..Brodie" ~ "TJ.Brodie", TRUE ~ player))
          
          
         