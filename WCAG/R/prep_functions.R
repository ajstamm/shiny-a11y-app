# author: Abby Stamm
# date: August 2024
# purpose: functions for sample dashboard

# penguin names and some other detail; diet = preferred and occasional
# swim speed = logic - prob = c(.01, .05, .25, .35, .25, .05, .03, .01)
# - gentoo: 
#   - diet: krill, shrimp, fish, squid; prob = c(.5, .3, .1, .1)
#   - swim speed: max 22mph 
# - chinstrap: 
#   - diet: krill, fish, squid, plankton, seal; prob = c(.6, .15, .15, .05, .05)
#   - swim speed: about 15-17mph, max 20mph 
# - adelie: 
#   - diet: krill, jellyfish, fish, amphipods, squid; prob = c(.4, .25, .25, .05, .05)
#   - swim speed: about 5mph 


describe_penguins <- function(d = NULL) {
  p <- if (is.null(d)) palmerpenguins::penguins_raw else d
  d <- feed_penguins(p) # add diets and swim speeds
  n <- name_penguins(d, var = "Sex") # add names
  f <- n |>
    dplyr::select(`Individual ID`, `Sample Number`, `studyName`, 
                  Name = name, `Favorite food` = fave_food, 
                  `Swim speed` = swim_speed) |> 
    unique()
  q <- p |> 
    dplyr::full_join(f) |>
    janitor::clean_names() |>
    dplyr::select(individual_id, study_name, sample_number,
                  dplyr::everything()) |> 
    dplyr::mutate(sex = ifelse(is.na(sex), "Unknown", 
                               tools::toTitleCase(tolower(sex))))

  return(q)
}

feed_penguins <- function(d) {
  swim_probs <- c(.01, .05, .25, .35, .25, .05, .03, .01)

  d <- d |> dplyr::select(`Individual ID`, `Sample Number`, `studyName`, 
                          species = Species, Sex) 
  
  g <- d |> dplyr::filter(grepl("Gentoo", species)) |> 
    dplyr::mutate(fave_food = sample(c("krill", "shrimp", "fish", "squid"),
                                     prob = c(.5, .3, .1, .1), size = 124, 
                                     replace = TRUE),
                  swim_speed = sample(15:22, prob = swim_probs, size = 124, 
                                      replace = TRUE))
  a <- d |> dplyr::filter(grepl("Adelie", species)) |> 
    dplyr::mutate(fave_food = sample(c("krill", "jellyfish", "fish", 
                                       "amphipods", "squid"),
                                     prob = c(.4, .25, .25, .05, .05), 
                                     size = 152, replace = TRUE),
                  swim_speed = sample(3:10, prob = swim_probs, size = 152, 
                                      replace = TRUE))
  c <- d |> dplyr::filter(grepl("Chinstrap", species)) |> 
    dplyr::mutate(fave_food = sample(c("krill", "fish", "squid", "plankton", 
                                       "seal"),
                                     prob = c(.6, .15, .15, .05, .05), 
                                     size = 68, replace = TRUE),
                  swim_speed = sample(13:20, prob = swim_probs, size = 68, 
                                      replace = TRUE))
  
  f <- dplyr::bind_rows(list(g, a, c)) 
  return(f)
}

