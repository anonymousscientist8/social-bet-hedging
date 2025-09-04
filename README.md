## Social uncertainty influences the optimal balance of quantity and quality of cooperative relationships

# Decscription
This project looked to model the behavior of the common vampire bat, looking to realistically simulate roost switching, foraging, allogrooming, food sharing, reproduction, birth, and death. By doing so, we hoped to investigate how manipulating social uncertainty via average roost switching rate influenced the evolution of more diversifying (i.e., investment into quantity of relationships) or focusing (i.e., investment into quality of relationships) allogrooming strategies. Included here are NetLogo behaviorspace output files showing the number of bats using each of six genetically-determined allogrooming strategies, as well as R code used to process this data and create figures.

# File summaries and instructions

All necessary R packages and NetLogo extensions are listed at the top of each R and NetLogo file, respectively. Filepaths will need to be edited to properly run code.

"food_sharing_donations_2010-2014.csv" is a data file showing instances of bats donating blood after fasting trials in a captive colony, observed between 2010 and 2014. Here, date refers to the date of donation, donor is the name of the donor, receiver is the name of the receiver, and donation.sec is the time, in seconds, that donations took place. Trial refers to the order of fasting trials. "average_weight_given.R" takes this data file and finds the average amount each bat donated per day in percent body weight.

