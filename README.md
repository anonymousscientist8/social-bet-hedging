## Social uncertainty influences the optimal balance of quantity and quality of cooperative relationships

# Decscription
This project looked to model the behavior of the common vampire bat, looking to realistically simulate roost switching, foraging, allogrooming, food sharing, reproduction, birth, and death. By doing so, we hoped to investigate how manipulating social uncertainty via average roost switching rate influenced the evolution of more diversifying (i.e., investment into quantity of relationships) or focusing (i.e., investment into quality of relationships) allogrooming strategies. Included here are NetLogo behaviorspace output files showing the number of bats using each of six genetically-determined allogrooming strategies, as well as R code used to process this data and create figures.

# File summaries and instructions

All necessary R packages and NetLogo extensions are listed at the top of each R and NetLogo file, respectively. Filepaths will need to be edited to properly run code.

"food_sharing_donations_2010-2014.csv" is a data file showing instances of bats donating blood after fasting trials in a captive colony, observed between 2010 and 2014. Here, date refers to the date of donation, donor is the name of the donor, receiver is the name of the receiver, and donation.sec is the time, in seconds, that donations took place. Trial refers to the order of fasting trials. "average_weight_given.R" takes this data file and finds the average amount each bat donated per day in percent body weight.

"create_Fig1_v11.R"