name_penguins <- function(d, var = "Sex") {
  # Females ----
  female <- { c(
    # A-C ----
    "Amy", "Ali", "Ann", "Abi", "Agy", "Ada", "Ari", "Aya", "Adi",
    "Bri", "Bes", "Bea", "Bee", "Bae", 
    "Cat", "Chi", "Cho", "Cas", "Cay", 
    # D-F ----
    "Del", "Dot", "Dia", "Di", "Dea", 
    "Eta", "Eva", "Era", "Eve", "Ewe", "Em", "El", "Es",
    "Fae", "Fey", "Fly", "Flo", "Fia", "Fan", "Fam", "Fa",
    # G-I ----
    "Gin", "Gam", "Gem", "Glo", "Gia", "Gal", 
    "Hen", "Hel", "Hey", "Hae", "Haj", "Hi", "Hon", "Her", 
    "Ing", "Ida", "Ivy", "Icy", "Io", 
    # J-L ----
    "Jen", "Jan", "Joy", "Jun", "Jaz", "Jam", "Jin", 
    "Kim", "Kay", "Kat", "Kel", "Kes", "Kit", 
    "Lam", "Lin", "Liz", "Liv", "Lou", "Lia", "Lei", "La", "Lu",
    # M-O ----
    "May", "Meg", "Mol", "Mum", "Mae", "Mia", "Ma",
    "Nix", "Nan", "Nel", "Nia", "Nag", 
    "Ola", "Opa", "Ogg", "Oba", 
    # P-R ----
    "Pay", "Pri", "Pel", "Pia", "Pru", "Phi", "Pi", 
    "Qua", 
    "Rin", "Rae", "Rue", "Rho", "Roe", "Ran", "Ren", "Rhi", "Re", 
    # S-V ----
    "Sis", "Sue", "Spa", "Sea", "See", 
    "Tes", "Tie", "Tat", "Tru", "Tia", 
    "Una", "Uni", 
    "Ven", "Vi", "Via", 
    # W-Z ----
    "Wan", "Wen", "Wea", 
    "Xi", "Xis", 
    "Yas", "Yin", 
    "Zoe", "Zee") }
  male <- { c(
    # A-C ----
    "Abe", "Axe", "Asa", "Ace", "Art", "Alf", "Ask", "Ark", "Aba", "Add", 
    "Ben", "Bob", "Bai", "Bo", 
    "Cob", "Cub", "Cox", "Cad", "Cab", "Cap", "Cy", 
    # D-F ----
    "Den", "Don", "Dex", "Dag", "Dap", "Doc", "Dom", 
    "Eli", "Elm", "Emu", "Edy", "Eco", "Elk", "Eb", "Ed",
    "Fin", "Fox", "Fez", "Fab", "Fad", "Far", "Fix", 
    # G-I ----
    "Gay", "Guy", "Gad", "Gus", "Go", 
    "Har", "Hoy", "Hob", "Hap", "Hal", "Ho", "Ham", "Hao", "Has", "Hog", "Him",
    "Ian", "Inu", "Ira", "Ivo", "Ick", 
    # J-L ----
    "Jay", "Jet", "Jos", "Jeb", "Jim", "Jut", "Jag", "Jot", "Jud", 
    "Ken", "Kai", "Kin", "Kid", 
    "Lee", "Len", "Lot", "Leo", "Lux", "Lex", "Lad", "Li", 
    # M-O ----
    "Moe", "Mug", "Mat", "Mic", "Mec", "Mu", "Mo", 
    "Nod", "Nat", "Ned", "Neo", "Nay", "Nap", "Nab", "No",
    "Ori", "Oni", "Orc", "Oaf", "Obi", "Oz", 
    # P-R ----
    "Pop", "Pin", "Psy", "Pig", "Pal", "Pad", "Pa", "Pod", 
    "Quo", 
    "Reb", "Rex", "Raj", "Roc", "Rad", "Rah", "Rai", "Roy", "Rep", "Rob", "Rum", 
    # S-V ----
    "Spy", "Sun", "Sap", "Stu", "Sty", "Soy", "Sin", "Sy", "Six", "Sep", "Sev", 
    "Tom", "Tod", "Ted", "Tim", "Teo", "Tex", "Tar", "Ty", "Top", 
    "Ulg", "Uri", "Ugh", "Udo", "Ulu", 
    "Vic", "Vim", "Van", "Vet", "Von", "Vat", 
    # W-Z ----
    "Wil", "Wes", "Wex", "Wag", "Wad", "Was", 
    "Xo", "Xav", 
    "Yes", "Yah", "Yak", "Yar", "Yo", 
    "Zil", "Zev", "Zap", "Zed") }
  unisex <- { c(
    # A-C ----
    "Arc", "An", "And", "Ash", "Al", "Ave",
    "Bar", "Ban", "Bex", "Bet", "Bay", "Ba", "Bel", 
    "Cam", "Car", "Cal", "Coy", 
    # D-F ----
    "Day", "Dor", "Dax", "Daz", "Dal", "Din", "Da", "Dev", "Dip", 
    "Eon", "Egg",
    "Fry", "Fen", "Fel", "Fam", "Fit", "Fir", "Fip",  
    # G-I ----
    "Gru", "Gen", "Gab", "Gap", "Get", "Gnu", "Gel", 
    "Hay", "Hex", "Hem", "Hid", "Hue", "Hai", "Hej", "Hop", "Hic", "Hep", "Hat",
    "Ink", "Ixi", "Ire", "Iri", "Ilk", 
    # J-L ----
    "Jas", "Jax", 
    "Koi", "Koa", "Kip", "Key", 
    "Les", "Lev", "Let", "Lan", "Let", "Lop", 
    # M-N ----
    "Max", "Mad", "Mag", "Mel", "Mix", "Mac", "Mop", "Met", "My", 
    "Nol", "Nip", "Nox", "Nor", "Nye", "Noa", "Nil", "Nog", 
    "Oak", "Orb", 
    # P-R ----
    "Pen", "Pip", "Pah", "Pet", "Pat", "Pic", 
    "Qui", 
    "Rap", "Red", "Rat", "Ray", "Riz", "Rag", 
    # S-V ----
    "Sam", "Sar", "Sal", "Sen", "Sad", "Sag", "Sup", "Set", "Sel", 
    "Tog", "Tip", "Try", "Tye", "The", "Thy", 
    "Uli", "Urn", "Uke", 
    "Vin", "Vas", "Vie", "Vip", 
    # W-Z ----
    "Who", "Way", "Wat", "Wig", "Win", "Woo", "Wee", "Why", 
    "Xan", 
    "Yep", "Yip", "Yap", "Yam", "Yen", 
    "Zig", "Zag", "Zip", "Zoo", "Zen") }

  # add names ----
  p <- d |> dplyr::mutate(sex = substr(tolower(!!dplyr::sym(var)), 1, 1))
  
  u <- p |> dplyr::filter(is.na(sex)) |>
    dplyr::mutate(name = sample(unisex, size = 11))
  f <- p |> dplyr::filter(sex == "f") |>
    dplyr::mutate(name = sample(c(female, unisex[!unisex %in% u$name]), 
                                size = 165))
  m <- p |> dplyr::filter(sex == "m") |>
    dplyr::mutate(name = sample(c(male, unisex[!unisex %in% c(u$name, f$name)]), 
                                size = 168))
  
  # combine and return ----
  d <- dplyr::bind_rows(list(f, m, u)) 
  return(d)
}