"social_bet_hedging21 experiment-spreatsheets" each show the output of a set of simulation runs, each performed by behaviorspace in NetLogo. These also include dates and order of runs on that dates. For example, "social_bet_hedging21 experiment-spreadsheet_10jul24_1.csv" is the first batch of simulations run on July 10, 2024. Inlcuded here is the name of the NetLogo file ("social_bet_hedging21.nlogo"), the size of the in-simulation space (minimum and maximum x and y coordinates), run numbers, and the generalized, editable model paratmeters, including "roost-switch?" (whether roost switching was possible), social-pref? ("whether bats decided where to roost based on social preferences), "social-inheritance" (whether the child inherits its mother's preferences), "social-inheritance2" (whether a child inherits it's mother's friends' preferences towards the mother), "cheating" (whether bats will choose not to feed non-kin), "p_die" (probability of being killed while foraging), "limit" (maximum number of fully grown bats in each roost), "foraging" (daily foraging success rate), "decay" (amount of relationship score deterioration per day), "modifier" (an additive that modifies roost switching rate), "discriminatory" (food-sharing in-group bias control), "threshold" (coroosting in-group bias control), "share-boost" (how much each food-sharing event improves relationship score), "share-decline" (how much each rejected food-sharing event decreases relationship score), "groom_give" (how much relationship score can improve across all groomed partners summed per day), "donations" (how many food-sharing donations can be given per day), "amount" (how large food sharing donations are in percent body weight), "strats" (the number of different allogrooming strategies). For this, only "modifier", "threshold", and "discriminatory" changed between trials (-1, 0, and 1 for "modifier", 0 and 1200 for "threshold", and 30, 50, and 70 for "discriminatory"). These files also include time steps for each trial, which can be used to determine if the population survived to 200 years (72,999 days, or time steps). Finally, the file show, for each simulation, how many bats were pink ("Diversifying 3" in the paper), violet ("Diversifying 2"), green ("Diversifying 1"), yellow ("Focusing 1"), blue ("Focusing 2"), and yellow ("Focusing 3").

"empirical.csv" (available at https://zenodo.org/records/15633665) is a similar spreadsheet looking at population size at every time step for randomly generated simulations across all scenarios with empirical roost switching rate. "roost_size.R" takes "empirical.csv" and finds average roost size for each simulation. This was not directly used in the paper except to verify that the average roost size is close to the roost limit.

"social_bet_hedgning21.nlogo" uses the parameters described above to simulate bats foraging for food, roost switching, grooming, food sharing, dying, and giving birth, with each submodel parameterized by published vampire bat data. It outputs "social_bet_hedging21 experiment-spreatsheets" via behaviorspace, as described above. For a more detailed explanation of the model, see the associated manuscript.

"strategies.R" serves two parts. The first chuck of "strategies3.R" requires that the proper "social_bet_hedging21 experiment spreadsheet" is manually entered into the code itself, including the filename. The spreadsheet itself must also be edited so only a single line showing all final population sizes in order of pink, magenta, violet, blue, green, and yellow (deleted first column and above rows in each of the spreadsheets). This creates a file called "temp.csv". Each of these temporary data files were manually combined to create "strategies3.csv", which includes "SocialInheritance1" and "SocialInheritance2" (see above "social-inheritance" and "social-inheritance2", "GroupSize" (how many adult bats can be in a roost at one time), "Foraging" (adult foraging success rate), "Predation" (daily probability of predation), "Threshold", "Discriminatory", and "Modifier" (see above for description), "Pink", "Magenta", "Violet", "Blue", "Green", and Yellow" (all of which show final populations for different allogrooming strategies, see above), "PopBust?" (whether the maximum number of adult bats were ever in the simulation), "Focusing" (the number of bats who could groom up to 4 bats a day), "Neutral" (the number of bats who could groom up to 8 bats a day), "Diversifying" (the number of bats who could groom up to 12 bats a day), "Equitable" (the number of bats who groomed all bats equally daily), "Inequitable" (the number of bats who groomed more familiar bats preferentially more), and "Average" (the average number of potential bats groomed per day). For the data included in the associated manuscript, a group size of 6, no social inheritance, predation rate of 0.0003, and foraging success rate of 0.93 were exclusively used.

"strategies3.csv" is uploaded to the second part of "strategies.R." This code filters the code and plots the distribution of grooming strategies for each of the 18 scenarios. These plots are not used in the paper. "fixation_check.R" uses "strategies3.csv" to determine what percentage of simulations only had one strategy remaining after 200 years.

"create_Fig1.R" shows the typical investment distribution for simulated vampire bats when there are 12 available other bats to groom. "create_Fig2.R" uses "strategies3.csv" to create a graph showing the number of bats using each of the 6 allogrooming strategies across all 18 scenarios. Similarly, "create_Fig3.R" uses "strategies3.csv" to create a figure showing how the average number of daily potential bats groomed changes as grooming rate ("modifier") changes across all 18 scenarios. "create_FigS1.R" models the foraging success rate of virtual vampire bats, "create_FigS2.R" models the simulated bats' growth curve, and "create_FigS3.R" shows the relationship between weight and time until starvation for the virtual bats.

# References

G. G. Carter, D. R. Farine DR, R. J. Crisp, J. K. Vrtilek, S. P. Ripperger, R. A. Page, Development of new food-sharing relationships in vampire bats. Curr. Biol. 30,1275–1279 (2020). 

G. G. Carter, L. Leffer, Social grooming in bats: are vampire bats exceptional? PLoS One. 10 (2015). 

R. F. Crespo, R. J. Burns, S. B. Linhart, Load-lifting capacity of the vampire bat. J. Mammal. 51, 627–629 (1970). 

U. Schmidt, U. Manske, Die Jugendentwicklung der Vampirfledermäuse (Desmodus rotundus). Z. Säugetierkd. 38, 14–33 (1972). 

U. Schmidt, Vampirfledermäuse : Familie Desmodontidae (Chiroptera). (Die neue Brehm-Bücherei, 1978). 

G. S. Wilkinson, Reciprocal food sharing in the vampire bat. Nature. 308, 181–184 (1984). 

G. S. Wilkinson, The social organization of the common vampire bat: I. pattern and cause of association. Behav. Ecol. Sociobiol. 17, 111–121 (1985). 

G. S. Wilkinson, The social organization of the common vampire bat: II. Mating system, genetic structure, and relatedness. Behav. Ecol. Sociobiol. 17, 123–134 (1985). 

G. G. Carter, G. S. Wilkinson, Social benefits of non-kin food sharing by female vampire bats. Proc. R. Soc. B Biol. Sci. 282 (2015).

H. A. Delpietro, R. G. Russo, G. G. Carter, R. D. Lord, G. L. Delpietro, Reproductive seasonality, sex ratio and philopatry in Argentina’s common vampire bats. R. Soc. Open Sci. 4 (2017). 

I. Razik, B. K. G. Brown, R. A. Page, G. G. Carter, Non-kin adoption in the common vampire bat. R. Soc. Open Sci. 8 (2021). 

I. Razik, B. K. G. Brown, G. G. Carter, Forced proximity promotes the formation of enduring cooperative relationships in vampire bats. Biol. Lett. 18 (2022). 

C. R. A. Hartman, G. S. Wilkinson, I. Razik, I. M. Hamilton, E. A. Hobson, G. G. Carter, Hierarchically embedded scales of movement shape the social networks of vampire bats. Proc. R. Soc. B Biol. Sci. 291 (2024). 

G. G. Carter, Co-option and the evolution of food sharing in vampire bats. J. Ethol. 127, 837–849 (2021). 
