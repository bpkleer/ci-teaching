math <- 2 + 4

math2 <- 6 * math

###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
# Lab tasks zu Lernblock 3                                                #
# Kurs:    Statistik+: Einstieg in R leicht gemacht                       #
# Autor:   Meike Schulz-Narres, B. Philipp Kleer                          #
# Uni:     Justus-Liebig-University Giessen (Germany)                     #
# Term:    Sommer 2022                                                    #
# Lizenz:  CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/) #                                                                        
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###

# 1. Erstelle eine Tabelle table1 der Variable stfeco aus dem PSS. 
#    Die Tabelle soll neben den gültigen Fällen auch die fehlenden Werte anzeigen.
table1 <- table(
  pss$stfeco, 
  useNA = "ifany"
)
table1

# 2. Erstellt eine Kreuztabelle table2 aus den Variablen district und 
#    income aus dem PSS.
table2 <- table(
  pss$income, 
  pss$district
)
table2

# 3. Nutze das Objekt table2 und gib nun die Spaltenprozente an. 
#    Speichere dies im Objekt table2col.
table2col <- prop.table(
  table2, 
  2
)
table2col

# 4. Teste den Zusammenhang zwischen den Variablen agea und lrscale. 
#    a) Erstelle zuerst ein Scatterplot und speichere dies in plot1. 
#    b) Überlege dir, welches Maß du anwenden kannst!
#    c) Berechne das Maß und speichere das Ergebnis in res1. Verwende hierzu die
#       library psych.

#    c) Berechne das Maß und speichere das Ergebnis in res1. 
library("psych")
res1 <- corr.test(
  pss$agea, 
  pss$lrscale,
  method = "pearson",      
  use = "complete.obs"
)
res1

# 5. Du möchtest wissen, ob sich das Vertrauen der Befragten in das Parlament (trstprl)
#    zwischen den Geschlechtern (gndr) unterscheidet. Du hast dazu in einem angesehenen
#    Journal einen Beitrag gelesen, dass Männer mehr Vertrauen als Frauen haben. Daher
#    testest du einseitig!
library("car")
leveneTest(
  pss$wkhtot,      
  pss$gndr,        
  center = "mean"
) 

levels(pss$gndr)
# female ist erste Gruppe, daher less! Denn Frauen-Mann soll ja negativ sein!
mt1 <- t.test(
  pss$trstprl ~ pss$gndr,     
  mu = 0,                        
  alternative = "less",     
  paired = FALSE,    # ungepaarte Stichproben!            
  var.equal = TRUE  # Option des Levene-Tests!
)   
